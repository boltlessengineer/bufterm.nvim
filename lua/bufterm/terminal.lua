local M = {}

local conf = require('bufterm.config').options
local aug  = require('bufterm.config').augroup
local ui   = require('bufterm.ui')

local is_windows = vim.fn.has('win32') == 1
local function is_cmd(shell) return shell:find("cmd") end

local function get_command_sep()
  return is_windows and is_cmd(vim.o.shell) and '&' or ';'
end

local function get_comment_sep()
  return is_windows and is_cmd(vim.o.shell) and '::' or '#'
end

---Terminal list saved by ID
---This list only includes spawned terminals
---@type Terminal[]
local terminals = {}

---get Terminal object from list by id
---@param buffer number
---@return number|nil
local function get_id_by_buf(buffer)
  for i, v in ipairs(terminals) do
    if v.bufnr == buffer then
      return i
    end
  end
  return nil
end

function M.__get_terms()
  return terminals
end

---@class Terminal
---@field cmd string
---@field jobid number?
---@field bufnr number? bufnr is used as ID
---@field on_stdout fun(job: number, data: string[]?, name:string?)
---@field on_stderr fun(job: number, data: string[], name:string)
---@field on_exit fun(job: number, exit_code: number?, name:string?)
local Terminal = {}

---Create a new terminal object
---@param term Terminal
---@return Terminal
function Terminal:new(term)
  term = term or {}
  -- local exist = get_by_buf(term.bufnr)
  -- if exist then return exist end
  self.__index = self
  term.cmd = term.cmd or vim.o.shell
  local t = setmetatable(term, self)
  if t.bufnr and t.jobid then
    t:__setup_autocmds()
    t:__add()
  end
  return t
end

---@private
function Terminal:__add()
  local id = get_id_by_buf(self.bufnr)
  if id then
    terminals[id] = self
    return
  end
  table.insert(terminals, self)
end

---@private
function Terminal:__detach()
  local index = get_id_by_buf(self.bufnr)
  if index then
    table.remove(terminals, get_id_by_buf(self.bufnr))
  end
  self.bufnr = nil
  self.jobid = nil
end

---@private
function Terminal:__setup_autocmds()
  vim.api.nvim_create_autocmd("User", {
    group = aug,
    pattern = "BufTermClose",
    once = true,
    callback = function (opts)
      if opts.data.buf == self.bufnr then
        self.jobid = nil
      end
    end
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = aug,
    buffer = self.bufnr,
    once = true,
    callback = function()
      self:__detach()
    end,
  })
end

---Spawn terminal in background
function Terminal:spawn()
  -- create new empty buffer
  self.bufnr = vim.api.nvim_create_buf(conf.list_buffers, false)
  self:__setup_autocmds()
  -- add to list first (to prevent duplicate from TermOpen)
  self:__add()
  -- start terminal in self.bufnr
  vim.api.nvim_buf_call(self.bufnr, function()
    -- HACK: cmd should be just pure cmd.
    -- just provide get_term_id() functions
    local comment_sep = get_comment_sep()
    local command_sep = get_command_sep()
    local cmd = table.concat({
      self.cmd,
      command_sep,
      comment_sep,
      self.bufnr
    })
    self.jobid = vim.fn.termopen(cmd, {
      on_stdout = self.on_stdout,
      on_stderr = self.on_stderr,
      on_exit = function(...)
        self.jobid = nil
        if self.on_exit then
          self.on_exit(...)
        end
      end,
    }) or nil -- HACK: fallback to ignore nil warning
  end)
  -- update the terminals list
  self:__add()
end

---Open terminal buffer
---@param window? number winid to open the terminal buffer
function Terminal:enter(window)
  window = window or 0
  if not self.bufnr then
    self:spawn()
  end
  vim.api.nvim_win_set_buf(window, self.bufnr)
end

---Open terminal buffer in floating window
function Terminal:open()
  -- TODO: close all opened floating window with terminal buffer
  self:spawn()
  ui.open_float(self.bufnr)
end

---get terminal by id
---@param id number
---@return Terminal
function M.get_term(id)
  return terminals[id]
end

function M.get_recent_term()
  return terminals[#terminals]
end

function M.get_next_buf(buffer)
  local cur = get_id_by_buf(buffer)
  if not cur then return buffer end
  local i = cur + 1
  if i > #terminals then
    i = i - #terminals
  end
  return terminals[i].bufnr
end

function M.get_prev_buf(buffer)
  local cur = get_id_by_buf(buffer)
  if not cur then return buffer end
  local i = cur - 1
  if i < 1 then
    i = i + #terminals
  end
  return terminals[i].bufnr
end

M.Terminal = Terminal
M.get_id_by_buf = get_id_by_buf

return M
