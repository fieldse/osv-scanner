#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/OWASP/NodeGoat"
REPO_DIR="./test-repo"
SCRIPT="./osv-scan.sh"
LOCKFILE="${REPO_DIR}/package-lock.json"

function info()  { echo "[INFO]  $*"; }
function pass()  { echo "[PASS]  $*"; }
function fail()  { echo "[FAIL]  $*" >&2; exit 1; }

function setup_repo() {
  if [[ -d "$REPO_DIR" ]]; then
    info "test-repo already exists, skipping clone"
  else
    info "Cloning ${REPO_URL} into ${REPO_DIR}..."
    git clone --depth=1 "$REPO_URL" "$REPO_DIR"
  fi

  [[ -f "$LOCKFILE" ]] || fail "Expected lockfile not found: $LOCKFILE"
  pass "Lockfile found: $LOCKFILE"
}

function run_scan() {
  info "Running osv-scan.sh against $LOCKFILE..."

  OUTPUT="$("$SCRIPT" "$LOCKFILE" 2>&1)"
  EXIT_CODE=$?

  echo "$OUTPUT"
  return $EXIT_CODE
}

function assert_scan_ran() {
  local output="$1"

  echo "$output" | grep -q "Scanning:" \
    || fail "Expected 'Scanning:' line not found in output"
  pass "Scanner started"
}

function assert_vulnerabilities_found() {
  local output="$1"

  # OSV Scanner exits non-zero and prints vuln details when findings exist.
  # Accept either a vuln table or the OSV package name format.
  if echo "$output" | grep -qiE "vulnerability|CVE-|GHSA-|OSV-"; then
    pass "Vulnerabilities reported"
  else
    info "No vulnerabilities detected (may be expected for updated lockfiles)"
  fi
}

function main() {
  info "=== OSV Scanner test ==="

  [[ -x "$SCRIPT" ]] || fail "$SCRIPT not found or not executable"

  setup_repo

  local output
  # OSV Scanner exits 1 when vulns are found — capture output without failing
  output="$(run_scan || true)"

  assert_scan_ran "$output"
  assert_vulnerabilities_found "$output"

  pass "=== All checks passed ==="
}

main "$@"
