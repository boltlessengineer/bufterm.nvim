local conf = require('bufterm.config').options

if not conf.enable_ctrl_w then
  return
end

local wincmd_key = '<C-w>'
local function _tmap_wincmd(lhs, rhs, opts)
  vim.keymap.set('t', wincmd_key .. lhs, rhs, opts)
end

local mode_wincmd = false
local original_timeout = vim.o.timeout
local function leave_wincmd()
  vim.o.timeout = original_timeout
  mode_wincmd = false
end

-- map <C-w>
_tmap_wincmd('', function()
  if mode_wincmd then
    leave_wincmd()
    return
  end
  original_timeout = vim.o.timeout
  vim.o.timeout = false
  mode_wincmd = true
  -- re-input <C-w> (with notimeout)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(wincmd_key, true, true, true),
    '', false)
end)

for _, lhs in ipairs({
  'h', 'j', 'k', 'l', 'H', 'J', 'K', 'L', 'w',
  'v', 's', 'o', 'q',
  '+', '-', '<', '>', '=',
}) do
  local cmd = lhs
  local rhs = function()
    vim.cmd.wincmd(cmd)
    leave_wincmd()
  end
  _tmap_wincmd(lhs, rhs)
  if string.match(lhs, '[a-z]') then
    lhs = string.format('<C-%s>', lhs)
    _tmap_wincmd(lhs, rhs)
  elseif string.match(lhs, '[A-Z]') then
    lhs = string.format('<CS-%s>', lhs)
    _tmap_wincmd(lhs, rhs)
  end
end
-- TODO: check if this runs `TermLeave`
-- TODO: setup autocmd to run `stopinsert()` on `:wincmd` here
_tmap_wincmd(':', [[<C-\><C-o>:]])
