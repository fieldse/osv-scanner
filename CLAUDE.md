# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Run a dependency vulnerability scan on a Node.js project using [OSV Scanner](https://github.com/google/osv-scanner) via Docker.

## How It Works

The `osv-scan.sh` script:
1. Detects a lockfile in the current directory (`package-lock.json` preferred, falls back to `yarn.lock`)
2. Prompts the user to confirm or override the detected lockfile
3. Resolves the absolute path of the lockfile and its parent directory
4. Mounts the lockfile's directory into the `ghcr.io/google/osv-scanner` Docker container as `/src`
5. Runs OSV Scanner and outputs the vulnerability report

## Usage

```bash
chmod +x osv-scan.sh
./osv-scan.sh
```

The script prompts interactively. No arguments needed.

## Key Details

- **Path Resolution**: The script uses the lockfile's directory for Docker mounting, not `$(pwd)` — this ensures it works regardless of where the lockfile lives relative to the working directory.
- **Dependencies**: Docker and Bash are required.
- **Single File**: The entire implementation is in `osv-scan.sh` — no build process, no config.
