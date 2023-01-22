- [ ] Better name

- [ ] Telescope support
- [x] add comment in term.cmd to show terminal id
- [x] BufTermNext & BufTermPrev usercmds
- [x] revert to have BufTermFloatToggle function
- [x] add `prevent_win_close_on_exit=true` option
- [ ] combine `prevent_win_close_on_exit` and `use_fallback_buffer` to one `fallback_on_exit` option

# UI
- [ ] handle situation when cycle through terminal buffers in floating-window while they are also opened in normal split windows
    - [ ] just don't allow to open in floating window while it is in split window
    - [ ] detect split & enter new terminal buffer
- [ ] b:bufterm_index & g:bufterm_count variables for winbar
- [-] `ui.open_win()` option (used by `:BufTermToggle`)
- [x] `utils.toggle_float(buf)` default helper function
- [ ] option to open empty buffer as fallback (with `BufWinLeave` autocmd to automatically remove)

# Terminal
- [ ] support `auto_scroll` (but how? currently only `termopen` can do it)
- [ ] `prevent_win_close_on_exit` goes to `Terminal`'s option (set default from config)

# Keymap/Vi-mode
- [x] run stopinsert() on `terminal-mode` -> `command-mode` -> `:wincmd k`
- [x] `<C-w>` feature
- [ ] Seperate Keymap feature as other plugin. Leave only Vi-mode feature
- [ ] startinsert() inside `TermClose` autocmd (current way is HACK)
- [ ] Option to set more wincmds

# Bug?
- [ ] lazygit (floating) -> `C` (nvim-unception) -> `:wq` -> lazygit goes to background window..???
