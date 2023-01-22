- [ ] Telescope support
- [x] add comment in term.cmd to show terminal id
- [x] BufTermNext & BufTermPrev usercmds
- [x] revert to have BufTermFloatToggle function
- [x] add `prevent_win_close_on_exit=true` option

# UI
- [ ] b:bufterm_index & g:bufterm_count variables for winbar
- [ ] `ui.toggle_win()` option (used by `:BufTermToggle`)
- [ ] option to open empty buffer as fallback (with `BufWinLeave` autocmd to automatically remove)

# Terminal
- [ ] support `auto_scroll` (but how? currently only `termopen` can do it)
- [ ] `prevent_win_close_on_exit` goes to `Terminal`'s option (set default from config)

# Keymap/Vi-mode
- [x] run stopinsert() on `terminal-mode` -> `command-mode` -> `:wincmd k`
- [ ] startinsert() inside `TermClose` autocmd (current way is HACK)
- [ ] keymaps
    - [x] `<C-w>` feature
    - [ ] Add note about Hydra.nvim in README
        (Similar algorithm, but created my own to reduce dependency and Hydra.nvim's feature is too masive then this plugin's need)
