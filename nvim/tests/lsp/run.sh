#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
RESULTS_FILE="$SCRIPT_DIR/results.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

if ! command -v nvim &>/dev/null; then
  echo "ERROR: nvim not found in PATH" >&2
  exit 1
fi

echo -e "${BOLD}LSP Test Runner${RESET}"
echo "Config: $NVIM_CONFIG"
echo "Neovim: $(nvim --version | head -1)"
echo ""

results=()
total=0
passed=0
failed=0

# Filter by server name if argument provided
filter="${1:-}"

for fixture_dir in "$FIXTURES_DIR"/*/; do
  server_name="$(basename "$fixture_dir")"

  if [[ -n "$filter" && "$server_name" != "$filter" ]]; then
    continue
  fi

  if [[ ! -f "$fixture_dir/spec.lua" ]]; then
    echo -e "${YELLOW}SKIP${RESET} $server_name (no spec.lua)"
    continue
  fi

  total=$((total + 1))

  output=$(
    XDG_CONFIG_HOME="$(dirname "$NVIM_CONFIG")" \
    nvim --headless \
      -u "$NVIM_CONFIG/init.lua" \
      --cmd "lua _G.FIXTURE_DIR='$fixture_dir'" \
      -l "$SCRIPT_DIR/runner.lua" \
      2>/dev/null || true
  )

  if [[ -z "$output" ]]; then
    echo -e "${RED}FAIL${RESET} $server_name - no output (crashed?)"
    failed=$((failed + 1))
    results+=("{\"server\":\"$server_name\",\"attach_ms\":0,\"attached\":false,\"diagnostics\":\"skip\",\"definition\":\"skip\",\"errors\":[\"no output from runner\"]}")
    continue
  fi

  results+=("$output")

  # Parse result for display
  attached=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['attached'])" 2>/dev/null || echo "false")
  attach_ms=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['attach_ms'])" 2>/dev/null || echo "0")
  diag=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['diagnostics'])" 2>/dev/null || echo "skip")
  defn=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['definition'])" 2>/dev/null || echo "skip")
  errors=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print('\n'.join('    ' + e for e in r['errors']))" 2>/dev/null || echo "")

  server_passed=true
  if [[ "$attached" != "True" ]]; then
    server_passed=false
  fi
  if [[ "$diag" == "fail" || "$defn" == "fail" ]]; then
    server_passed=false
  fi

  fmt_status() {
    case "$1" in
      pass) echo -e "${GREEN}pass${RESET}" ;;
      fail) echo -e "${RED}fail${RESET}" ;;
      skip) echo -e "${YELLOW}skip${RESET}" ;;
      *) echo "$1" ;;
    esac
  }

  if [[ "$server_passed" == "true" ]]; then
    passed=$((passed + 1))
    echo -e "${GREEN}PASS${RESET} $server_name  attach=${attach_ms}ms  diag=$(fmt_status "$diag")  defn=$(fmt_status "$defn")"
  else
    failed=$((failed + 1))
    echo -e "${RED}FAIL${RESET} $server_name  attach=${attach_ms}ms  diag=$(fmt_status "$diag")  defn=$(fmt_status "$defn")"
    if [[ -n "$errors" ]]; then
      echo -e "$errors"
    fi
  fi
done

echo ""
echo -e "${BOLD}Results: ${passed}/${total} passed, ${failed} failed${RESET}"

# Write JSON results
echo "[" > "$RESULTS_FILE"
for i in "${!results[@]}"; do
  if [[ $i -gt 0 ]]; then
    echo "," >> "$RESULTS_FILE"
  fi
  echo "  ${results[$i]}" >> "$RESULTS_FILE"
done
echo "]" >> "$RESULTS_FILE"

echo "Results written to: $RESULTS_FILE"

if [[ $failed -gt 0 ]]; then
  exit 1
fi
