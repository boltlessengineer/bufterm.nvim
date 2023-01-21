# bufterm.nvim

> This readme is work in progress

A neovim plugin to manage *only* terminal-buffers

## Thoughts

Terminal object should NEVER contain specific window information.
Managing windows is completely another job.
User should able to *enter* terminal buffers in any window.
This also makes managing neovim's default `:terminal` command much easy.

[toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) is great but it is hard to manually set terminal buffer to window layout user wants.

bufterm won't save window information in Terminal object. So there is no *close* or *toggle* function. User can always manually close buffer with `:bdelete!` and window with `:close`

## Installation

Using packer.nvim

```lua
use {
  'boltlessengineer/bufterm.nvim',
  config = function()
    require('bufterm').setup()
  end,
}
```

## Setup

Below is default configuration

```lua
require('bufterm').setup({
  normal_mode_keymap = [[<C-[>]],   -- keymap to enter normal-mode in terminal buffers
  save_native_terms = true,         -- integrate native terminals from `:terminal` command
  prevent_win_close_on_exit = true, -- prevent auto-closing window on terminal exit
  use_fallback_buffer = true,       -- open empty buffer when no terminal window left
  start_in_insert = true,           -- start terminal in insert mode
  remember_mode = true,             -- remember vi_mode of terminal buffer
  ui = {
    width = 0.9,                    -- UI options for default floating window
    height = 0.9,
  },
})
```
> **Note**: `prevent_close_on_exit` option won't work with `:bdelete!` command

## Usage

- Open new terminal buffer with `:terminal` or `:BufTermEnter`
- Switch between terminal buffers with `:BufTermNext` and `:BufTermPrev`

### `:BufTermEnter`

Enter terminal buffer in current window.
Create new terminal buffer if there is no terminal buffer running

### `:BufTermFloat`

Toggle Terminal buffer in way user wants (default is floating window)

### `:BufTermPrev`, `:BufTermNext`

Cycle through list of terminal buffers

## Tips

### Open Lazygit with bufterm.nvim

```lua
-- this will add Terminal to the list (not starting job yet)
local Terminal = require('bufterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = 'lazygit',
})
vim.keymap.set('n', '<leader>g', function()
  lazygit:open()
end, {
  desc = 'Toggle lazygit floating window',
})
```
