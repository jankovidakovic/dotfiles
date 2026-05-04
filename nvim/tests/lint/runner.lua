--- Lint Test Runner
--- Invoked headlessly: nvim --headless -u init.lua --cmd "lua FIXTURE_DIR='...'" -l tests/lint/runner.lua
---
--- Outputs a JSON result line to stdout and exits.

local fixture_dir = _G.FIXTURE_DIR
if not fixture_dir then
  io.stderr:write('ERROR: FIXTURE_DIR not set\n')
  vim.cmd('cquit! 1')
  return
end

if fixture_dir:sub(-1) ~= '/' then
  fixture_dir = fixture_dir .. '/'
end

local test_root = fixture_dir:match('(.*/tests/lint/)') or (fixture_dir .. '../../')
package.path = test_root .. '?.lua;' .. package.path

local lib = require('lib')

-- Load and validate spec
local spec_path = fixture_dir .. 'spec.lua'
local spec_fn, err = loadfile(spec_path)
if not spec_fn then
  io.stdout:write(vim.json.encode({
    linter = 'unknown',
    lint_ms = 0,
    diagnostics = 'skip',
    errors = { 'Failed to load spec: ' .. err },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

local ok, spec = pcall(spec_fn)
if not ok then
  io.stdout:write(vim.json.encode({
    linter = 'unknown',
    lint_ms = 0,
    diagnostics = 'skip',
    errors = { 'Spec error: ' .. tostring(spec) },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

local valid_ok, valid_err = pcall(lib.validate_spec, spec)
if not valid_ok then
  io.stdout:write(vim.json.encode({
    linter = spec.linter or 'unknown',
    lint_ms = 0,
    diagnostics = 'skip',
    errors = { 'Validation: ' .. tostring(valid_err) },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

local result = {
  linter = spec.linter,
  lint_ms = 0,
  diagnostics = 'skip',
  errors = {},
}

local timeout = spec.timeout_ms or 15000

-- Change to fixture dir
vim.cmd('cd ' .. vim.fn.fnameescape(fixture_dir))

-- Open the bad file and set filetype
local diag_file = fixture_dir .. spec.diagnostics.file
vim.cmd('edit ' .. vim.fn.fnameescape(diag_file))
local bufnr = vim.api.nvim_get_current_buf()
vim.bo[bufnr].filetype = spec.filetype

-- Trigger linting
local t0 = lib.now_ms()
require('lint').try_lint()

-- Wait for diagnostics from this linter
local diags = lib.wait_for_diagnostics(bufnr, spec.linter, timeout)
result.lint_ms = math.floor(lib.now_ms() - t0)

local diag_pass = true

for _, exp in ipairs(spec.diagnostics.expected) do
  local found = false
  for _, d in ipairs(diags) do
    if (d.lnum + 1) == exp.line then
      local in_message = d.message and d.message:find(exp.pattern)
      local in_code = d.code and tostring(d.code):find(exp.pattern)
      if in_message or in_code then
        found = true
        break
      end
    end
  end
  if not found then
    diag_pass = false
    result.errors[#result.errors + 1] = ('diagnostics: expected pattern "%s" on line %d, not found'):format(
      exp.pattern, exp.line)
  end
end

-- Check clean file
if spec.diagnostics.clean_file then
  local clean_path = fixture_dir .. spec.diagnostics.clean_file
  vim.cmd('edit ' .. vim.fn.fnameescape(clean_path))
  local clean_bufnr = vim.api.nvim_get_current_buf()
  vim.bo[clean_bufnr].filetype = spec.filetype

  require('lint').try_lint()
  local clean_diags = lib.wait_for_diagnostics(clean_bufnr, spec.linter, 5000, 1000)
  if #clean_diags > 0 then
    diag_pass = false
    local msgs = {}
    for _, d in ipairs(clean_diags) do
      msgs[#msgs + 1] = ('  line %d: %s'):format(d.lnum + 1, d.message)
    end
    result.errors[#result.errors + 1] = 'diagnostics: clean file has diagnostics:\n' .. table.concat(msgs, '\n')
  end
end

result.diagnostics = diag_pass and 'pass' or 'fail'

io.stdout:write(vim.json.encode(result) .. '\n')
vim.cmd('qall!')
