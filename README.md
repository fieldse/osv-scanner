# osv-scanner

Scans a Node.js project's lockfile for known vulnerabilities using [OSV Scanner](https://github.com/google/osv-scanner) via Docker.

## Requirements

- Docker

## Usage

```bash
chmod +x osv-scan.sh
./osv-scan.sh
```

Auto-detects `package-lock.json` or `yarn.lock` in the current directory. Prompts to confirm or override.

Pass a lockfile directly to skip the prompt:

```bash
./osv-scan.sh path/to/package-lock.json
```

## Output

Vulnerability report printed to stdout. Exit code is non-zero if vulnerabilities are found.

## Testing

```bash
chmod +x test.sh
./test.sh
```

Clones [OWASP/NodeGoat](https://github.com/OWASP/NodeGoat) into `./test-repo` (a deliberately vulnerable Node.js app) and runs the scanner against it. Skips the clone if the directory already exists.
