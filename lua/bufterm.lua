local ui = require('bufterm.ui')
local term = require('bufterm.terminal')
local Terminal = require('bufterm.terminal').Terminal
local config = require('bufterm.config')

local M = {}

---setup bufterm plugin
---@param conf BufTermConfig
function M.setup(conf)
  config.set(conf)

  require('bufterm.autocmds')

  vim.api.nvim_create_user_command("BufTermEnter", function()
    -- check if current buftype is *NOT* 'terminal'
    if vim.bo.buftype == 'terminal' then return end
    -- get latest terminal buffer (create new if none)
    local t = term.get_recent_term()
    if not t then
      t = Terminal:new({
      })
    end
    -- enter latest terminal buffer
    t:enter()
  end, {})

  vim.api.nvim_create_user_command("BufTermNext", function ()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(0, term.get_next_buf(buf))
  end, {})

  vim.api.nvim_create_user_command("BufTermPrev", function ()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(0, term.get_prev_buf(buf))
  end, {})

  -- use Terminal:open(opener) instead of TermToggle
end

return M
