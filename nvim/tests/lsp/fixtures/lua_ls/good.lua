local M = {}

local function helper(x)
  table.insert(M, x)
  return x + 1
end

helper(42)

return M
