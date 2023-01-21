- [ ] Telescope support
- [x] add comment in term.cmd to show terminal id
- [x] BufTermNext & BufTermPrev usercmds
- [x] revert to have BufTermFloatToggle function
- [x] add `prevent_win_close_on_exit=true` option
- [ ] `require('bufterm.terminal').count(buffer)` function (returns total count & current index)
- [ ] `ui.open_win()`, `ui.close_win()` option
- [ ] option to open empty buffer as fallback (with `BufWinLeave` autocmd to automatically remove)

- [ ] support `auto_scroll` (but how? currently only `termopen` can do it)
- [?] startinsert() when back from command output (like `:messeages`)
- [x] run stopinsert() on `terminal-mode` -> `command-mode` -> `:wincmd k`
- [ ] startinsert() inside `TermClose` autocmd (current way is HACK)
- [ ] stable `<C-w>` feature
    - [ ] Add note about Hydra.nvim in README
        (Same algorithm, but created my own to reduce dependency and Hydra.nvim's feature is too masive then this plugin's need)
