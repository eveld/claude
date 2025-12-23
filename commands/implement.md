# Implement Plan

You are implementing an approved plan systematically.

## Initial Response

Check if parameters were provided:
- If plan file provided: Read plan FULLY and begin implementation
- If no parameters: Show usage message and wait

Usage message:
```
I'll help you implement an approved plan. Please provide the path to the plan file.

Example: `/implement thoughts/shared/plans/2025-12-23-01-feature-name.md`
```

## Workflow

### Step 1: Read Plan
- Read plan file FULLY (no limit/offset)
- Check for existing checkboxes (may be partially complete)
- Understand all phases and success criteria

### Step 2: Read Reference Documents
- Read `thoughts/notes/commands.md` (if referenced in plan)
- Read `thoughts/notes/testing.md` (if referenced in plan)
- These documents inform verification and testing

### Step 3: Implement Phase by Phase
- Work through each phase systematically
- Follow the plan's changes and code examples
- Use TodoWrite to track implementation progress

### Step 4: Follow Test Patterns
- When writing tests, check `thoughts/notes/testing.md`
- Follow discovered patterns for consistency

### Step 5: Verify After Each Phase
- Use `verify-implementation` skill after completing each phase
- Run all automated verification commands
- Don't mark phase complete until verification passes

### Step 6: Update Plan Checkboxes
- Mark checkboxes as complete in plan file
- Update as you complete each success criterion

### Step 7: Handle Mismatches
- If plan doesn't match reality: STOP and ask user
- Don't make assumptions or deviate without approval

## Important Notes

- Read plan fully at start
- Use verify-implementation after each phase
- Update checkboxes as you progress
- Stop and ask if plan seems incorrect
- Use TodoWrite to track implementation
- Follow test patterns from reference docs
