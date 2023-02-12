local M = {}

local filetype = require('bufterm.config').filetype
local opts     = require('bufterm.config').options
local aug      = require('bufterm.config').augroup
local utils    = require('bufterm.utils')

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
  if (not i) or (i < 0 or i > n) then
    return nil
  end
  local removed = terminals[i]
  for j = i, n - 1 do
    terminals[j] = terminals[j + 1]
    utils.log('term shift', terminals[j].count, '->', j)
    terminals[j].count = j
    vim.b[terminals[j].bufnr].terminal_index = j
  end
  terminals[n] = nil
  vim.g.terminal_count = n - 1
  return removed
end

function M.__get_terms()
  return terminals
end

---@class Terminal
---@field cmd string|fun():string
---@field jobid number?
---@field bufnr number? bufnr is used as ID
---@field on_stdout fun(job: number, data: string[]?, name:string?)
---@field on_stderr fun(job: number, data: string[], name:string)
---@field on_exit fun(job: number, exit_code: number?, name:string?)
---@field buflisted boolean
---@field termlisted boolean set this false if you treat this terminal as single independent terminal.
---@field fallback_on_exit boolean ignored when termlisted is false
---@field auto_close boolean
local Terminal = {}

---Create a new terminal object
---@param term? Terminal
---@return Terminal
function Terminal:new(term)
  term = term or {}
  utils.log('Terminal:new() for', term.bufnr)
  self.__index = self
  term.cmd = term.cmd or vim.o.shell
  term.buflisted = vim.F.if_nil(term.buflisted, opts.terminal.buflisted)
  term.fallback_on_exit = vim.F.if_nil(term.fallback_on_exit, opts.terminal.fallback_on_exit)
  term.termlisted = vim.F.if_nil(term.termlisted, true)
  if term.auto_close ~= nil then
    -- just use given value
  elseif term.cmd == vim.o.shell then
    term.auto_close = true
  else
    term.auto_close = opts.terminal.auto_close
  end
  setmetatable(term, self)
  if term.bufnr and term.jobid then
    term:__setup()
  end
  return term
end

---Add Terminal to list
---@private
function Terminal:__attach()
  if get_index(self.bufnr) then return end
  utils.log('Terminal:__attach() for', self.bufnr)
  table.insert(terminals, self)
  vim.g.terminal_count = #terminals
  -- setting self.count will automatically update buffer variable
  self.count = #terminals
end

---Remove Terminal from list
---@private
function Terminal:__detach()
  utils.log('Terminal:__detach() for', self.bufnr)
  remove(self.bufnr)
  self.bufnr = nil
  self.jobid = nil
end

---@private
function Terminal:__setup()
  utils.log('Terminal:__setup() for', self.bufnr)
  -- This is executed after TermClose event
  vim.api.nvim_create_autocmd("User", {
    group = aug,
    pattern = "__BufTermClose",
    callback = function(args)
      -- utils.log("__BufTermClose")
      if args.data.buf == self.bufnr then
        self.jobid = nil
        return true
      end
    end
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    group = aug,
    buffer = self.bufnr,
    callback = function(args)
      -- ignore if self.bufnr is changed
      if args.buf ~= self.bufnr then return end
      self:__detach()
      return true
    end,
  })
  if self.termlisted then
    self:__attach()
  end
  vim.bo[self.bufnr].filetype = filetype
  vim.bo[self.bufnr].buflisted = self.buflisted
  vim.b[self.bufnr].termlisted = self.termlisted
  vim.b[self.bufnr].auto_close = self.auto_close
  vim.b[self.bufnr].fallback_on_exit = self.fallback_on_exit
  vim.b[self.bufnr].terminal_index = self.count
end

---@private
function Terminal:__spawn()
  -- create new empty buffer
  self.bufnr = vim.api.nvim_create_buf(self.buflisted, false)
  utils.log('Terminal:__spawn() for', self.bufnr)
  self:__setup()
  local cmd
  if type(self.cmd) == "function" then
    cmd = self.cmd()
    -- TODO: stop spawning terminal if self.cmd() == nil
  else
    cmd = self.cmd
  end
  vim.api.nvim_buf_call(self.bufnr, function()
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
end

---Run job in terminal's buffer
---This would refresh all existing terminal windows with new buffer
function Terminal:run()
  if self.jobid then return end
  utils.log('Terminal:run() bufnr =', self.bufnr)
  local prev_bufnr = self.bufnr
  -- run terminal job in new buffer
  self:__spawn()
  -- switch all window's prevent buffer to new buffer
  if prev_bufnr then
    local winlist = vim.api.nvim_list_wins()
    for _, win in pairs(winlist) do
      if prev_bufnr == vim.api.nvim_win_get_buf(win) then
        utils.log('switch prev window to bufnr =', self.bufnr)
        vim.api.nvim_win_set_buf(win, self.bufnr)
      end
    end
    -- detach previous buffer
    vim.api.nvim_buf_delete(prev_bufnr, { force = true })
  end
end

---Spawn terminal in background
function Terminal:spawn()
  if self.bufnr then return end
  self:__spawn()
end

---Open terminal buffer
---@param window? number winid to open the terminal buffer
function Terminal:enter(window)
  window = window or 0
  self:spawn()
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
