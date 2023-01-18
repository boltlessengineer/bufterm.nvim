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
---This list even includes terminals not running (YET)
---@type Terminal[]
local terminals = {}

local function get_last_id()
  for i, v in ipairs(terminals) do
    if not v then
      return i - 1
    end
  end
  return #terminals
end

function M.__get_terms()
  return terminals
end

---@class Terminal
---@field id number
---@field cmd string
---@field jobid number
---@field bufnr number
---@field on_stdout fun(job: number, data: string[]?, name:string?)
---@field on_stderr fun(job: number, data: string[], name:string)
---@field on_exit fun(job: number, exit_code: number?, name:string?)?
local Terminal = {}

---Create a new terminal object
---@param term Terminal
---@return Terminal
function Terminal:new(term)
  term = term or {}
  if terminals[term.id] then
    return terminals[term.id]
  end
  self.__index = self
  term.cmd = term.cmd or vim.o.shell
  local t = setmetatable(term, self)
  -- add to list if specific id is given (see README/tips)
  if term.id then
    t:__add()
  end
  return t
end

---@private
function Terminal:__add()
  terminals[self.id] = self
  return self
end

---Spawn terminal in background
function Terminal:spawn()
  if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
    -- create new empty buffer
    self.bufnr = vim.api.nvim_create_buf(conf.list_buffers, false)
    vim.api.nvim_create_autocmd("BufDelete", {
      group = aug,
      buffer = self.bufnr,
      callback = function()
        self.bufnr = nil
        self.jobid = nil
      end,
    })
  end
  self.id = self.id or get_last_id() + 1
  if not self.jobid then
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
        self.id
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
      }) or 0 -- HACK: fallback to ignore nil warning
    end)
  end
  -- add to terminal list
  self:__add()
end

---Open terminal buffer
---@param window? number winid to open the terminal buffer
function Terminal:enter(window)
  window = window or 0
  self:spawn()
  vim.api.nvim_win_set_buf(window, self.bufnr)
end

---Open terminal buffer in floating window
function Terminal:open()
  -- TODO: close all opened floating window with terminal buffer
  self:spawn()
  ui.open_float(self.bufnr)
end

---returns terminal by buffer
---@param buffer number
---@return Terminal|nil
function M.is_buf_in_list(buffer)
  for _, v in ipairs(terminals) do
    if v.bufnr == buffer then
      return v
    end
  end
  return nil
end

---get terminal by id
---@param id number
---@return Terminal
function M.get_term(id)
  return terminals[id]
end

function M.get_recent_term()
  local term
  local lid = get_last_id()
  if lid > 0 then
    term = terminals[lid]
  else
    -- TODO: don't return new terminal here. just return nil
    term = Terminal:new({
    })
  end
  return term
end

function M.get_next_term(buf)
  local cur = M.is_buf_in_list(buf)
  if not cur then
    return M.get_recent_term()
  end
  for i, v in ipairs(terminals) do
    if i == cur.id + 1 then
      return v
    end
  end
  return terminals[1]
end

function M.get_prev_term(buf)
  -- TODO: change algorithm entirely.
  -- cycle through with pairs() then ipairs()
  local cur = M.is_buf_in_list(buf)
  if not cur then
    return M.get_recent_term()
  end
  local prev_term
  for i, v in pairs(terminals) do
    if i == cur.id then break end
    prev_term = v
  end
  return prev_term
end

function M.detach_buf(buffer)
  for i, v in ipairs(terminals) do
    if v.bufnr == buffer then
      terminals[i] = nil
    end
  end
end

M.Terminal = Terminal

return M
