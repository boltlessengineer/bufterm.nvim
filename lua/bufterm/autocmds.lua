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
-- -> actually that's :bdelete's default behavior (same with normal files)
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
  callback = function()
    if conf.start_in_insert then
      vim.cmd.startinsert()
    end
  end,
})
if conf.remember_mode then
  local term_mode_var = '__terminal_mode'
  -- Save mode once when user enters/leaves terminal buffer first time
  vim.api.nvim_create_autocmd('TermOpen', {
    group = augroup,
    callback = function(args)
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
        group = augroup,
        buffer = args.buf,
        once = true,
        callback = function()
          local mode = vim.fn.mode()
          vim.api.nvim_buf_set_var(args.buf, term_mode_var, mode)
        end
      })
    end,
  })
  vim.api.nvim_create_autocmd('TermEnter', {
    group = augroup,
    callback = function(args)
      vim.api.nvim_buf_set_var(args.buf, term_mode_var, 't')
    end
  })
  vim.api.nvim_create_autocmd('TermLeave', {
    group = augroup,
    callback = function(args)
      vim.api.nvim_buf_set_var(args.buf, term_mode_var, 'n')
    end
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    pattern = 'term://*',
    callback = vim.schedule_wrap(function(args)
      local mode = vim.api.nvim_buf_get_var(args.buf, term_mode_var)
      if mode == 't' then
        vim.cmd.startinsert()
      end
    end),
  })
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = augroup,
    pattern = 'c:ntT',
    callback = vim.schedule_wrap(function (args)
      local new_buf = vim.api.nvim_get_current_buf()
      if args.buf ~= new_buf then
        vim.cmd.stopinsert()
        vim.api.nvim_exec_autocmds('TermEnter', {
          buffer = args.buf,
        })
      end
    end)
  })
end
