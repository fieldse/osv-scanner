# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Run a dependency vulnerability scan on a Node.js project using [OSV Scanner](https://github.com/google/osv-scanner) via Docker.

## How It Works

`osv-scan.sh`:
1. Detects a lockfile in the current directory (`package-lock.json` preferred, falls back to `yarn.lock`)
2. Prompts the user to confirm or override the detected lockfile (skipped if path passed as argument)
3. Resolves the absolute path of the lockfile and its parent directory
4. Mounts the lockfile's directory into `ghcr.io/google/osv-scanner` as `/src`
5. Runs OSV Scanner and outputs the vulnerability report

## Files

| File | Purpose |
|------|---------|
| `osv-scan.sh` | Main scanner script |
| `test.sh` | Integration test — clones OWASP/NodeGoat and runs the scanner |

## Running

```bash
./osv-scan.sh                          # interactive, auto-detects lockfile
./osv-scan.sh path/to/package-lock.json  # non-interactive
./test.sh                              # run integration test
```

## Key Constraints

- **Path resolution**: Docker volume mount uses the lockfile's directory, not `$(pwd)` — required for lockfiles outside the working directory.
- **No host installs**: Never run `npm install`, `yarn install`, or any Node tooling on the host. All package operations stay inside the Docker container.
- **Dependencies**: Docker and Bash only.
