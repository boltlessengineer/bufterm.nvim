# Generals
- [ ] Telescope support

# UI
- [ ] handle situation when cycle through terminal buffers in floating-window while they are also opened in normal split windows
    - [ ] just don't allow to open in floating window while it is in split window
    - [ ] detect split & enter new terminal buffer
- [ ] Stable winbar support
- [ ] mouse support

# Terminal
- [ ] support `auto_scroll` (but how? currently only `termopen` can do it)
- [x] `auto_close=false` option to support terminal jobs like `build`, `run` things.
    - don't detach terminal when `TermClose`. detach when `BufDelete`
    - remember terminal buffers even jobs are finished

# Group
- Group buffers feature
- People can open specical window containing all terminal/quickrun related buffers
- This works similar to VSC's integrated terminal window

# Keymap/Vi-mode
- [ ] startinsert() inside `TermClose` autocmd (current way is HACK)

# Bug
- [ ] bug when `git commit` with nvim-unception
    lazygit (floating) -> `C` (nvim-unception) -> `:wq` -> lazygit goes to background window..???
