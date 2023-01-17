local Terminal = require("bufterm.terminal").Terminal
local term = require("bufterm.terminal")
local conf = require('bufterm.config').options

local augroup = vim.api.nvim_create_augroup('MyTerm', {})

if conf.list_buffers then
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function(opts)
      -- check if current buffer is in terminals list to prevent duplicate
      if not term.is_buf_in_list(opts.buf) then
        return
      end
      -- create new Terminal object with scanned informations
      local t = Terminal:new({
        bufnr = opts.buf,
        -- HACK: how to get jobid inside `TermOpen`?
        jobid = -1,
      })
      -- add to list
      t:__add()
    end,
  })
end

vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function(opts)
    -- detach terminal from list
    term.detach_buf(opts.buf)
  end
})
