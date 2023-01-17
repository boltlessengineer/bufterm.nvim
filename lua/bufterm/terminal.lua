local opts = require('bufterm.config').options

local M = {}

---Terminal list saved by ID
---@type Terminal[]
local terminals = {}

function M.__print_terms()
  vim.pretty_print(terminals)
end

---@class Terminal
---@field id number
---@field cmd string
---@field bufnr number
local Terminal = {}

---Create a new terminal object
---@param term Terminal
---@return Terminal
function Terminal:new(term)
  term = term or {}
  self.__index = self
  term.cmd = term.cmd or vim.o.shell
  local t = setmetatable(term, self)
  -- add to list if specific id is given (see README/tips)
  if term.id then
    t:__update()
  end
  return t
end

---@private
function Terminal:__update()
  terminals[self.id] = self
  return self
end

function Terminal:__add()
  self.id = self.id or #terminals + 1
  self:__update()
end

---Spawn terminal in background
function Terminal:spawn()
  if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
    -- create new empty buffer
    self.bufnr = vim.api.nvim_create_buf(opts.list_buffers, false)
  end
  -- add terminal to list first (to bypass TermOpen autocmd)
  self:__add()

  -- start terminal in self.bufnr
  vim.api.nvim_buf_call(self.bufnr, function()
    self.jobid = vim.fn.termopen(self.cmd, {
      on_exit = function()
      end
    })
  end)
  -- now update the terminal list
  self:__update()
end

---Open terminal buffer
---@param window? number winid to open the terminal buffer
function Terminal:open(window)
  window = window or 0
  if (not self.bufnr) or (not vim.api.nvim_buf_is_valid(self.bufnr))
      or (not self.jobid) then
    self:spawn()
  end
  vim.api.nvim_win_set_buf(window, self.bufnr)
end

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
  if #terminals > 0 then
    term = terminals[#terminals]
  else
    term = Terminal:new({
    })
  end
  return term
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
