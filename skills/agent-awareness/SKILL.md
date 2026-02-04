---
name: agent-awareness
description: ALWAYS check this skill before using grep, glob, Task tool, or doing any codebase exploration. Guides you to use specialized agents that are more efficient than basic tools.
---

# Agent Awareness Guide

You have access to specialized agents that are MORE EFFICIENT than basic tools. You MUST use these agents instead of grep, glob, or generic Task agents.

## Decision Tree

**Finding files or components?**
→ Use `codebase-locator` agent
- Better than: grep, glob, find, ls
- Example: "Find all authentication-related files"

**Understanding how code works?**
→ Use `codebase-analyzer` agent
- Better than: Reading multiple files manually
- Example: "Analyze how the login flow works"

**Finding similar implementations or patterns?**
→ Use `codebase-pattern-finder` agent
- Better than: Searching and reading manually
- Example: "Find examples of API handlers"

**Finding documentation in thoughts/?**
→ Use `thoughts-locator` agent
- Better than: grep in thoughts directory
- Example: "Find research about authentication"

**Understanding specific documents?**
→ Use `thoughts-analyzer` agent
- Better than: Reading docs manually
- Example: "Extract key insights from these research docs"

**Researching external information?**
→ Use `web-search-researcher` agent
- Only when user explicitly asks for web research
- Example: "Research how JWT tokens work"

**Analyzing complex errors or stack traces?**
→ Use `error-analyzer` agent
- Better than: Reading multiple files manually to understand error
- Example: "Analyze this panic: nil pointer dereference at handler.go:42"

## Available Agents

| Task Type | Use This subagent_type |
|-----------|----------------------|
| Finding files/components | `codebase-locator` |
| Understanding code | `codebase-analyzer` |
| Finding similar patterns | `codebase-pattern-finder` |
| Finding documentation | `thoughts-locator` |
| Analyzing documents | `thoughts-analyzer` |
| Web research | `web-search-researcher` |
| Analyzing errors | `error-analyzer` |

## Implementation Agents

During implementation, use aggressive agent orchestration:
- See `spawn-implementation-agents` skill for full pattern
- Keep main agent under 40k tokens per phase
- Use sub-agents for file reading, pattern finding, testing, verification
- 60% token reduction per phase

## When to Use Agents

### ALWAYS Use Agents For:
- "Find all files that..."
- "Where is the code for..."
- "How does [feature] work?"
- "Find examples of..."
- "Show me similar..."
- "What documentation exists about..."

### NEVER Use Basic Tools For:
- ❌ grep/Grep when looking for files or features
- ❌ glob/Glob when finding components
- ❌ Reading multiple files to understand a system
- ❌ Generic Task agents when specialized agents exist

## How to Invoke Agents

Use the Task tool with the correct `subagent_type`:

```
Task(
  subagent_type="codebase-locator",
  prompt="Find all authentication-related files",
  description="Locate auth files"
)
```

## Remember

Agents have isolated context windows and specialized tools. They are designed for these tasks and will give you better, faster, more comprehensive results than basic tools.
