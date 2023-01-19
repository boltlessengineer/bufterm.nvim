# bufterm.nvim

> This readme is work in progress

A neovim plugin to manage *only* terminal-buffers

## Thoughts

Terminal object should NEVER contain specific window information.
Managing windows are completely another job.
User should able to *enter* terminal buffers in current window.
This also makes managing neovim's default `:terminal` command much easy.

[toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) is great but it is hard to manually set terminal buffer to window layout user wants.

bufterm won't save window information in Terminal object. So there is no *close* or *toggle* function. User can always manually close buffer with `:bd!` and window with `:close`

## Usage

Open new terminal buffer with `:terminal` or `:BufTermEnter`

### `:[range]BufTermEnter`

Enter terminal buffer in current window.
Create new terminal buffer if there is no terminal buffer running
If `[range]` value is given, it will be the terminal id.

### `:[range]BufTermToggle`

Toggle Terminal buffer in way user wants

## Tips

### Toggle Lazygit with bufterm.nvim

```lua
-- this will add Terminal to the list (not starting job yet)
local Terminal = require('bufterm.terminal').Terminal
local lazygit = Terminal:new({
  id = 99, -- set id with number you won't use
  cmd = 'lazygit',
})
local function ToggleLazyGit()
  vim.cmd [[99BufTermToggle]]
end
vim.keymap.set('n', '<leader>g', '99BufTermToggle', {
  desc = 'Toggle lazygit floating window',
})
```
