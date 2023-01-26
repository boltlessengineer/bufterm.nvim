# bufterm.nvim

> Treat terminals as buffers, not windows.

A neovim plugin to manage terminal buffers

## Thoughts

- No need to open terminal buffer in new specific window every time.
- User should able to *enter* terminal buffers in *any window*.

Other terminal plugins are great but it is hard to manually set terminal buffer to window layout user wants.

BufTerm NEVER create terminal window on it's own. It only gives you `enter()` function to enter terminal buffer. User can always manually close buffer with `:bdelete!` and window with `:close`

## Features

https://user-images.githubusercontent.com/60088301/213930518-37b8fdb1-299a-4c24-a926-5936cbf3d205.mov

### Enter & Switch Terminal buffers

You can enter terminal buffer in *any* windows. Just enter the window you want, and run `:BufTermEnter`

You can also cycle through terminal buffers with `:BufTermNext` and `:BufTermPrev` commads.

### Vim8-like Window navigation

Automatically restore the last mode when leaving the terminal buffer.

Window navigation using `<C-w>` key directly in terminal mode just like vim8.

> **Warning**
> Don't use keymap `<C-\><C-n><C-w>...` or `<C-\><C-o><C-w>...` for window navigation. This will break `remember_mode` feature.
> Instead, use `:wincmd` or `enable_ctrl_w` option below.

### Compatible with native commands

Although BufTerm provides various useful commands, you can still use Neovim's native commands like `:terminal`, `:buffer`, `:bprev`, `:wincmd`

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
  save_native_terms = true, -- integrate native terminals from `:terminal` command
  start_in_insert   = true, -- start terminal in insert mode
  remember_mode     = true, -- remember vi_mode of terminal buffer
  enable_ctrl_w     = true, -- use <C-w> for window navigating in terminal mode (like vim8)
  terminal = {              -- default terminal settings
    buflisted         = true, -- whether to set 'buflisted' option
    fallback_on_exit  = true, -- prevent auto-closing window on terminal exit
  }
})
```
> **Note**: `fallback_on_exit` option won't work with `:bdelete!` command

## Usage

- Enter terminal buffers in current window with `:BufTermEnter`
- Open new terminal buffer with `:terminal` or `:BufTermEnter`
- Switch between terminal buffers with `:BufTermNext` and `:BufTermPrev`

### `:BufTermEnter`

Enter terminal buffer in current window.
Create new terminal buffer if there is no terminal buffer running

### `:BufTermPrev`, `:BufTermNext`

Cycle through list of terminal buffers

### `Terminal:new(term)`

Create new `Terminal` object. See the [examples](#Tips) below.

### `Terminal:spawn()`

Spawn the terminal buffer. This will spawn new terminal job and create the buffer for it. But not showing the actual buffer in window yet.

### `Terminal:enter(window)`

Open terminal buffer in specific window.

## Tips

### Open Lazygit in floating window

```lua
-- this will add Terminal to the list (not starting job yet)
local Terminal = require('bufterm.terminal').Terminal
local ui       = require('bufterm.ui')

local lazygit = Terminal:new({
  cmd = 'lazygit',
})
vim.keymap.set('n', '<leader>g', function()
  -- spawn terminal (terminal won't be spawned if self.jobid is valid)
  lazygit:spawn()
  -- open floating window
  ui.toggle_float(lazygit.bufnr)
end, {
  desc = 'Open lazygit in floating window',
})
```

### Toggle Floating terminal
```lua
local term = require('bufterm.terminal')
local ui   = require('bufterm.ui')

vim.keymap.set({ 'n', 't' }, '<C-t>', function()
  local recent_term = term.get_recent_term()
  ui.toggle_float(recent_term.bufnr)
end, {
  desc = 'Toggle floating window with terminal buffers',
})
```

# Inspirations

- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [hydra.nvim](https://github.com/anuvyklack/hydra.nvim)
