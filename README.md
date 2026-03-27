# osv-scanner

Scans a Node.js project's lockfile for known vulnerabilities using [OSV Scanner](https://github.com/google/osv-scanner) via Docker.

## Requirements

- Docker

## Usage

```bash
chmod +x osv-scan.sh
./osv-scan.sh
```

Auto-detects `package-lock.json` or `yarn.lock` in the current directory. You can confirm the detected file or enter a different path.

You can also pass the lockfile directly:

```bash
./osv-scan.sh path/to/package-lock.json
```

## Output

Vulnerability report is printed to stdout by OSV Scanner. Exit code is non-zero if vulnerabilities are found.
