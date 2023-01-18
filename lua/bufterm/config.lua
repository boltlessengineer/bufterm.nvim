local M = {}

---@class BufTermUIConfig
---@field width number
---@field height number

---@class BufTermConfig
---@field list_buffers boolean
---@field save_native_terms boolean
---@field ui BufTermUIConfig
M.options = {
  list_buffers = true,
  save_native_terms = true,
  ui = {
    width = 0.9,
    height = 0.9,
  }
}

M.augroup = vim.api.nvim_create_augroup('BufTerm', {})

---setup bufterm plugin config
---@param opts BufTermConfig
function M.set(opts)
  M.options = vim.tbl_deep_extend('force', M.options, opts)
end

return M
