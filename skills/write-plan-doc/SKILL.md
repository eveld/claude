---
name: write-plan-doc
description: Use when creating implementation plans to generate properly structured plans with phases, success criteria, and project references.
---

# Write Plan Document

Create structured implementation plans following project conventions.

## Document Structure

Use the template from `templates/plan-document.md`:

1. **Overview** - Brief description
2. **Current State Analysis** - What exists now
3. **Desired End State** - Specification and verification
4. **What We're NOT Doing** - Explicit out-of-scope items
5. **Implementation Approach** - High-level strategy
6. **Project References** - Links to commands.md and testing.md
7. **Phases** - Detailed implementation steps
8. **Testing Strategy** - Unit, integration, manual
9. **References** - Links to tickets, research

## File Path and Naming

Save to: `thoughts/shared/plans/YYYY-MM-DD-NN-description.md`

Format:
- `YYYY-MM-DD` - Today's date
- `NN` - Sequence number (01, 02, etc.)
- `description` - Kebab-case brief description
- Optional: Include ticket number like `ENG-1234-description`

Example: `2025-12-23-01-ENG-1478-email-notifications.md`

## Phase Structure

Each phase must include:

**Overview** - What this phase accomplishes

**Changes Required** - Specific files and code changes

**Success Criteria** - Split into two sections:
- **Automated Verification**: Commands that can be run
- **Manual Verification**: Human testing needed

## Success Criteria Guidelines

**Automated** (use `make` when possible):
```markdown
- [ ] Tests pass: `make test`
- [ ] Linting passes: `make lint`
- [ ] Build succeeds: `make build`
```

**Manual**:
```markdown
- [ ] Feature appears correctly in UI
- [ ] Performance acceptable with 1000+ items
- [ ] Error messages are user-friendly
```

## Project References

Always reference these documents if they exist:
- `thoughts/notes/commands.md` - Available commands
- `thoughts/notes/testing.md` - Test patterns

These are created by `discover-project-commands` and `discover-test-patterns` skills.

## File References

Include specific file:line references throughout:
- When mentioning existing code
- When suggesting where to add code
- When referencing similar patterns

## No Open Questions

Plans must be complete and actionable. If you have open questions:
1. STOP writing the plan
2. Research or ask for clarification
3. Only proceed once all decisions are made
