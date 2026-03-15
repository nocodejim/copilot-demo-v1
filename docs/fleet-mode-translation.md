# Fleet Mode → Claude Code: Translation Guide

Copilot CLI's `/fleet` decomposes a prompt into parallel subtasks and runs them via subagents. Claude Code achieves the same outcome through three complementary mechanisms that are **more powerful** than fleet mode.

---

## Side-by-Side Comparison

| Capability | `/fleet` (Copilot CLI) | Claude Code |
|---|---|---|
| **Parallel execution** | Automatic decomposition | Agent teams, worktrees, background agents |
| **Agent identity** | Anonymous subagents | Named agents with persistent memory |
| **Isolation** | Shared workspace | Git worktree per agent (own branch) |
| **Coordination** | Task list only | Task list + peer messaging + mailbox |
| **Tool restrictions** | None | Per-agent tool allow/deny lists |
| **Permission control** | Inherited | Per-agent permission modes (plan, read-only) |
| **Model selection** | Fixed (low-cost) | Per-agent model override (opus/sonnet/haiku) |
| **Cross-session memory** | None | Persistent memory (user/project/local scopes) |
| **Monitoring** | `/tasks` | `Ctrl+T` task list + SubagentStart/Stop hooks |

---

## Mechanism 1: Agent Teams (Direct Fleet Equivalent)

Agent teams are the closest analog to `/fleet`. Enable with:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude
```

### Example: Parallel Security + Testing + K8s Validation

```
Create an agent team with these roles:
1. security-reviewer: Audit all Java source files for OWASP Top 10
2. test-writer: Write unit tests for all service classes
3. k8s-validator: Validate Kubernetes manifests against best practices

Each teammate works in parallel. Report findings when done.
```

**What happens:**
- Lead agent decomposes the task into 3 subtasks
- Each teammate gets its own context window
- Teammates claim tasks from shared task list
- They can message each other directly (e.g., test-writer asks security-reviewer about a finding)
- Lead synthesizes all results when teammates finish

### Agent Team vs Fleet: The Upgrade

```
Fleet mode:                          Agent teams:
┌─────────────┐                     ┌─────────────┐
│  Orchestrator│                     │    Lead      │
│  (anonymous) │                     │  (named)     │
└─┬───┬───┬───┘                     └─┬───┬───┬───┘
  │   │   │                           │   │   │
  ▼   ▼   ▼                           ▼   ▼   ▼
┌───┐┌───┐┌───┐                     ┌───┐┌───┐┌───┐
│ ? ││ ? ││ ? │ anonymous            │sec││tst││k8s│ named + specialized
└───┘└───┘└───┘                     └─┬─┘└─┬─┘└─┬─┘
  │   │   │                           │   │   │
  ▼   ▼   ▼                           ▼   ▼   ▼
 Same workspace                      Git worktrees (isolated branches)
 No memory                           Persistent memory
 No messaging                        Peer messaging + mailbox
```

---

## Mechanism 2: Worktree Isolation (Parallel Feature Branches)

For independent feature work, use `--worktree` to give each session its own git branch:

```bash
# Terminal 1: Add NAICS API
claude --worktree add-naics-api

# Terminal 2: Add health checks
claude --worktree add-health-checks

# Terminal 3: Write tests
claude --worktree add-tests
```

Each session gets:
- Its own git branch (`worktree-add-naics-api`, etc.)
- Its own working directory under `.claude/worktrees/`
- Full access to repo history
- No file conflicts with other sessions

Merge when ready — standard git workflow.

### When to Use Worktrees vs Agent Teams

| Scenario | Use |
|---|---|
| Decompose one prompt into parallel subtasks | Agent teams |
| Work on independent features simultaneously | Worktrees |
| Need agents to coordinate / message each other | Agent teams |
| Need complete git isolation per task | Worktrees |
| Quick parallel research | Agent teams |
| Long-running parallel development | Worktrees |

---

## Mechanism 3: Background Agents

Background a running task and keep working:

```
> Run the security-scan skill and report findings
[Claude starts scanning...]
[Press Ctrl+B to background]
[Continue with other work]
[Notification appears when scan completes]
```

Or configure agents to always run in background:

```yaml
# .claude/agents/background-scanner/AGENT.md
---
name: background-scanner
description: Continuous security scanning in background
background: true
---
```

---

## Demo Script: Fleet-Equivalent Showcase

### Step 1: Show the Setup (30 seconds)
```
"Let me show you our Claude Code configuration.
 CLAUDE.md gives Claude project context — like copilot-instructions.md but with
 file imports and path-scoping.

 We have three custom agents: security-reviewer (read-only), test-writer
 (worktree-isolated), and k8s-deployer (kubectl-only). Each has tool
 restrictions — the security reviewer literally cannot modify code."
```

### Step 2: Launch Agent Team (2 minutes)
```
"Now watch this. I'm going to ask Claude to parallelize three tasks
 at once — the same thing /fleet does, but with named, specialized agents."

> Create an agent team:
> 1. Review all Java files for security issues
> 2. Write unit tests for NaicsController
> 3. Validate the K8s deployment manifest

[Show 3 agents spinning up in split panes or task list]
```

### Step 3: Show Coordination (2 minutes)
```
"Each agent works independently but can communicate.
 The security reviewer found that our CSRF is disabled — that's intentional
 for the demo, but in production it would flag Critical.

 The test writer is generating tests in its own git branch — worktree
 isolation means no merge conflicts while it works.

 The K8s agent validated our deployment manifest and found our resource
 limits are properly set."

[Show Ctrl+T task list with live progress]
```

### Step 4: Synthesize Results (1 minute)
```
"The lead agent now has all three reports. It synthesizes them into
 a single summary. This is what /fleet does, but each agent here has
 persistent memory — next time I ask for a security review, it remembers
 what it found last time."
```

### Talking Points

| Question | Answer |
|---|---|
| "How is this different from /fleet?" | "Fleet dispatches anonymous subagents. Agent teams give each agent a name, tool restrictions, permission modes, and persistent memory. It's fleet mode with enterprise guardrails." |
| "Can agents modify code?" | "Only if you allow it. Our security-reviewer has `disallowedTools: Write, Edit` — it can read and analyze but never change code. That's enforced, not just suggested." |
| "What about cost?" | "Each agent can use a different model. Security review on Sonnet, implementation on Opus, exploration on Haiku. You control the cost profile per agent." |
| "Is this production-ready?" | "Agent teams are experimental (behind a flag). Worktrees and background agents are GA. For production demos, use worktrees + background agents for the most reliable experience." |
