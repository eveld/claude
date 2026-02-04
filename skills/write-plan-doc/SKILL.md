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
8. **Changelog** - Implementation tracking (created during implementation)
   - Not created by plan command
   - Implementation command creates and maintains it
   - Used for auto-correction loop
9. **Testing Strategy** - Unit, integration, manual
10. **References** - Links to tickets, research

## File Path and Naming

Determine feature slug first using `determine-feature-slug` skill:
- If implementing from existing research: Use same slug (same directory)
- If new feature: Auto-detect next number, suggest description from plan title
- Prompts user to accept or customize

Save to: `thoughts/NNNN-description/plan.md`

Example workflow:
1. Planning from research doc `thoughts/0005-authentication/research.md`
2. Skill suggests: `0005-authentication` (same directory)
3. Document saved to: `thoughts/0005-authentication/plan.md`

**Backward compatibility**: Old path `thoughts/shared/plans/YYYY-MM-DD-NN-description.md` still recognized.

## Phase Structure

Each phase must include:

**Overview** - What this phase accomplishes

**Changes Required** - Specific files and code changes

**Success Criteria** - Split into two sections:
- **Automated Verification**: Commands that can be run
- **Manual Verification**: Human testing needed

## Milestone Structure

Group related phases into testable milestones:

**When to create milestones**:
- Group 2-4 related phases together
- Each milestone has user-facing outcome
- User can test milestone completion
- Natural stopping points for validation

**Milestone format**:
```markdown
## Milestone N: {Name}
**Goal**: {What user gets}
**Testable**: {How to verify it works}

### Phase N.1: {Technical step}
### Phase N.2: {Technical step}
```

**Example**:
```markdown
## Milestone 1: Database Ready
**Goal**: Database can store authentication data
**Testable**: Can manually insert and query user records

### Phase 1.1: Create User Table
[Technical implementation details]

### Phase 1.2: Add Authentication Fields
[Technical implementation details]

## Milestone 2: Authentication Working
**Goal**: Users can log in and receive tokens
**Testable**: Can log in via API and get valid JWT

### Phase 2.1: Implement Login Handler
[Technical implementation details]
```

**Benefits**:
- Clear stopping points for user validation
- Incremental delivery of value
- User-facing goals, not just technical tasks
- Easier to understand project progress

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

### Changelog Reference

During implementation, a changelog will be created:
- `thoughts/NNNN-description/changelog.md` - Phase-by-phase tracking
- Read before each phase for auto-correction
- Updated after each phase with deviations

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
