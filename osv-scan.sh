#!/usr/bin/env bash

set -euo pipefail

OSV_IMAGE="ghcr.io/google/osv-scanner"

function usage() {
  echo "Usage: $(basename "$0") [lockfile]"
  echo "  Scans a Node.js lockfile for known vulnerabilities using OSV Scanner."
  echo "  If no lockfile is given, auto-detects package-lock.json or yarn.lock."
}

# Returns the first lockfile found in the current directory, or empty string.
function detect_lockfile() {
  for f in package-lock.json yarn.lock; do
    [[ -f "$f" ]] && echo "$f" && return
  done
}

# Prompts the user to confirm or override the detected lockfile path.
function prompt_lockfile() {
  local default="$1"
  local input

  if [[ -n "$default" ]]; then
    read -rp "Lockfile to scan [${default}]: " input
    echo "${input:-$default}"
  else
    read -rp "Lockfile to scan: " input
    echo "$input"
  fi
}

function run_scan() {
  local lockfile="$1"
  local abs dir name

  abs="$(cd "$(dirname "$lockfile")" && pwd)/$(basename "$lockfile")"
  dir="$(dirname "$abs")"
  name="$(basename "$abs")"

  echo "Scanning: $abs"

  docker run --rm \
    -v "${dir}":/src \
    "$OSV_IMAGE" \
    --lockfile "/src/${name}"
}

function main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage; exit 0
  fi

  local lockfile="${1:-}"

  if [[ -z "$lockfile" ]]; then
    lockfile="$(prompt_lockfile "$(detect_lockfile)")"
  fi

  [[ -z "$lockfile" ]] && { echo "Error: no lockfile specified." >&2; exit 1; }
  [[ ! -f "$lockfile" ]] && { echo "Error: '$lockfile' not found." >&2; exit 1; }

  run_scan "$lockfile"
}

main "$@"
