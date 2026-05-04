local M = {}

---Validate a lint spec table at runtime, raising on missing/invalid fields.
---@param spec table
---@return lint_test.Spec
function M.validate_spec(spec)
  assert(type(spec.linter) == 'string', 'spec.linter must be a string')
  assert(type(spec.filetype) == 'string', 'spec.filetype must be a string')

  if spec.timeout_ms ~= nil then
    assert(type(spec.timeout_ms) == 'number', 'spec.timeout_ms must be a number')
  end

  assert(type(spec.diagnostics) == 'table', 'spec.diagnostics is required')
  assert(type(spec.diagnostics.file) == 'string', 'spec.diagnostics.file must be a string')
  assert(type(spec.diagnostics.expected) == 'table', 'spec.diagnostics.expected must be a table')
  for i, exp in ipairs(spec.diagnostics.expected) do
    assert(type(exp.line) == 'number', ('spec.diagnostics.expected[%d].line must be a number'):format(i))
    assert(type(exp.pattern) == 'string', ('spec.diagnostics.expected[%d].pattern must be a string'):format(i))
  end

  return spec
end

---Get current time in milliseconds.
---@return integer
function M.now_ms()
  return vim.uv.hrtime() / 1e6
end

---Wait for diagnostics from a specific source to settle.
---@param bufnr integer
---@param source string Linter name to filter diagnostics by
---@param timeout_ms integer
---@param stable_ms? integer How long diagnostics must be unchanged (default 1000)
---@param min_wait_ms? integer Minimum time before accepting 0 diags as settled (default 3000)
---@return vim.Diagnostic[]
function M.wait_for_diagnostics(bufnr, source, timeout_ms, stable_ms, min_wait_ms)
  stable_ms = stable_ms or 1000
  min_wait_ms = min_wait_ms or 3000
  local last_count = -1
  local last_change = M.now_ms()
  local start = M.now_ms()

  vim.wait(timeout_ms, function()
    local diags = vim.diagnostic.get(bufnr)
    local filtered = {}
    for _, d in ipairs(diags) do
      if d.source and d.source:find(source, 1, true) then
        filtered[#filtered + 1] = d
      end
    end
    local count = #filtered
    if count ~= last_count then
      last_count = count
      last_change = M.now_ms()
    end
    local elapsed_since_change = M.now_ms() - last_change
    local elapsed_total = M.now_ms() - start
    if count == 0 and elapsed_total < min_wait_ms then
      return false
    end
    return elapsed_since_change >= stable_ms
  end, 100)

  local diags = vim.diagnostic.get(bufnr)
  local filtered = {}
  for _, d in ipairs(diags) do
    if d.source and d.source:find(source, 1, true) then
      filtered[#filtered + 1] = d
    end
  end
  return filtered
end

return M
