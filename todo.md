# Generals
- [ ] Better name
    - enterm.nvim
    - bufterm.nvim
    - enhenced-terminal.nvim
- [ ] Telescope support

# UI
- [ ] handle situation when cycle through terminal buffers in floating-window while they are also opened in normal split windows
    - [ ] just don't allow to open in floating window while it is in split window
    - [ ] detect split & enter new terminal buffer

# Terminal
- [x] way to handle *single* terminals like `lazygit`
    - don't fallback to any other terminals
    - don't be entered from other terminals
- [ ] support `auto_scroll` (but how? currently only `termopen` can do it)

# Keymap/Vi-mode
- [ ] Seperate Keymap feature as other plugin. Leave only Vi-mode feature
- [ ] startinsert() inside `TermClose` autocmd (current way is HACK)

# Bug
- [ ] bug when `git commit` with nvim-unception
    lazygit (floating) -> `C` (nvim-unception) -> `:wq` -> lazygit goes to background window..???
