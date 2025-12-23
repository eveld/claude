---
name: spawn-planning-agents
description: Use when creating implementation plans to research codebase patterns and gather context for planning.
---

# Spawn Planning Agents

Use specialized agents to gather context needed for creating detailed implementation plans.

## Planning Research Needs

When planning implementations, you need:

1. **Existing code patterns** - How is similar functionality implemented?
2. **Integration points** - What files will need to change?
3. **Test patterns** - How should tests be written?
4. **Documentation** - What prior decisions or research exists?

## Agent Selection for Planning

**Find what exists**:
- `codebase-locator` - Find files related to the feature area
- `thoughts-locator` - Find existing plans, research, or tickets

**Understand patterns**:
- `codebase-pattern-finder` - Find similar features to model after
- `codebase-analyzer` - Understand existing architecture

**Extract insights**:
- `thoughts-analyzer` - Extract key decisions from prior research

## Planning Workflow

1. **Context gathering (parallel)**:
   - Locate existing code in the feature area
   - Find similar implementations to model after
   - Check for prior research or decisions

2. **Pattern analysis (parallel, after context)**:
   - Analyze architecture of similar features
   - Understand integration points

3. **Plan creation**:
   - Use findings to inform phases
   - Reference specific files and patterns
   - Include concrete examples from codebase

## Example

Planning task: "Add email notifications feature"

**Step 1 - Context (parallel)**:
```
Task(subagent_type="codebase-locator", prompt="Find all notification-related code")
Task(subagent_type="codebase-pattern-finder", prompt="Find examples of background job handlers and email sending")
Task(subagent_type="thoughts-locator", prompt="Find any research about notification systems")
```

**Step 2 - Analysis (after context)**:
```
Task(subagent_type="codebase-analyzer", prompt="Analyze how the existing SMS notification system works, including job queuing and template rendering")
```

**Step 3 - Plan with specifics**:
Reference the patterns found and create phases that follow existing conventions.
