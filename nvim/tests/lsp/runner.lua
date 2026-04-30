--- LSP Test Runner
--- Invoked headlessly: nvim --headless -u init.lua --cmd "lua FIXTURE_DIR='...'" -l tests/lsp/runner.lua
---
--- Outputs a JSON result line to stdout and exits.

local fixture_dir = _G.FIXTURE_DIR
if not fixture_dir then
  io.stderr:write('ERROR: FIXTURE_DIR not set\n')
  vim.cmd('cquit! 1')
  return
end

-- Ensure fixture_dir has trailing slash
if fixture_dir:sub(-1) ~= '/' then
  fixture_dir = fixture_dir .. '/'
end

-- Add test directory to Lua path so we can require lib
local test_root = fixture_dir:match('(.*/tests/lsp/)') or (fixture_dir .. '../../')
package.path = test_root .. '?.lua;' .. package.path

local lib = require('lib')

-- Load and validate spec
local spec_path = fixture_dir .. 'spec.lua'
local spec_fn, err = loadfile(spec_path)
if not spec_fn then
  io.stdout:write(vim.json.encode({
    server = 'unknown',
    attach_ms = 0,
    attached = false,
    diagnostics = 'skip',
    definition = 'skip',
    errors = { 'Failed to load spec: ' .. err },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

local ok, spec = pcall(spec_fn)
if not ok then
  io.stdout:write(vim.json.encode({
    server = 'unknown',
    attach_ms = 0,
    attached = false,
    diagnostics = 'skip',
    definition = 'skip',
    errors = { 'Spec error: ' .. tostring(spec) },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

local valid_ok, valid_err = pcall(lib.validate_spec, spec)
if not valid_ok then
  io.stdout:write(vim.json.encode({
    server = spec.server or 'unknown',
    attach_ms = 0,
    attached = false,
    diagnostics = 'skip',
    definition = 'skip',
    errors = { 'Validation: ' .. tostring(valid_err) },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

-- Result accumulator
local result = {
  server = spec.server,
  attach_ms = 0,
  attached = false,
  diagnostics = 'skip',
  definition = 'skip',
  errors = {},
}

local timeout = spec.attach_timeout_ms or 15000

-- Determine which file to open first
local initial_file
if spec.diagnostics then
  initial_file = fixture_dir .. spec.diagnostics.file
elseif spec.definition then
  initial_file = fixture_dir .. spec.definition.file
else
  local files = vim.fn.glob(fixture_dir .. '*', false, true)
  for _, f in ipairs(files) do
    if not f:match('spec%.lua$') then
      initial_file = f
      break
    end
  end
end

if not initial_file then
  io.stdout:write(vim.json.encode({
    server = spec.server,
    attach_ms = 0,
    attached = false,
    diagnostics = 'skip',
    definition = 'skip',
    errors = { 'No fixture file found to open' },
  }) .. '\n')
  vim.cmd('qall!')
  return
end

-- Change to fixture dir so root markers are found
vim.cmd('cd ' .. vim.fn.fnameescape(fixture_dir))

-- Open the file and set filetype
vim.cmd('edit ' .. vim.fn.fnameescape(initial_file))
local bufnr = vim.api.nvim_get_current_buf()
vim.bo[bufnr].filetype = spec.filetype

-- Wait for the server to attach
local client, attach_ms = lib.wait_for_attach(spec.server, bufnr, timeout)
result.attach_ms = attach_ms

if not client then
  result.attached = false
  result.errors[#result.errors + 1] = ('Server "%s" did not attach within %dms'):format(spec.server, timeout)
  io.stdout:write(vim.json.encode(result) .. '\n')
  vim.cmd('qall!')
  return
end

result.attached = true

-- === Diagnostics test ===
if spec.diagnostics then
  local diag_file = fixture_dir .. spec.diagnostics.file
  if vim.api.nvim_buf_get_name(bufnr) ~= vim.fn.fnamemodify(diag_file, ':p') then
    vim.cmd('edit ' .. vim.fn.fnameescape(diag_file))
    bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].filetype = spec.filetype
  end

  local diags = lib.wait_for_diagnostics(bufnr, timeout)
  local diag_pass = true

  for _, exp in ipairs(spec.diagnostics.expected) do
    local found = false
    for _, d in ipairs(diags) do
      if (d.lnum + 1) == exp.line and d.message:find(exp.pattern) then
        found = true
        break
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

    local clean_diags = lib.wait_for_diagnostics(clean_bufnr, 5000, 1000)
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
end

-- === Definition test ===
if spec.definition then
  local def_file = fixture_dir .. spec.definition.file
  if vim.api.nvim_buf_get_name(bufnr) ~= vim.fn.fnamemodify(def_file, ':p') then
    vim.cmd('edit ' .. vim.fn.fnameescape(def_file))
    bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].filetype = spec.filetype
  end

  -- Re-acquire client for this buffer
  lib.wait_for_attach(spec.server, bufnr, 5000)
  local clients = vim.lsp.get_clients({ name = spec.server, bufnr = bufnr })
  if #clients > 0 then
    local loc = lib.get_definition(
      clients[1], bufnr,
      spec.definition.cursor[1], spec.definition.cursor[2]
    )

    if not loc then
      result.definition = 'fail'
      result.errors[#result.errors + 1] = 'definition: no result returned'
    else
      local def_pass = true
      if spec.definition.target_file then
        local expected_path = vim.fn.fnamemodify(fixture_dir .. spec.definition.target_file, ':p')
        if loc.file ~= expected_path then
          def_pass = false
          result.errors[#result.errors + 1] = ('definition: expected file %s, got %s'):format(
            expected_path, loc.file)
        end
      end
      if spec.definition.target_line and loc.line ~= spec.definition.target_line then
        def_pass = false
        result.errors[#result.errors + 1] = ('definition: expected line %d, got %d'):format(
          spec.definition.target_line, loc.line)
      end
      result.definition = def_pass and 'pass' or 'fail'
    end
  else
    result.definition = 'fail'
    result.errors[#result.errors + 1] = 'definition: server not attached to definition file'
  end
end

-- Output result
io.stdout:write(vim.json.encode(result) .. '\n')
vim.cmd('qall!')
