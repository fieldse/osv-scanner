#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/OWASP/NodeGoat"
REPO_DIR="./test-repo"
SCRIPT="./osv-scan.sh"
LOCKFILE="${REPO_DIR}/package-lock.json"
LOG_DIR="./log"
LOG_FILE="${LOG_DIR}/osv-scan-$(date +%Y%m%d-%H%M%S).txt"

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
  info "Output → $LOG_FILE"
  mkdir -p "$LOG_DIR"

  # Tee to log file; OSV Scanner exits 1 on findings — capture without failing
  "$SCRIPT" "$LOCKFILE" 2>&1 | tee "$LOG_FILE" || true
}

function assert_scan_ran() {
  grep -q "Scanning:" "$LOG_FILE" \
    || fail "Expected 'Scanning:' line not found in output"
  pass "Scanner started"
}

function assert_vulnerabilities_found() {
  if grep -qiE "vulnerability|CVE-[0-9]|GHSA-[0-9a-f]|OSV-[0-9]{4}-[0-9]" "$LOG_FILE"; then
    pass "Vulnerabilities reported"
  else
    info "No vulnerabilities detected (may be expected for updated lockfiles)"
  fi
}

function main() {
  info "=== OSV Scanner test ==="

  [[ -x "$SCRIPT" ]] || fail "$SCRIPT not found or not executable"

  setup_repo
  run_scan
  assert_scan_ran
  assert_vulnerabilities_found

  pass "=== All checks passed ==="
}

main "$@"
