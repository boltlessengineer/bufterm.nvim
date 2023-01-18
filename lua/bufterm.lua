local ui = require('bufterm.ui')
local term = require('bufterm.terminal')
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
    -- enter latest terminal buffer
    t:enter()
  end, {})

  vim.api.nvim_create_user_command("BufTermNext", function ()
    if vim.bo.buftype ~= 'terminal' then return end
    local buf = vim.api.nvim_get_current_buf()
    local t = term.get_next_term(buf)
    if t then
      vim.api.nvim_win_set_buf(0, t.bufnr)
    end
  end, {})

  vim.api.nvim_create_user_command("BufTermPrev", function ()
    if vim.bo.buftype ~= 'terminal' then return end
    local buf = vim.api.nvim_get_current_buf()
    local t = term.get_prev_term(buf)
    if t then
      vim.api.nvim_win_set_buf(0, t.bufnr)
    end
  end, {})

  -- usercmd for toggling floating terminal window
  vim.api.nvim_create_user_command("BufTermToggle", function(opts)
    -- check if current window is floating window
    if vim.api.nvim_win_get_config(0).relative == 'editor' then
      -- close current(floating) window
      vim.cmd.close()
      return
    else
      -- open new floating-window
      ui.open_float()
      if opts.count and opts.count > 0 then
        local t = term.get_term(opts.count)
        if not t then
          t = term.Terminal:new({
            id = opts.count
          })
        end
        t:enter()
      end
      vim.cmd("BufTermEnter")
    end
  end, { count = true })
end

return M
