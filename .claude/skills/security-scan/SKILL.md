---
name: security-scan
description: Run a comprehensive security scan of the project. Checks dependencies for CVEs, reviews security configs, and scans for secrets. Use when asked about security posture or vulnerabilities.
allowed-tools: Read, Grep, Glob, Bash, Agent
---

Perform a comprehensive security scan of this Spring Boot project:

1. **Dependency Audit**: Check `pom.xml` for known vulnerable dependencies
   - Look for SnakeYAML versions < 2.0 (CVE-2022-1471)
   - Check Spring Boot version for known CVEs
   - Run `./mvnw dependency:tree` to see transitive dependencies

2. **Security Configuration Review**:
   - Check if CSRF is disabled in any SecurityFilterChain
   - Check actuator endpoint exposure in application.properties
   - Look for `.permitAll()` on sensitive endpoints
   - Check for hardcoded passwords or API keys

3. **Secret Scanning**:
   - Search for patterns: API keys, passwords, tokens, connection strings
   - Check for .env files that shouldn't be committed
   - Verify .gitignore covers sensitive files

4. **Report**: Output a structured Markdown report with findings, severity, and recommendations.
