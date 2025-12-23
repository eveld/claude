---
name: spawn-research-agents
description: Use when conducting codebase research to orchestrate specialized agents in parallel for comprehensive investigation.
---

# Spawn Research Agents

Use specialized agents in parallel to research different aspects of the codebase efficiently.

## Agent Selection

Choose agents based on research needs:

**Always start with locators**:
- `codebase-locator` - Find WHERE files/components are
- `thoughts-locator` - Find WHAT documentation exists

**Then use analyzers on findings**:
- `codebase-analyzer` - Understand HOW specific code works
- `codebase-pattern-finder` - Find SIMILAR implementations
- `thoughts-analyzer` - Extract insights from specific docs

**Only if user explicitly requests**:
- `web-search-researcher` - External research

## Parallel Execution Pattern

Spawn multiple agents at once using multiple Task calls in a single message:

```
Task(subagent_type="codebase-locator", prompt="Find all authentication files")
Task(subagent_type="thoughts-locator", prompt="Find auth-related documentation")
```

Then wait for both to complete before spawning follow-up agents.

## Research Workflow

1. **Decompose**: Break research question into specific areas
2. **Locate**: Use locator agents to find relevant files/docs
3. **Analyze**: Use analyzer agents on most promising findings
4. **Synthesize**: Combine all results with file:line references

## Example

Research question: "How does authentication work?"

**Step 1 - Locate (parallel)**:
```
Task(subagent_type="codebase-locator", prompt="Find all authentication-related files including handlers, middleware, and services")
Task(subagent_type="thoughts-locator", prompt="Find any documentation about authentication implementation")
```

**Step 2 - Analyze (parallel, after step 1 completes)**:
```
Task(subagent_type="codebase-analyzer", prompt="Analyze authentication flow from login endpoint through JWT generation")
Task(subagent_type="codebase-pattern-finder", prompt="Find examples of how other endpoints use authentication middleware")
```

**Step 3 - Synthesize**:
Combine findings with specific file paths and line numbers.
