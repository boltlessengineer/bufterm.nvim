local Terminal = require("bufterm.terminal").Terminal
local term = require("bufterm.terminal")
local conf = require('bufterm.config').options

local augroup = require('bufterm.config').augroup

if conf.save_native_terms then
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function(opts)
      -- check if current buffer is in list to prevent duplicate
      if term.get_id_by_buf(opts.buf) then
        return
      end
      -- create new Terminal object with scanned informations
      local _ = Terminal:new({
        bufnr = opts.buf,
        jobid = vim.fn.jobpid(vim.bo[opts.buf].channel),
      })
      -- set buffer options to make same with bufterm.nvim's terminals
      vim.bo[opts.buf].buflisted = conf.list_buffers
    end,
  })
end

vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function(opts)
    -- detach terminal from list
    -- TODO: add config option on this behavior
    -- config.prevent_close_on_quit
    if vim.api.nvim_buf_is_loaded(opts.buf) then
      local prev_t = term.get_term(term.get_id_by_buf(opts.buf) - 1)
      if prev_t then
        vim.api.nvim_win_set_buf(0, prev_t.bufnr)
      end
      vim.api.nvim_buf_delete(opts.buf, { force = true })
    end
    -- TODO: don't detach here
    -- just execute User->BufTermClose event
    vim.api.nvim_exec_autocmds("User", {
      pattern = "BufTermClose",
      data = {
        buf = opts.buf,
      }
    })
  end
})
-- 33, 34(ls)

function _G.print_buf(str)
  local bufnr = 51
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {str})
end
-- vim.api.nvim_create_autocmd({'TermOpen', 'BufEnter', 'WinEnter'}, {
--   pattern = 'term://*',
--   callback = function (opts)
--     print_buf(string.format('enter : %d', opts.buf))
--     vim.cmd.startinsert()
--   end
-- })
-- vim.api.nvim_create_autocmd({'BufLeave'}, {
--   pattern = 'term://*',
--   callback = function (opts)
--     print_buf(string.format('leave : %d', opts.buf))
--     vim.cmd.stopinsert()
--   end
-- })
vim.api.nvim_create_autocmd({
  'TermOpen',
  'BufEnter',
  'WinEnter',
}, {
  callback = function (opts)
    if (vim.bo[opts.buf].buftype == 'terminal') then
      vim.cmd.startinsert()
    else
      vim.cmd.stopinsert()
    end
  end
})
