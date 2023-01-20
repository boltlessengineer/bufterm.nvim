local Terminal = require("bufterm.terminal").Terminal
local term = require("bufterm.terminal")
local conf = require('bufterm.config').options

local augroup = require('bufterm.config').augroup

if conf.save_native_terms then
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function(opts)
      -- check if current buffer is in list to prevent duplicate
      if term.get_index(opts.buf) then
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

local function get_fallback_buffer()
  -- create empty buffer
  local buffer = vim.api.nvim_create_buf(true, false)
  return buffer
end

-- TODO: what if user manually :bdelete!?
-- -> user just should not manually :bdelete
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function(opts)
    if conf.prevent_win_close_on_exit then
      -- if vim.api.nvim_buf_is_loaded(opts.buf) then
      vim.schedule(function()
        if vim.api.nvim_buf_is_loaded(opts.buf) then
          local prev_buf = term.get_prev_buf(opts.buf)
          if prev_buf and prev_buf ~= opts.buf then
            vim.api.nvim_set_current_buf(prev_buf)
            -- HACK: hack from u/pysan3
            if vim.api.nvim_buf_get_var(prev_buf, '__terminal_mode') then
              vim.api.nvim_feedkeys('A', 'n', false)
            end
          elseif conf.use_fallback_buffer then
            vim.api.nvim_set_current_buf(get_fallback_buffer())
          end
          -- check one more time in schedule
          vim.api.nvim_buf_delete(opts.buf, { force = true })
        end
      end)
      -- end
    end
    vim.api.nvim_exec_autocmds("User", {
      pattern = "__BufTermClose",
      data = {
        buf = opts.buf,
      }
    })
  end
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup,
  callback = function(args)
    if conf.start_in_insert then
      vim.cmd.startinsert()
    end
    vim.api.nvim_buf_set_var(args.buf, '__terminal_mode', conf.start_in_insert)
  end,
})
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = 'term://*',
  callback = vim.schedule_wrap(function(args)
    if vim.api.nvim_buf_get_var(args.buf, '__terminal_mode') then
      vim.cmd.startinsert()
    end
  end),
})
vim.api.nvim_create_autocmd('BufLeave', {
  group = augroup,
  pattern = 'term://*',
  callback = function()
    vim.cmd.stopinsert()
  end
})
if conf.remember_mode then
  vim.api.nvim_create_autocmd('TermEnter', {
    group = augroup,
    callback = function(args)
      vim.api.nvim_buf_set_var(args.buf, '__terminal_mode', true)
    end,
  })
  vim.keymap.set('t', '<Plug>(term-pre-normal-mode)', function()
    vim.api.nvim_buf_set_var(0, '__terminal_mode', false)
  end)
end
