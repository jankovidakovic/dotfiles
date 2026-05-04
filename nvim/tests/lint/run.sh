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

echo -e "${BOLD}Lint Test Runner${RESET}"
echo "Config: $NVIM_CONFIG"
echo "Neovim: $(nvim --version | head -1)"
echo ""

results=()
total=0
passed=0
failed=0

# Filter by linter name if argument provided
filter="${1:-}"

for fixture_dir in "$FIXTURES_DIR"/*/; do
  linter_name="$(basename "$fixture_dir")"

  if [[ -n "$filter" && "$linter_name" != "$filter" ]]; then
    continue
  fi

  if [[ ! -f "$fixture_dir/spec.lua" ]]; then
    echo -e "${YELLOW}SKIP${RESET} $linter_name (no spec.lua)"
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
    echo -e "${RED}FAIL${RESET} $linter_name - no output (crashed?)"
    failed=$((failed + 1))
    results+=("{\"linter\":\"$linter_name\",\"lint_ms\":0,\"diagnostics\":\"skip\",\"errors\":[\"no output from runner\"]}")
    continue
  fi

  results+=("$output")

  # Parse result for display
  lint_ms=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['lint_ms'])" 2>/dev/null || echo "0")
  diag=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r['diagnostics'])" 2>/dev/null || echo "skip")
  errors=$(echo "$output" | python3 -c "import sys,json; r=json.load(sys.stdin); print('\n'.join('    ' + e for e in r['errors']))" 2>/dev/null || echo "")

  linter_passed=true
  if [[ "$diag" == "fail" ]]; then
    linter_passed=false
  fi

  fmt_status() {
    case "$1" in
      pass) echo -e "${GREEN}pass${RESET}" ;;
      fail) echo -e "${RED}fail${RESET}" ;;
      skip) echo -e "${YELLOW}skip${RESET}" ;;
      *) echo "$1" ;;
    esac
  }

  if [[ "$linter_passed" == "true" ]]; then
    passed=$((passed + 1))
    echo -e "${GREEN}PASS${RESET} $linter_name  lint=${lint_ms}ms  diag=$(fmt_status "$diag")"
  else
    failed=$((failed + 1))
    echo -e "${RED}FAIL${RESET} $linter_name  lint=${lint_ms}ms  diag=$(fmt_status "$diag")"
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
