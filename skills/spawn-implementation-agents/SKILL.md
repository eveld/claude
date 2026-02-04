---
name: spawn-implementation-agents
description: Guide for efficient agent orchestration during implementation to conserve main agent context
---

# Spawn Implementation Agents

Orchestrate specialized agents during implementation to keep main agent context under 40k tokens per phase.

## The Problem

Without agents, implementing a phase uses ~92k tokens in main agent:
- Read plan & changelog: 15k
- Read existing code files: 30k
- Find usage patterns: 15k
- Write implementation: 10k
- Write tests: 10k
- Run verification: 10k
- Update changelog: 2k

This approaches the 200k context limit and risks compaction.

## The Solution

Use agents to isolate heavy operations:
- Main agent: 38k tokens (plan + changelog + summaries + code writing)
- Sub-agents: 60k tokens total (in isolated contexts)
- Total system: 98k tokens (50% safety margin)

## 5-Phase Orchestration Pattern

### Phase 1: Analysis (Parallel)

Spawn simultaneously to gather context:

```markdown
Task(subagent_type="workflows:codebase-analyzer",
     prompt="Analyze existing auth system architecture.
     Focus on handler pattern, middleware usage, error handling.
     Return 2-3k summary with key patterns and file:line references.")

Task(subagent_type="workflows:codebase-pattern-finder",
     prompt="Find similar implementations of authentication handlers.
     Return 3k of concrete examples showing handler pattern, validation, errors.")

Task(subagent_type="workflows:thoughts-analyzer",
     prompt="Extract insights from changelog.md about previous phase learnings.
     Return 2k of key deviations and discoveries that affect this phase.")
```

**Wait for all three**. Main agent receives ~8k of summaries.

### Phase 2: Implementation (Main Agent)

Main agent writes code using summaries:
- Has patterns from codebase-pattern-finder
- Understands architecture from codebase-analyzer
- Knows previous deviations from thoughts-analyzer
- Writes implementation: 10k tokens
- Total so far: 15k (plan/changelog) + 8k (summaries) + 10k (code) = 33k

### Phase 3: Testing (Sequential)

Spawn test writer:

```markdown
Task(subagent_type="workflows:test-writer",
     prompt="Generate tests for AuthHandler following patterns in testing.md.
     Test functions: Login(), Logout(), ValidateToken().
     Return test code only, ~3k tokens.")
```

Main agent receives test code, integrates it. Total: 36k

### Phase 4: Verification (Sequential)

Spawn verifier:

```markdown
Task(subagent_type="Bash",
     prompt="Run verification commands from plan.md:
     - make test
     - make lint
     - make build
     Return concise summary: ✅ passed or ❌ failed with key errors only.")
```

Main agent receives pass/fail + errors. Total: 38k

### Phase 5: Documentation (Main Agent)

Update changelog.md: 2k tokens. Final total: 40k

## Token Budget Comparison

| Activity | Without Agents | With Agents | Savings |
|----------|----------------|-------------|---------|
| Read plan & changelog | 15k | 15k | 0k |
| Understand existing code | 30k | 3k | **27k** |
| Find patterns | 15k | 3k | **12k** |
| Write implementation | 10k | 10k | 0k |
| Write tests | 10k | 3k | **7k** |
| Run verification | 10k | 2k | **8k** |
| Update changelog | 2k | 2k | 0k |
| **TOTAL** | **92k** | **40k** | **52k** |

## Guidelines

**When to spawn in parallel**:
- Analysis phase (codebase-analyzer + pattern-finder + thoughts-analyzer)
- Independent lookups (finding multiple unrelated examples)
- Reading multiple unrelated files

**When to spawn sequentially**:
- Test writing (needs implementation to be done first)
- Verification (needs tests to be written first)
- Operations that depend on previous results

**What agents return**:
- **Summaries**, not raw data (2-5k tokens each)
- **Key patterns**, not all files (concrete examples only)
- **Pass/fail + errors**, not full output (1-2k tokens)

## Benefits

- **60% token reduction** per phase in main agent
- **Larger phases possible**: 5-8 files instead of 3-5
- **Complex integrations supported**: Agents find patterns
- **Large files OK**: Agents handle reading (>2000 lines)
- **Safety margin**: 100k tokens remaining in system

## Important Notes

- Main agent NEVER reads large files directly
- Main agent orchestrates, sub-agents execute
- Summaries are compressed, not exhaustive
- This is guidance, not automation - user still in control
