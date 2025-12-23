---
name: before-spawning-task
description: Use BEFORE using the Task tool. Ensures you select the correct specialized subagent_type instead of generic agents.
---

# Before Spawning Task

**STOP**: You're about to use the Task tool.

## Check for Specialized Agents First

Don't use generic subagent_type values. We have specialized agents:

| Task Type | Use This subagent_type |
|-----------|----------------------|
| Finding files/components | `codebase-locator` |
| Understanding code | `codebase-analyzer` |
| Finding similar patterns | `codebase-pattern-finder` |
| Finding documentation | `thoughts-locator` |
| Analyzing documents | `thoughts-analyzer` |
| Web research | `web-search-researcher` |

## Examples

### ❌ Wrong:
```
Task(subagent_type="general-purpose", prompt="Find auth files")
Task(subagent_type="Explore", prompt="How does login work?")
```

### ✅ Correct:
```
Task(subagent_type="codebase-locator", prompt="Find all authentication-related files")
Task(subagent_type="codebase-analyzer", prompt="Analyze how the login flow works")
```

## When Generic Agents Are OK

Only use generic agents (general-purpose, Explore) when:
- No specialized agent matches the task
- Task requires mixed capabilities (search + analysis + web)
- User explicitly requests a specific agent type

Always prefer specialized agents when available.
