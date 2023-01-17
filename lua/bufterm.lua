local ui = require('bufterm.ui')
local term = require('bufterm.terminal')
local config = require('bufterm.config')

local M = {}

---setup bufterm plugin
---@param conf BufTermConfig
function M.setup(conf)
  config.set(conf)

  vim.api.nvim_create_user_command("BufTermEnter", function()
    -- check if current buftype is *NOT* 'terminal'
    if vim.bo.buftype == 'terminal' or vim.bo.filetype == 'terminal' then
      return
    end
    -- get latest terminal buffer (create new if none)
    local t = term.get_recent_term()
    -- open latest terminal buffer
    t:open()
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
        t:open()
      end
      vim.cmd("BufTermEnter")
    end
  end, { count = true })
end

return M
