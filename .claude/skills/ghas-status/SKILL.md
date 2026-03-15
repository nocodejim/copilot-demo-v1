---
name: ghas-status
description: Check GitHub Advanced Security status — Dependabot alerts, CodeQL scan results, and secret scanning. Use when asked about security findings or GHAS status.
allowed-tools: Bash, Read
---

Check the GHAS status for this repository:

## Dependabot Alerts
```bash
gh api repos/{owner}/{repo}/dependabot/alerts --jq '.[] | "\(.security_advisory.severity): \(.security_advisory.summary) [\(.dependency.package.name)]"'
```

## CodeQL Results
```bash
gh api repos/{owner}/{repo}/code-scanning/alerts --jq '.[] | "\(.rule.severity): \(.rule.description) [\(.most_recent_instance.location.path):\(.most_recent_instance.location.start_line)]"'
```

## Secret Scanning
```bash
gh api repos/{owner}/{repo}/secret-scanning/alerts --jq '.[] | "\(.state): \(.secret_type)"'
```

Present results as a summary dashboard.
