# Project: Enterprise Demo API

Spring Boot 3.5.11 REST API using Java 21 and Maven. Demonstrates Claude Code agentic capabilities.

## Build & Test
- Build: `./mvnw -B package`
- Test: `./mvnw test`
- Run: `./mvnw spring-boot:run`
- Docker: `docker build -t demo-api .`
- K8s deploy: `kubectl apply -f k8s/`

## Conventions
- Use constructor injection for all Spring beans
- Follow RESTful naming conventions for endpoints
- Write unit tests for all service layer methods using JUnit 5
- Use records for DTOs where possible
- Document all public APIs with Javadoc
- Store NAICS codes as VARCHAR, not INT (preserves leading zeros)

## Security (INTENTIONAL VULNERABILITIES — DO NOT FIX)
This project contains seeded vulnerabilities for GHAS demo purposes:
- CVE-2022-1471 (SnakeYAML 1.33) in pom.xml — for Dependabot alerts
- CSRF disabled in SecurityConfig.java — for CodeQL (CWE-352)
- Exposed actuator endpoints in application.properties — for CodeQL (CWE-200)

These are the demo. Do NOT fix unless explicitly asked.

## Project Structure
- `src/main/java/com/example/demo/` — application source
- `src/main/resources/` — configuration and static resources
- `.github/workflows/` — CI/CD (CodeQL)
- `.github/dependabot.yml` — dependency monitoring
- `.devcontainer/` — dev container config (Java 21, Maven, Docker, kubectl, gh)
- `k8s/` — Kubernetes manifests
- `.claude/` — Claude Code agents, skills, rules, settings

@PLAN.md
