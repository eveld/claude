---
name: discover-project-commands
description: Use during planning to discover and document available project commands (make targets, npm scripts, etc.) for success criteria.
---

# Discover Project Commands

Automatically discover and document all available commands in the project for reference during planning and implementation.

## What to Discover

### Make Targets
Check for `Makefile` and extract all targets:
- Use `make -qp` or parse Makefile directly
- Document target names and descriptions (from comments)

### NPM Scripts
Check for `package.json` and extract scripts:
- Read package.json
- Document script names and what they do

### Go Commands
If Go project, document standard commands:
- `go test ./...`
- `go build ./...`
- `go run`
- Custom test/build commands

### Other Build Tools
Check for and document:
- Gradle tasks
- Maven goals
- Cargo commands
- Python setup.py commands

## Output Format

Write to: `thoughts/notes/commands.md`

Use the template from `templates/commands-reference.md` and populate with discovered commands.

## Discovery Process

1. **Check for Makefile**: Parse targets and descriptions
2. **Check for package.json**: Extract npm scripts
3. **Detect language**: Look for go.mod, requirements.txt, Cargo.toml, etc.
4. **Document commands**: Use template to create reference doc
5. **Include metadata**: Add timestamp and project name

## Example Output Structure

```markdown
---
last_updated: 2025-12-23T10:00:00Z
last_updated_by: Claude
project: my-project
---

# Project Commands Reference

Last discovered: 2025-12-23

## Make Targets

- `make test` - Run all tests
- `make build` - Build the project
- `make lint` - Run linters

## NPM Scripts

- `npm test` - Run Jest tests
- `npm run build` - Build for production

## Common Verification Commands

- `make test` - Recommended for success criteria
- `make lint` - Recommended for code quality checks
```

## When to Use

Automatically invoked by the `plan` command if `thoughts/notes/commands.md` doesn't exist.
