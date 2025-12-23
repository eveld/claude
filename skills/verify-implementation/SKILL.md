---
name: verify-implementation
description: Use after implementing changes to run verification commands and ensure tests pass, code builds, and functionality works.
---

# Verify Implementation

Run verification commands after implementing changes to ensure correctness.

## Verification Sources

Check `thoughts/notes/commands.md` (created by `discover-project-commands` skill) for:
- Available test commands
- Linting commands
- Build commands
- Other project-specific verification

## Common Verification Steps

### 1. Run Tests
Check commands.md, then run appropriate command:
- `make test` - If Make target exists
- `npm test` - If npm script exists
- `go test ./...` - Direct Go command
- `pytest` - Direct Python command

### 2. Run Linting
Check commands.md, then run:
- `make lint` - If Make target exists
- `npm run lint` - If npm script exists
- `golangci-lint run` - Direct Go command
- `eslint .` - Direct JavaScript command

### 3. Build Check
Check commands.md, then run:
- `make build` - If Make target exists
- `npm run build` - If npm script exists
- `go build ./...` - Direct Go command

### 4. Type Checking (if applicable)
- `npm run typecheck` - TypeScript
- `mypy .` - Python
- Go builds include type checking

## Verification Workflow

1. **Check for commands.md**: Read `thoughts/notes/commands.md`
2. **Run automated checks**: Use commands from reference doc
3. **Report results**: Show pass/fail for each check
4. **Manual verification**: Prompt for manual testing if needed

## Handling Failures

If verification fails:
1. Show the error output
2. Analyze the error
3. Fix the issue
4. Re-run verification
5. Don't mark task complete until all checks pass

## Example

```bash
# Read the commands reference
cat thoughts/notes/commands.md

# Run appropriate commands
make test
make lint
make build

# All pass? Mark phase complete in plan
# Any fail? Debug and fix before proceeding
```
