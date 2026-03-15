# Claude Code Enterprise Demo — Walkthrough Script

**Duration:** ~15 minutes
**Audience:** Enterprise teams evaluating AI-assisted development tools
**Prerequisites:** Dev container running, GitHub repo created, GHAS active

---

## Pre-Demo Checklist

- [ ] Dev container is built and running (`java -version` returns 21)
- [ ] GitHub repo is public and GHAS is active
- [ ] CodeQL has run at least once (push to main triggers it)
- [ ] Dependabot has flagged CVE-2022-1471
- [ ] Application builds successfully (`./mvnw -B package`)
- [ ] Claude Code is running inside the dev container terminal

---

## Scene 1: Project Understanding (2 min)

**Goal:** Show how Claude Code understands your project through CLAUDE.md

### Script

> "First, let me show you how Claude Code understands our project.
> Every repo has a CLAUDE.md at the root — think of it as copilot-instructions.md
> but more powerful."

**Show:** Open `CLAUDE.md` — point out build commands, conventions, and the `@PLAN.md` import.

> "Notice the `@PLAN.md` reference. Claude Code supports file imports —
> it pulls in referenced documents automatically. No copy-pasting context."

**Show:** Open `.claude/rules/java-conventions.md` — point out the `paths` frontmatter.

> "Path-specific rules load automatically when Claude touches matching files.
> Java conventions apply to *.java, test conventions only to src/test/.
> Copilot uses separate .instructions.md files — Claude Code integrates
> this directly into the rules system."

### Key Comparison
| Feature | Copilot CLI | Claude Code |
|---|---|---|
| Project instructions | `copilot-instructions.md` | `CLAUDE.md` with `@` imports |
| Path-specific rules | `.github/instructions/*.instructions.md` | `.claude/rules/*.md` with `paths` |

---

## Scene 2: Custom Agents (3 min)

**Goal:** Show read-only security review with tool restrictions

### Script

> "We've defined three custom agents. Let me show the security reviewer."

**Show:** Open `.claude/agents/security-reviewer/AGENT.md`

> "Notice the frontmatter: `disallowedTools: Write, Edit` and `permissionMode: plan`.
> This agent can read and analyze but literally cannot modify your code.
> That's enforced at the tool level, not just a prompt suggestion."

**Demo:** In Claude Code, type:
```
Use the security-reviewer agent to analyze our Spring Security configuration
```

> "Watch — it finds the disabled CSRF (CWE-352, Critical) and the exposed
> actuators (CWE-200, Medium). These are our seeded vulnerabilities.
> The agent produces a structured report with severity, CWE, and fix recommendations."

### Key Comparison
| Feature | Copilot CLI | Claude Code |
|---|---|---|
| Agent definition | `.github/agents/*.agent.md` | `.claude/agents/*/AGENT.md` |
| Tool restrictions | `tools: ["read", "search"]` | `tools` + `disallowedTools` + `permissionMode` |
| Model override | Not available | `model: sonnet` per agent |
| Persistent memory | Not available | `memory: project` per agent |

---

## Scene 3: Skills (2 min)

**Goal:** Show task-specific knowledge loading

### Script

> "Skills are like specialized knowledge packs. They only load when relevant —
> progressive disclosure saves context window space."

**Demo:** Type `/security-scan` in Claude Code.

> "This skill knows how to audit our pom.xml for CVEs, check Spring Security
> configs, and scan for secrets. It's the same concept as Copilot's skills
> directory, but Claude Code adds dynamic context injection."

**Show:** Point out `allowed-tools` in SKILL.md

> "Each skill can restrict which tools Claude uses. The deploy-local skill
> only gets Bash and Read — it can't accidentally edit your source code
> during deployment."

---

## Scene 4: Fleet Mode Equivalent (5 min) — THE HEADLINER

**Goal:** Demonstrate parallel agent execution

### Setup
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

### Script

> "This is the big one. Copilot CLI has /fleet — it decomposes prompts into
> parallel subtasks. Claude Code has agent teams, which do the same thing
> but with three upgrades: persistent identity, tool restrictions, and
> git-isolated worktrees."

**Demo:** In Claude Code, type:
```
Create an agent team to work in parallel:
1. Security review all Java source files
2. Write unit tests for NaicsController and NaicsCodeRepository
3. Validate our Kubernetes manifests against best practices
```

> "Watch — three agents spin up simultaneously. Each has its own context
> window and can see the shared task list."

**Show:** Press `Ctrl+T` to show task list with live progress.

> "The test-writer agent is working in a git worktree — its own isolated
> branch. No merge conflicts. The security reviewer is read-only — it
> can't accidentally fix what it finds. The K8s agent only has kubectl access."

**Wait for completion, then:**

> "The lead agent synthesizes all three reports. Next time I ask for a
> security review, the agent remembers what it found today — persistent
> memory across sessions. Fleet mode doesn't do that."

### Fallback (if agent teams flag is unstable)

Use worktrees + background agents instead:

```bash
# Terminal 1
claude --worktree security-review
> Review all Java files for OWASP Top 10 issues

# Terminal 2
claude --worktree test-writing
> Write unit tests for NaicsController

# Terminal 3
claude --worktree k8s-validation
> Validate k8s/ manifests
```

---

## Scene 5: GHAS Integration (3 min)

**Goal:** Show seeded vulnerabilities detected by GitHub

### Script

> "Let's look at what GitHub Advanced Security found."

**Demo:** Run the ghas-status skill or:
```bash
gh api repos/nocodejim/copilot-demo-v1/dependabot/alerts --jq '.[].security_advisory | "\(.severity): \(.summary)"'
```

> "Dependabot immediately flagged CVE-2022-1471 — SnakeYAML 1.33, CVSS 9.8
> Critical. It's already created a PR to bump to version 2.0.
> One-click fix for a Critical vulnerability."

**Show CodeQL results:**
```bash
gh api repos/nocodejim/copilot-demo-v1/code-scanning/alerts --jq '.[] | "\(.rule.security_severity_level): \(.rule.description)"'
```

> "CodeQL found our disabled CSRF protection (Critical, CWE-352) and the
> exposed actuator endpoints (Medium, CWE-200). Three security findings
> from the default query suite — no custom rules needed."

> "Now here's the magic — I can ask Claude Code to fix these:"
```
Review the Dependabot alert for CVE-2022-1471 and create a fix PR
```

---

## Scene 6: Dev Container + K8s (2 min)

**Goal:** Show containerized development and deployment

### Script

> "Everything runs in a dev container — Java 21, Maven, Docker, kubectl,
> gh CLI. Zero tools installed on the host. Anyone who clones this repo
> gets the exact same environment."

**Demo:**
```bash
./mvnw -B package -DskipTests
docker build -t demo-api:latest .
kubectl apply -f k8s/
kubectl get pods -l app=demo-api -w
```

> "From code to cluster in four commands. The deployment has health probes,
> resource limits, and proper labels — production-grade K8s config."

**Once pod is running:**
```bash
kubectl port-forward svc/demo-api 8080:8080 &
curl -s http://localhost:8080/api/public/naics/search?q=software | jq .
```

> "Our NAICS lookup API is live. 46 industry codes seeded from Census Bureau
> public domain data."

---

## Closing (1 min)

> "Let's recap what we showed:
>
> 1. **CLAUDE.md** — project-aware AI with file imports and path-specific rules
> 2. **Custom agents** — tool-restricted, permission-controlled specialists
> 3. **Skills** — progressive knowledge loading for common workflows
> 4. **Agent teams** — /fleet but with identity, memory, and git isolation
> 5. **GHAS** — AI-assisted security remediation
> 6. **Dev containers + K8s** — reproducible environments, one-command deployment
>
> Everything is version-controlled. CLAUDE.md, agents, skills, rules —
> they're all in the repo. Your team's AI configuration travels with the code."

---

## Q&A Cheat Sheet

| Question | Answer |
|---|---|
| "Does our code leave the machine?" | "Claude Code runs locally. Code is sent to Anthropic's API for processing but is not stored or used for training. Enterprise plans add zero-retention guarantees." |
| "How does this compare to Copilot Workspace?" | "Different tools for different workflows. Copilot Workspace is browser-based PR planning. Claude Code is CLI-first agentic development — it reads, writes, tests, and deploys from your terminal." |
| "What about VS Code integration?" | "Claude Code has a VS Code extension. The agents, skills, and rules we showed all work in both CLI and IDE modes." |
| "Cost?" | "Claude Code is included with Claude Pro ($20/mo), Team ($30/user/mo), or Enterprise plans. Agent teams use per-agent tokens — you control cost by choosing models per agent." |
| "Can we use this with our private repos?" | "Yes. Claude Code works with any git repo. GHAS for private repos requires GitHub Enterprise. Claude Code itself has no repo visibility restrictions." |
