# Claude Code Enterprise Demo Runbook

**Adapted from GitHub Copilot CLI demo plan for Claude Code.**
**Every section maps the original Copilot CLI concept to its Claude Code equivalent.**

---

## Overview

This demo showcases Claude Code's agentic capabilities in an enterprise-grade Spring Boot project. The original plan targeted GitHub Copilot CLI with corporate tooling (JFrog, Dynatrace, fleet mode). This adaptation:

- **Removes**: JFrog artifact management, Dynatrace APM (not available at home)
- **Replaces**: Copilot CLI customization with Claude Code equivalents
- **Keeps**: Spring Boot scaffolding, GHAS (CodeQL + Dependabot), NAICS data, security demos
- **Adds**: Local Kubernetes deployment, Claude Code agent teams (fleet equivalent)
- **Repo**: Public on GitHub (GHAS requires public repo, no sensitive info)

---

## Feature Translation: Copilot CLI → Claude Code

| Copilot CLI Feature | Claude Code Equivalent | Advantage |
|---|---|---|
| `copilot-instructions.md` | `CLAUDE.md` + `.claude/rules/*.md` | Path-specific rules, file imports via `@`, directory-scoped loading |
| `.github/agents/*.agent.md` | `.claude/agents/` with YAML frontmatter | Tool restrictions, permission modes, persistent memory, worktree isolation |
| `.github/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` | Dynamic context injection (`!command`), subagent execution, model override |
| `/fleet` (parallel subagents) | Agent teams + `--worktree` + background agents | True git isolation per agent, shared task lists, peer-to-peer messaging |
| Plan mode (`Shift+Tab`) | Plan mode (`Shift+Tab` / `--permission-mode plan`) | Identical UX, read-only exploration before implementation |
| `/tasks` monitoring | `Ctrl+T` task list + `TaskCreate`/`TaskUpdate` | Integrated task tracking with dependency management |
| Copilot integrations | MCP servers (`.mcp.json`) | Standardized protocol, OAuth support, 100+ community servers |
| copilot.json config | `.claude/settings.json` | Granular tool-level permissions with glob patterns |

---

## Phase 0: Environment Setup (Dev Container)

> **Design decision:** Java, Maven, and build tools live inside a dev container — not on the host WSL2 system. This keeps the dev box clean and makes the environment reproducible for anyone cloning the repo.

### 0.1 Dev Container Configuration

File: `.devcontainer/devcontainer.json`

**Base image:** `mcr.microsoft.com/devcontainers/java:21-bookworm` — ships with Java 21 (MS OpenJDK) and Maven pre-installed.

**Features included:**
| Feature | Purpose |
|---|---|
| `docker-outside-of-docker` | Build Docker images from inside the container (shares host Docker socket) |
| `kubectl-helm-minikube` | kubectl + Helm for K8s deployment |
| `github-cli` | `gh` CLI for repo creation, GHAS queries, PR management |
| `node` | Node.js LTS for any tooling that needs it (devcontainer CLI, etc.) |

**VS Code extensions auto-installed:**
- Java Extension Pack + Spring Boot Extension Pack
- YAML support + Kubernetes tools

**Port forwarding:** 8080 (Spring Boot default)

**Post-create verification:** `java -version && mvn -version && gh --version && kubectl version --client`

### 0.2 Workflow: How Claude Code + Dev Container Interact

```
┌──────────────────────────────────────────────────┐
│  Host (WSL2)                                     │
│  ┌────────────────────────────────────────────┐  │
│  │  VS Code + Dev Containers extension        │  │
│  │  ┌──────────────────────────────────────┐  │  │
│  │  │  Dev Container (Java 21 + Maven)     │  │  │
│  │  │  ┌────────────────────────────────┐  │  │  │
│  │  │  │  Claude Code (runs in terminal)│  │  │  │
│  │  │  │  → mvn, java, docker, kubectl  │  │  │  │
│  │  │  │  → gh CLI (shared auth)        │  │  │  │
│  │  │  └────────────────────────────────┘  │  │  │
│  │  │  Docker socket → host Docker daemon  │  │  │
│  │  │  kubectl → host K8s cluster          │  │  │
│  │  └──────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

**Steps:**
1. Open project in VS Code on WSL2
2. "Reopen in Container" (or `Ctrl+Shift+P` → Dev Containers: Reopen in Container)
3. VS Code rebuilds container with Java 21, Maven, gh, kubectl
4. Open integrated terminal → Claude Code runs inside the container
5. All `Bash` tool calls (mvn, docker, kubectl) execute inside the container
6. Docker socket is shared — `docker build` uses host daemon
7. kubectl reaches host K8s cluster (kubeconfig mounted)
8. gh CLI auth is shared from host (via credential forwarding)

### 0.3 Create Public GitHub Repository

Run from inside the dev container terminal (or host — `gh` is available on both):

```bash
cd /home/jim/projects/copilot-demo-v1
git init
gh repo create nocodejim/copilot-demo-v1 --public --source=. --push \
  --description "Enterprise demo: Claude Code agentic capabilities with Spring Boot, GHAS, and Kubernetes"
```

> **Why public?** GHAS (CodeQL, Dependabot alerts, secret scanning) is free and automatic on public repos. No sensitive info — the app is a demo vehicle.

### 0.4 Verify Dev Container (post-create)

The `postCreateCommand` runs automatically and confirms:
```
openjdk version "21.0.x" ...
Apache Maven 3.9.x ...
gh version 2.x.x ...
Client Version: v1.x.x ...
```

If any tool is missing, the container build failed — check Docker logs.

---

## Phase 1: Spring Boot Project Scaffolding

### 1.1 Generate from Spring Initializr

```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d bootVersion=3.5.11 \
  -d groupId=com.example \
  -d artifactId=demo \
  -d name=demo \
  -d description="Demo REST API project" \
  -d packageName=com.example.demo \
  -d packaging=jar \
  -d javaVersion=21 \
  -d dependencies=web,actuator,security,data-jpa,h2 \
  -o demo.zip
unzip demo.zip -d .
rm demo.zip
```

### 1.2 Seed CVE-2022-1471 (SnakeYAML)

Add to `pom.xml` — CVSS 9.8 CRITICAL, Dependabot will auto-flag:

```xml
<!-- INTENTIONALLY VULNERABLE — for GHAS/Dependabot demo -->
<dependency>
    <groupId>org.yaml</groupId>
    <artifactId>snakeyaml</artifactId>
    <version>1.33</version>
</dependency>
```

### 1.3 Add Security Misconfigurations (for CodeQL)

**SecurityConfig.java** — CSRF disabled (CWE-352, severity 8.8):

```java
@EnableWebSecurity
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // CodeQL: java/spring-disabled-csrf-protection
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
```

**application.properties** — exposed actuators (CWE-200, severity 6.5):

```properties
management.endpoints.web.exposure.include=*
```

---

## Phase 2: GHAS Configuration

### 2.1 CodeQL Workflow

File: `.github/workflows/codeql.yml` — unchanged from original plan. Uses `github/codeql-action@v4` with `java-kotlin` language, `autobuild` mode.

### 2.2 Dependabot

File: `.github/dependabot.yml` — unchanged. Monitors `maven` and `github-actions` ecosystems.

---

## Phase 3: Claude Code Configuration (THE DEMO STAR)

This is where we diverge from Copilot CLI and showcase Claude Code's superior customization.

### 3.1 CLAUDE.md (replaces copilot-instructions.md)

File: `CLAUDE.md` at project root.

Claude Code's CLAUDE.md is more powerful than copilot-instructions.md:
- **File imports**: `@docs/api-guide.md` pulls in referenced files
- **Directory scoping**: Subdirectory CLAUDE.md files load on-demand
- **Ancestor walking**: Walks up directory tree, loading all CLAUDE.md files found
- **No frontmatter needed**: Plain Markdown

```markdown
# Project: Enterprise Demo API

Spring Boot 3.5.11 REST API using Java 21 and Maven. Demonstrates Claude Code agentic capabilities.

## Build & Test
- Build: `mvn -B package`
- Test: `mvn test`
- Run: `mvn spring-boot:run`
- Docker: `docker build -t demo-api .`
- K8s deploy: `kubectl apply -f k8s/`

## Conventions
- Use constructor injection for all Spring beans
- Follow RESTful naming conventions for endpoints
- Write unit tests for all service layer methods using JUnit 5
- Use records for DTOs where possible
- Document all public APIs with Javadoc
- Store NAICS codes as VARCHAR, not INT (preserves leading zeros)

## Security
- This project contains INTENTIONAL vulnerabilities for GHAS demo purposes
- CVE-2022-1471 (SnakeYAML 1.33) — seeded for Dependabot
- CSRF disabled in SecurityConfig — seeded for CodeQL
- Exposed actuators — seeded for CodeQL
- DO NOT fix these unless explicitly asked — they ARE the demo

@docs/architecture.md
```

### 3.2 Path-Specific Rules (replaces .github/instructions/*.instructions.md)

Copilot CLI uses `.github/instructions/**/*.instructions.md` with `applyTo` frontmatter.
Claude Code uses `.claude/rules/*.md` with `paths` frontmatter — more flexible.

File: `.claude/rules/java-conventions.md`

```markdown
---
name: Java Conventions
description: Java 21 coding standards for all Java source files
paths:
  - "**/*.java"
---

- Use Java 21 features: records, sealed classes, pattern matching, virtual threads where appropriate
- Follow Google Java Style Guide
- Always use constructor injection over field injection for Spring beans
- Write Javadoc for all public methods
- Prefer `var` for local variables when type is obvious from RHS
```

File: `.claude/rules/test-conventions.md`

```markdown
---
name: Test Conventions
description: Testing standards for JUnit 5 test files
paths:
  - "src/test/**/*.java"
---

- Use JUnit 5 with AssertJ assertions
- Follow Arrange-Act-Assert pattern
- Use @DisplayName for readable test names
- Mock external dependencies, not internal classes
- Integration tests use @SpringBootTest
```

### 3.3 Custom Agents (replaces .github/agents/*.agent.md)

Claude Code agents are more powerful than Copilot agents:
- **Tool restrictions**: Limit what tools agents can use
- **Permission modes**: Plan-only agents for safe exploration
- **Persistent memory**: Agents learn across sessions
- **Worktree isolation**: Each agent gets its own git branch
- **Model override**: Use cheaper models for simple tasks

#### Agent: Security Reviewer

File: `.claude/agents/security-reviewer/AGENT.md`

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities, OWASP Top 10, Spring Security misconfigs, and dependency CVEs. Use when asked to review security posture.
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
model: sonnet
permissionMode: plan
---

You are a security-focused code reviewer for a Spring Boot 3.x application.

## Responsibilities
- Analyze code for OWASP Top 10 vulnerabilities
- Check Spring Security configurations for misconfigurations
- Identify hardcoded secrets, SQL injection risks, and XSS vectors
- Review dependency versions against known CVE databases
- Check actuator endpoint exposure
- Verify CSRF protection is properly configured

## Output Format
Produce findings as a Markdown report with:
- **Finding**: Description of the issue
- **Severity**: Critical / High / Medium / Low
- **Location**: File and line number
- **CWE**: Applicable CWE identifier
- **Recommendation**: How to fix

Never modify code directly. Read-only analysis only.
```

#### Agent: K8s Deployer

File: `.claude/agents/k8s-deployer/AGENT.md`

```markdown
---
name: k8s-deployer
description: Manages Kubernetes deployments, troubleshoots pod issues, and validates manifests. Use when working with K8s resources.
tools: Read, Bash, Grep, Glob
disallowedTools: Write, Edit
model: sonnet
---

You are a Kubernetes operations specialist.

## Responsibilities
- Validate K8s manifests for best practices
- Deploy applications to local cluster
- Troubleshoot pod failures (CrashLoopBackOff, ImagePullBackOff, etc.)
- Check resource limits, health probes, and security contexts
- Monitor deployment rollout status

## Available Commands
- `kubectl apply -f k8s/` — deploy manifests
- `kubectl get pods -w` — watch pod status
- `kubectl logs <pod>` — view logs
- `kubectl describe pod <pod>` — detailed pod info
- `docker build -t demo-api .` — build image

Never modify source code. Only execute kubectl and docker commands.
```

#### Agent: Test Writer

File: `.claude/agents/test-writer/AGENT.md`

```markdown
---
name: test-writer
description: Writes comprehensive JUnit 5 tests for Java classes. Use when asked to add tests, improve coverage, or write unit/integration tests.
tools: Read, Write, Edit, Grep, Glob, Bash
model: sonnet
isolation: worktree
---

You are a test engineering specialist for Spring Boot applications.

## Responsibilities
- Write unit tests using JUnit 5 + Mockito
- Write integration tests using @SpringBootTest
- Use AssertJ for fluent assertions
- Follow Arrange-Act-Assert pattern
- Use @DisplayName for readable test descriptions
- Achieve high branch coverage

## Conventions
- Test class naming: `{ClassName}Test.java`
- Test method naming: `should{ExpectedBehavior}_when{Condition}`
- Place tests in matching package under `src/test/java/`
- Use constructor injection in test configs

Run `mvn test` after writing tests to verify they pass.
```

### 3.4 Custom Skills (replaces .github/skills/*/SKILL.md)

Claude Code skills are functionally equivalent to Copilot skills but with extras:
- **Dynamic context**: `!command` injects live output into skill context
- **Subagent execution**: `context: fork` runs in isolated agent
- **Model override**: Use cheaper models for simple skills

#### Skill: Security Scan

File: `.claude/skills/security-scan/SKILL.md`

```markdown
---
name: security-scan
description: Run a comprehensive security scan of the project. Checks dependencies for CVEs, reviews security configs, and scans for secrets. Use when asked about security posture or vulnerabilities.
allowed-tools: Read, Grep, Glob, Bash, Agent
---

Perform a comprehensive security scan of this Spring Boot project:

1. **Dependency Audit**: Check `pom.xml` for known vulnerable dependencies
   - Look for SnakeYAML versions < 2.0 (CVE-2022-1471)
   - Check Spring Boot version for known CVEs
   - Run `mvn dependency:tree` to see transitive dependencies

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
```

#### Skill: Deploy Local

File: `.claude/skills/deploy-local/SKILL.md`

```markdown
---
name: deploy-local
description: Build and deploy the application to local Kubernetes. Use when asked to deploy, build Docker image, or manage K8s resources.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

Build and deploy the demo application to local Kubernetes:

## Steps

1. **Build the application**:
   ```bash
   mvn -B package -DskipTests
   ```

2. **Build Docker image**:
   ```bash
   docker build -t demo-api:latest .
   ```

3. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f k8s/
   kubectl rollout status deployment/demo-api --timeout=120s
   ```

4. **Verify**:
   ```bash
   kubectl get pods -l app=demo-api
   kubectl port-forward svc/demo-api 8080:8080 &
   curl -s http://localhost:8080/actuator/health | jq .
   ```

5. **Show status**:
   - `kubectl get all -l app=demo-api`
   - Application URL: http://localhost:8080
```

#### Skill: GHAS Status

File: `.claude/skills/ghas-status/SKILL.md`

```markdown
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
```

### 3.5 Project Settings

File: `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(mvn *)",
      "Bash(docker *)",
      "Bash(kubectl *)",
      "Bash(gh *)",
      "Bash(curl *)",
      "Bash(git *)",
      "Read",
      "Glob",
      "Grep"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'File modified — consider running mvn test'"
          }
        ]
      }
    ]
  }
}
```

### 3.6 Hooks for Automation

Hooks in `.claude/settings.json` provide event-driven automation that Copilot CLI doesn't have:

| Hook | Purpose | Demo Value |
|---|---|---|
| `PostToolUse` (Edit/Write) | Remind to run tests after edits | Shows CI-like feedback loop |
| `PreToolUse` (Bash) | Block destructive commands | Shows guardrails |
| `Stop` | Auto-format or summarize | Shows post-response automation |
| `SubagentStart/Stop` | Log agent activity | Shows observability |

---

## Phase 4: "Fleet Mode" — Agent Teams + Worktrees

This is the marquee translation. Copilot CLI's `/fleet` decomposes prompts into parallel subtasks. Claude Code achieves the same — and more — through three mechanisms:

### 4.1 Agent Teams (Direct Fleet Equivalent)

```bash
# Enable experimental agent teams
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude
```

Then in session:
```
Create an agent team with these roles:
1. security-reviewer: Audit all Java source files for OWASP Top 10
2. test-writer: Write unit tests for all service classes
3. k8s-validator: Validate Kubernetes manifests against best practices

Each teammate works in parallel. Report findings when done.
```

**What the audience sees**: Multiple Claude agents working simultaneously, each with their own context, coordinating through a shared task list. This is `/fleet` but with persistent identity, memory, and peer communication.

### 4.2 Worktree Isolation (Parallel Feature Branches)

```bash
# Start isolated sessions for parallel feature work
claude --worktree add-naics-api      # Branch: worktree-add-naics-api
claude --worktree add-health-checks  # Branch: worktree-add-health-checks
claude --worktree add-tests          # Branch: worktree-add-tests
```

Each session gets its own git branch and working directory. No file conflicts. Merge when ready.

### 4.3 Background Agents

During a session, press `Ctrl+B` to background a long-running task, or configure agents with `background: true`:

```
# In Claude Code session:
> Run the security-scan skill in the background while I work on the API

# Claude backgrounds the scan, you continue working
# Notification appears when scan completes
```

### 4.4 Demo Script: Fleet-Equivalent Parallel Execution

```
Step 1: Show CLAUDE.md and explain project context loading
Step 2: "Create an agent team to parallelize: security review, test writing, and K8s validation"
Step 3: Watch 3 agents spin up and work simultaneously
Step 4: Show shared task list (Ctrl+T) with live progress
Step 5: Agents report findings independently
Step 6: Lead agent synthesizes all results

Talking point: "This is like /fleet, but each agent has persistent memory,
can message each other, and works in git-isolated worktrees. It's fleet
mode with enterprise-grade coordination."
```

---

## Phase 5: NAICS Data Integration

Unchanged from original — download Census Bureau 2022 NAICS data, create JPA entity with VARCHAR codes, load via `data.sql`.

Key files:
- `src/main/java/com/example/demo/model/NaicsCode.java` — JPA entity
- `src/main/java/com/example/demo/repository/NaicsCodeRepository.java`
- `src/main/java/com/example/demo/controller/NaicsController.java` — REST API
- `src/main/resources/data.sql` — seed data

---

## Phase 6: Local Kubernetes Deployment

### 6.1 Dockerfile (multi-stage)

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src src
RUN apk add --no-cache maven && mvn -B package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 6.2 Kubernetes Manifests

```
k8s/
├── deployment.yaml
├── service.yaml
└── ingress.yaml (optional)
```

### 6.3 Deploy

```bash
docker build -t demo-api:latest .
kubectl apply -f k8s/
kubectl rollout status deployment/demo-api
```

---

## Phase 7: Demo Walkthrough

### Scene 1: Project Understanding (2 min)
- Show `CLAUDE.md` — Claude Code understands the project
- Show `.claude/rules/` — path-specific conventions load automatically
- "Unlike copilot-instructions.md, CLAUDE.md supports file imports and directory scoping"

### Scene 2: Custom Agents in Action (3 min)
- Invoke security-reviewer agent: "Review the security posture"
- Agent finds CSRF disabled, exposed actuators, SnakeYAML CVE
- "These agents have tool restrictions — security-reviewer can't modify code, only read"

### Scene 3: Skills for Common Workflows (2 min)
- Run `/security-scan` skill
- Run `/deploy-local` skill
- "Skills are progressive — Claude only loads them when relevant, saving context"

### Scene 4: Fleet Mode Equivalent (5 min) — THE HEADLINER
- Enable agent teams
- "Write tests for all services, review security, and validate K8s manifests — in parallel"
- Show 3 agents working simultaneously
- Show task list coordination
- "This is /fleet but with persistent memory, peer messaging, and git isolation"

### Scene 5: GHAS Integration (3 min)
- Show Dependabot alert for CVE-2022-1471
- Show CodeQL findings (CSRF, actuators)
- "Claude Code + GHAS = AI-assisted security remediation"

### Scene 6: Kubernetes Deployment (2 min)
- Run `/deploy-local`
- Show pods running, health check passing
- "From code to cluster in one command"

### Key Talking Points

| Topic | Message |
|---|---|
| **vs. Copilot CLI** | "Same capabilities, different architecture. Claude Code uses CLAUDE.md instead of copilot-instructions.md, .claude/agents/ instead of .github/agents/, and agent teams instead of /fleet." |
| **Agent teams** | "Fleet mode dispatches anonymous subagents. Agent teams give each agent identity, memory, and the ability to message each other. It's fleet mode grown up." |
| **Security** | "Tool restrictions mean the security reviewer literally cannot modify code. Permission modes enforce read-only exploration. This is enterprise-grade guardrails." |
| **Extensibility** | "MCP servers give Claude Code access to any tool with a standard interface — databases, APIs, monitoring. No custom integration code." |
| **Local-first** | "Everything runs locally. Your code stays on your machine. CLAUDE.md, agents, skills — all version-controlled in your repo." |

---

## Tools NOT in This Demo (Removed from Original)

| Original Tool | Why Removed | Alternative |
|---|---|---|
| JFrog Artifactory | Not available at home | Maven Central (default) |
| Dynatrace | Not available at home | kubectl logs + actuator endpoints |
| Corporate K8s | Not available at home | Local Kubernetes (Docker Desktop / k3s / kind) |
| Corporate GitHub org | Demo requires public repo | Personal GitHub (`nocodejim`) |

---

## Execution Order

```
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 5 → Phase 6 → Phase 4 → Phase 7
                                                                  ↑
                                                    (needs working app for demo)
```

Phase 4 (fleet demo) and Phase 7 (demo script) come last because they need a working application to demonstrate against.
