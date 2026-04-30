local M = {}

---Validate a spec table at runtime, raising on missing/invalid fields.
---@param spec table
---@return lsp_test.Spec
function M.validate_spec(spec)
  assert(type(spec.server) == 'string', 'spec.server must be a string')
  assert(type(spec.filetype) == 'string', 'spec.filetype must be a string')

  if spec.attach_timeout_ms ~= nil then
    assert(type(spec.attach_timeout_ms) == 'number', 'spec.attach_timeout_ms must be a number')
  end

  if spec.diagnostics then
    assert(type(spec.diagnostics.file) == 'string', 'spec.diagnostics.file must be a string')
    assert(type(spec.diagnostics.expected) == 'table', 'spec.diagnostics.expected must be a table')
    for i, exp in ipairs(spec.diagnostics.expected) do
      assert(type(exp.line) == 'number', ('spec.diagnostics.expected[%d].line must be a number'):format(i))
      assert(type(exp.pattern) == 'string', ('spec.diagnostics.expected[%d].pattern must be a string'):format(i))
    end
  end

  if spec.definition then
    assert(type(spec.definition.file) == 'string', 'spec.definition.file must be a string')
    assert(type(spec.definition.cursor) == 'table' and #spec.definition.cursor == 2,
      'spec.definition.cursor must be {line, col}')
  end

  return spec
end

---Get current time in milliseconds.
---@return integer
function M.now_ms()
  return vim.uv.hrtime() / 1e6
end

---Wait for an LSP client with the given name to attach to a buffer.
---@param server_name string
---@param bufnr integer
---@param timeout_ms integer
---@return vim.lsp.Client|nil client
---@return integer elapsed_ms
function M.wait_for_attach(server_name, bufnr, timeout_ms)
  local t0 = M.now_ms()
  local attached = vim.wait(timeout_ms, function()
    local clients = vim.lsp.get_clients({ name = server_name, bufnr = bufnr })
    return #clients > 0
  end, 50)

  local elapsed = math.floor(M.now_ms() - t0)

  if not attached then
    return nil, elapsed
  end

  local clients = vim.lsp.get_clients({ name = server_name, bufnr = bufnr })
  return clients[1], elapsed
end

---Wait for diagnostics to settle (unchanged for `stable_ms`).
---Won't consider "settled" at 0 diagnostics until at least `min_wait_ms` has passed,
---to handle slow servers that haven't published results yet.
---@param bufnr integer
---@param timeout_ms integer
---@param stable_ms? integer How long diagnostics must be unchanged (default 1000)
---@param min_wait_ms? integer Minimum time to wait before accepting 0 diags as settled (default 3000)
---@return vim.Diagnostic[]
function M.wait_for_diagnostics(bufnr, timeout_ms, stable_ms, min_wait_ms)
  stable_ms = stable_ms or 1000
  min_wait_ms = min_wait_ms or 3000
  local last_count = -1
  local last_change = M.now_ms()
  local start = M.now_ms()

  vim.wait(timeout_ms, function()
    local diags = vim.diagnostic.get(bufnr)
    local count = #diags
    if count ~= last_count then
      last_count = count
      last_change = M.now_ms()
    end
    local elapsed_since_change = M.now_ms() - last_change
    local elapsed_total = M.now_ms() - start
    -- Don't settle on 0 diagnostics until min_wait_ms has passed
    if count == 0 and elapsed_total < min_wait_ms then
      return false
    end
    return elapsed_since_change >= stable_ms
  end, 100)

  return vim.diagnostic.get(bufnr)
end

---Request definition synchronously at cursor position.
---@param client vim.lsp.Client
---@param bufnr integer
---@param line integer 1-indexed
---@param col integer 1-indexed
---@param timeout_ms? integer
---@return {file: string, line: integer}|nil
function M.get_definition(client, bufnr, line, col, timeout_ms)
  timeout_ms = timeout_ms or 5000

  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = line - 1, character = col - 1 },
  }

  local result = client:request_sync('textDocument/definition', params, timeout_ms, bufnr)
  if not result or result.err or not result.result then
    return nil
  end

  local locations = result.result
  -- Can be a single Location or Location[]
  if locations.uri then
    locations = { locations }
  end

  if #locations == 0 then
    return nil
  end

  local loc = locations[1]
  local uri = loc.uri or loc.targetUri
  local range = loc.range or loc.targetSelectionRange or loc.targetRange

  return {
    file = vim.uri_to_fname(uri),
    line = range.start.line + 1,
  }
end

return M
