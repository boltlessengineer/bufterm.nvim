local Terminal = require("bufterm.terminal").Terminal
local term = require("bufterm.terminal")
local conf = require('bufterm.config').options

local augroup = require('bufterm.config').augroup

if conf.save_native_terms then
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function(opts)
      -- check if current buffer is in list to prevent duplicate
      if term.is_buf_in_list(opts.buf) then
        return
      end
      -- create new Terminal object with scanned informations
      local t = Terminal:new({
        bufnr = opts.buf,
        jobid = vim.fn.jobpid(vim.bo[opts.buf].channel),
      })
      -- this won't actually spawn terminal
      -- but just adding spawned terminal to the list
      t:spawn()
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
      local prev_t = term.get_prev_term(opts.buf)
      vim.pretty_print(prev_t)
      if prev_t then
        vim.api.nvim_win_set_buf(0, prev_t.bufnr)
      end
      vim.api.nvim_buf_delete(opts.buf, { force = true })
    end
    term.detach_buf(opts.buf)
  end
})
