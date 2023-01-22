local Terminal = require("bufterm.terminal").Terminal
local term     = require("bufterm.terminal")
local conf     = require('bufterm.config').options
local augroup  = require('bufterm.config').augroup
local utils    = require('bufterm.utils')

if conf.save_native_terms then
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function(opts)
      -- check if current buffer is in list to prevent duplicate
      if term.get_index(opts.buf) then
        return
      end
      -- create new Terminal object with scanned informations
      local ok, jobid = pcall(vim.fn.jobpid, vim.bo[opts.buf].channel)
      if not ok then return end
      local _ = Terminal:new({
        bufnr = opts.buf,
        jobid = jobid,
      })
      -- set buffer options to make same with bufterm.nvim's terminals
      vim.bo[opts.buf].buflisted = conf.list_buffers
      vim.b[opts.buf].fallback_on_exit = conf.fallback_on_exit
    end,
  })
end

local term_mode_var = '__terminal_mode'
local function set_mode(buf, mode)
  vim.b[buf][term_mode_var] = mode
end
local function get_mode(buf)
  return vim.b[buf][term_mode_var]
end

-- TODO: what if user manually :bdelete!?
-- -> user just should not manually :bdelete
-- -> actually that's :bdelete's default behavior (same with normal files)
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function(opts)
    if vim.b[opts.buf].fallback_on_exit then
      vim.schedule(function()
        if vim.api.nvim_buf_is_loaded(opts.buf) then
          local prev_buf = term.get_prev_buf(opts.buf)
          if prev_buf and prev_buf ~= opts.buf then
            vim.api.nvim_set_current_buf(prev_buf)
            -- HACK: hack from u/pysan3
            if get_mode(prev_buf) == 't' then
              utils.log('feedkeys    after TermClose')
              vim.api.nvim_feedkeys('A', 'n', false)
            end
          end
          vim.api.nvim_buf_delete(opts.buf, { force = true })
        end
      end)
    else
      vim.schedule(function()
        if vim.api.nvim_buf_is_loaded(opts.buf) then
          vim.api.nvim_buf_delete(opts.buf, { force = true })
        end
      end)
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
  callback = vim.schedule_wrap(function(args)
    if conf.start_in_insert then
      utils.log('startinsert in TermOpen')
      if conf.remember_mode then
        set_mode(args.buf, 't')
      else
        set_mode(args.buf, 'n')
      end
    end
  end),
})
if conf.remember_mode then
  vim.api.nvim_create_autocmd('TermEnter', {
    group = augroup,
    callback = function(args)
      set_mode(args.buf, 't')
    end
  })
  vim.api.nvim_create_autocmd('TermLeave', {
    group = augroup,
    callback = function(args)
      set_mode(args.buf, 'n')
    end
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    pattern = 'term://*',
    callback = vim.schedule_wrap(function(args)
      if get_mode(args.buf) == 'n' then
        utils.log('stopinsert  in BufEnter')
        vim.cmd.stopinsert()
      else
        utils.log('startinsert in BufEnter')
        vim.cmd.startinsert()
      end
    end),
  })
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = augroup,
    pattern = 'c:ntT',
    callback = vim.schedule_wrap(function(args)
      local new_buf = vim.api.nvim_get_current_buf()
      if args.buf ~= new_buf then
        -- re-enter terminal mode at that buffer
        -- to handle when user entered command line from terminal mode
        vim.api.nvim_exec_autocmds('TermEnter', {
          buffer = args.buf,
        })
        local is_new_term = vim.bo[new_buf].buftype == 'terminal'
        -- if changed buffer is not terminal buffer, stopinsert
        if not is_new_term then
          vim.cmd.stopinsert()
        end
      end
    end)
  })
end
