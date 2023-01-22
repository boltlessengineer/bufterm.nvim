local term     = require('bufterm.terminal')
local Terminal = require('bufterm.terminal').Terminal
local config   = require('bufterm.config')
local ui       = require('bufterm.ui')

local M = {}

---setup bufterm plugin
---@param conf BufTermConfig
function M.setup(conf)
  config.set(conf)

  require('bufterm.autocmds')
  require('bufterm.keymaps')

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

  vim.api.nvim_create_user_command("BufTermNext", function()
    local buf = vim.api.nvim_get_current_buf()
    local next_buf = term.get_next_buf(buf)
    if next_buf then
      vim.api.nvim_win_set_buf(0, next_buf)
    end
  end, {})

  vim.api.nvim_create_user_command("BufTermPrev", function()
    local buf = vim.api.nvim_get_current_buf()
    local prev_buf = term.get_prev_buf(buf)
    if prev_buf then
      vim.api.nvim_win_set_buf(0, prev_buf)
    end
  end, {})

  vim.api.nvim_create_user_command('BufTermFloat', function()
    local winid = ui.toggle_float()
    if winid then
      local t = term.get_recent_term()
      if not t then
        t = Terminal:new()
      end
      t:spawn()
      vim.api.nvim_win_set_buf(winid, t.bufnr)
    end
  end, {})
end

function M.winbar()
  local count, current = term.count_terms()
  return string.format('[%d/%d]', current or 0, count)
end

return M
