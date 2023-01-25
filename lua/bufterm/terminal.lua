local M = {}

local filetype = require('bufterm.config').filetype
local opts     = require('bufterm.config').options
local aug      = require('bufterm.config').augroup

---Terminal list saved by ID
---This list only includes spawned terminals
---@type Terminal[]
local terminals = {}

vim.g.terminal_count = 0

---get Terminal object's index from list by buffer
---@param buffer number
---@return number|nil
local function get_index(buffer)
  if buffer == 0 then
    buffer = vim.api.nvim_get_current_buf()
  end
  for i, v in ipairs(terminals) do
    if v.bufnr == buffer then
      return i
    end
  end
  return nil
end

-- remove termianl buffer from list
-- update all terminals with changed index
local function remove(buffer)
  local i = get_index(buffer)
  local n = #terminals
  if i and (i < 0 or i > n) then
    return nil
  end
  local removed = terminals[i]
  for j = i, n - 1 do
    -- TODO: Terminal:update() updates self & buffer-local variables
    terminals[j] = terminals[j + 1]
    terminals[j]:update(j)
  end
  terminals[n] = nil
  vim.g.terminal_count = n - 1
  return removed
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
---@field fallback_on_exit boolean
---@field list boolean
local Terminal = {}

---Create a new terminal object
---@param term? Terminal
---@return Terminal
function Terminal:new(term)
  term = term or {}
  -- local exist = get_by_buf(term.bufnr)
  -- if exist then return exist end
  self.__index = self
  term.cmd = term.cmd or vim.o.shell
  term.fallback_on_exit = vim.F.if_nil(term.fallback_on_exit, opts.fallback_on_exit)
  term.list = vim.F.if_nil(term.list, true)
  setmetatable(term, self)
  if term.bufnr and term.jobid then
    term:__setup_autocmds()
    if term.list then
      term:__attach()
    end
  end
  return term
end

---Update terminal info by index
---@param index number
function Terminal:update(index)
  self.count = index
  vim.b[self.bufnr].terminal_index = index
end

---Add Terminal to list
---@private
function Terminal:__attach()
  table.insert(terminals, self)
  vim.g.terminal_count = #terminals
  self:update(#terminals)
end

---Remove Terminal from list
---@private
function Terminal:__detach()
  remove(self.bufnr)
  self.bufnr = nil
  self.jobid = nil
end

---@private
function Terminal:__setup_autocmds()
  -- This is executed after TermClose event
  vim.api.nvim_create_autocmd("User", {
    group = aug,
    pattern = "__BufTermClose",
    once = true,
    callback = function(args)
      if args.data.buf == self.bufnr then
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
  if self.bufnr and self.jobid then
    return
  end
  -- create new empty buffer
  self.bufnr = vim.api.nvim_create_buf(opts.list_buffers, false)
  vim.b[self.bufnr].fallback_on_exit = self.fallback_on_exit
  vim.bo[self.bufnr].filetype = filetype
  self:__setup_autocmds()
  -- add to list first (to prevent duplicate from TermOpen)
  if self.list then
    self:__attach()
  end
  -- start terminal in self.bufnr
  vim.api.nvim_buf_call(self.bufnr, function()
    self.jobid = vim.fn.termopen(self.cmd, {
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
  -- self:__add()
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

function M.get_recent_term()
  return terminals[#terminals]
end

function M.get_next_buf(buffer)
  local cur = get_index(buffer)
  if not cur then return nil end
  local i = cur + 1
  if i > #terminals then
    i = i - #terminals
  end
  if not terminals[i] then return nil end
  return terminals[i].bufnr
end

function M.get_prev_buf(buffer)
  local cur = get_index(buffer)
  if not cur then return nil end
  local i = cur - 1
  if i < 1 then
    i = i + #terminals
  end
  if not terminals[i] then return nil end
  return terminals[i].bufnr
end

M.Terminal = Terminal

return M
