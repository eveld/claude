---
name: update-changelog
description: Append phase completion details or final summary to changelog.md during implementation
---

# Update Changelog

Append phase tracking or final summary to `thoughts/NNNN-description/changelog.md`.

## When to Use

**During Implementation** (after each phase):
- Document what was actually done vs planned
- Note deviations and reasons
- List files changed
- Capture discoveries

**At Completion** (after all phases):
- Append FINAL SUMMARY section
- Summarize key deviations
- Document lessons learned
- Note technical debt and follow-up work

## Phase Update Format

Use template from `templates/changelog-document.md` Phase section:

```markdown
## Phase {N}: {Phase Name}
**Completed**: {ISO_DATE}
**Status**: ✅ Complete

### What We Did
- Created slug determination skill
- Added interactive prompting with suggestions

### Deviations from Plan
- **Planned**: Create bash script only
- **Actually**: Created both skill and script
- **Reason**: Skill needed for integration with commands

### Files Changed
- `skills/determine-feature-slug/SKILL.md` - New skill file
- `scripts/next-feature-slug.sh` - Helper script

### Discoveries
- Bash parameter expansion handles leading zeros: `10#$NUM`
- Kebab-case validation regex: `^[a-z0-9-]+$`
```

## Final Summary Format

Use template from `templates/changelog-document.md` FINAL SUMMARY section:

```markdown
## 🎯 FINAL SUMMARY
**Completion Date**: 2026-02-05
**Overall Status**: ✅ Complete

### What Was Built
Full plugin restructuring with feature directories, changelog tracking,
milestone grouping, and agent orchestration.

### Key Deviations
1. Added interactive slug prompting (not in original plan)
2. Kept thoughts/notes/ unchanged instead of moving

### Impact on Original Plan
- Plan estimated 11 phases, completed 11
- Added 2 skills not in plan (prompting helpers)
- Simplified 3 phases by combining related changes

[... rest of sections ...]
```

## Important Guidelines

- **Read plan first** to understand what was intended
- **Compare actual vs planned** - be specific about deviations
- **Capture learnings** - what would you do differently?
- **Note technical debt** - what was compromised for speed?
- **Append only** - never modify previous phase entries
- **Be concise** - focus on what matters, skip obvious details

## Auto-Correction Loop

The changelog enables auto-correction:
1. Before Phase N: Read both `plan.md` AND `changelog.md`
2. Plan shows original intent
3. Changelog shows actual state after Phase N-1
4. Adapt Phase N approach based on actual state
5. After Phase N: Document new deviations

Example:
```
Phase 3 needs to integrate with auth system
- plan.md says: "Use middleware pattern from Phase 1"
- changelog.md says: "Phase 1 used decorator pattern instead"
- Agent adapts: Uses decorator pattern, not middleware ✅
```
