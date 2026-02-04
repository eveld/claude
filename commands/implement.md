# Implement Plan

You are implementing an approved plan systematically.

## Initial Response

Check if parameters were provided:
- If plan file provided: Detect format and read FULLY
  - New format: `thoughts/NNNN-description/plan.md`
  - Old format: `thoughts/shared/plans/YYYY-MM-DD-NN-*.md`
- If no parameters: Show usage message and wait

Usage message:
```
I'll help you implement an approved plan. Please provide the path to the plan file.

Example (new format): `/implement thoughts/0005-authentication/plan.md`
Example (old format): `/implement thoughts/shared/plans/2026-02-03-01-auth.md`
```

## Workflow

### Step 1: Read Plan
- Read plan file FULLY (no limit/offset)
- Detect format (feature directory or legacy)
- Check for existing checkboxes (may be partially complete)
- Understand all phases and success criteria

### Step 2: Read Context Documents
- **Read changelog** if it exists: `thoughts/NNNN-description/changelog.md`
  - Understand what's been completed so far
  - Note deviations from previous phases
  - Adapt current phase based on actual state (auto-correction)
  - If changelog doesn't exist, this is the first phase

- Check if plan references `thoughts/notes/commands.md`
  - If yes and exists: Read it
  - If yes but doesn't exist: Use `discover-project-commands` skill, then read

- Check if plan references `thoughts/notes/testing.md`
  - If yes and exists: Read it
  - If yes but doesn't exist: Use `discover-test-patterns` skill, then read

### Step 3: Analyze with Agents (NEW)

**DO NOT read files directly in main context**

Before implementing, spawn analysis agents in parallel:

```markdown
Task(subagent_type="workflows:codebase-analyzer",
     prompt="Analyze [component] architecture for this phase.
     Return 2-3k summary with key patterns and integration points.")

Task(subagent_type="workflows:codebase-pattern-finder",
     prompt="Find similar implementations of [feature].
     Return 3k of concrete examples.")

Task(subagent_type="workflows:thoughts-analyzer",
     prompt="Extract insights from changelog.md about previous phases.
     Return 2k of deviations and learnings relevant to this phase.")
```

**Wait for all agents to complete**. Main agent receives summaries (~8k tokens total).

**See `spawn-implementation-agents` skill** for full orchestration pattern.

### Step 4: Implement Changes (Main Agent)

Write code based on:
- Patterns from codebase-pattern-finder
- Architecture from codebase-analyzer
- Previous learnings from thoughts-analyzer
- Plan specifications

**Do not read additional files** - use agent summaries instead.

### Step 5: Write Tests with Agent (NEW)

**DO NOT write tests directly in main context**

Spawn test-writer agent:

```markdown
Task(subagent_type="workflows:test-writer",
     prompt="Generate tests for [functions] following patterns in testing.md.
     Expected behavior: [describe from plan].
     Edge cases: [list from plan].
     Return test code only.")
```

Main agent receives test code (~3k tokens), integrates into test files.

### Step 6: Verify with Agent (UPDATED)

**DO NOT run verification directly in main context**

Spawn verification agent (use `verify-implementation` skill):

```markdown
Task(subagent_type="Bash",
     prompt="Run verification commands from plan.md success criteria:
     - [list automated checks]
     Return concise summary: ✅ passed or ❌ failed with key errors only.")
```

Main agent receives summary (1-2k tokens) instead of raw output (10k+).

### Step 7: Update Plan Checkboxes
- Mark checkboxes as complete in plan file
- Update as you complete each success criterion

### Step 8: Update Changelog
- Use `update-changelog` skill to append phase completion
- Include:
  - What was actually done
  - Deviations from plan (planned vs actually, reason)
  - Files changed
  - Discoveries made during implementation
- If this was the last phase: Also append FINAL SUMMARY section

### Step 9: Handle Mismatches
- If plan doesn't match reality: STOP and ask user
- If previous phases changed approach: Adapt based on changelog
- Don't make assumptions or deviate without approval

## Important Notes

- Read plan fully at start
- Use verify-implementation after each phase
- Update checkboxes as you progress
- Stop and ask if plan seems incorrect
- Use TodoWrite to track implementation
- Follow test patterns from reference docs

## Token Management

Each phase should keep main agent under 40k tokens:
- Plan + changelog: 15k
- Agent summaries: 8k
- Implementation: 10k
- Test integration: 3k
- Verification summary: 2k
- Changelog update: 2k
- **Total: ~40k**

Sub-agents use 60k tokens in isolated contexts (total system: <100k).

See `spawn-implementation-agents` skill for detailed guidance.
