---
name: upgrade-plugin
description: Handle plugin version upgrades with intelligent reasoning about edge cases and grouping decisions
---

# Upgrade Plugin

Orchestrate plugin version upgrades, combining automated scripts with intelligent reasoning for edge cases.

## When to Use

Called by `/workflows:upgrade` command to handle the upgrade process.

## Responsibilities

### 1. Version Detection
- Identify current plugin version from directory structure
- Detect old-format documents in `thoughts/shared/`
- Check for version-specific files or patterns

### 2. Document Analysis
- Scan for all migratable documents
- Group related documents by topic/feature
- Identify documents with cross-references
- Find non-standard formats or edge cases

### 3. Grouping Recommendations
Use research topics and plan titles to suggest feature groupings:

**Example**:
```
Found 3 related documents:
- thoughts/shared/research/2026-01-15-01-jwt-tokens.md
- thoughts/shared/research/2026-01-20-01-oauth-flow.md
- thoughts/shared/plans/2026-01-22-01-authentication-system.md

Recommendation: Group as feature 0005-authentication
- research.md: Combine JWT + OAuth research (most recent approach)
- plan.md: Use authentication system plan

Approve grouping? [Yes/Custom]
```

### 4. Cross-Reference Updates
- Scan documents for references to old paths
- Propose updates to new paths
- Example: `thoughts/shared/research/2026-01-15-01-auth.md` → `thoughts/0005-authentication/research.md`

### 5. Edge Case Handling
Present edge cases to user:

**Non-standard frontmatter**:
```
Document has custom field "owner: alice"
- Preserve in new location?
- Standardize to new format?
```

**Orphaned documents**:
```
Found plan without related research
- Create standalone feature directory?
- Pair with related research?
```

### 6. Migration Execution
- Run `scripts/migrate-thoughts.sh` for standard cases
- Apply user-approved groupings
- Update cross-references
- Add feature_slug to frontmatter
- Preserve originals

### 7. Report Generation
```markdown
# Upgrade Report: v1.2.0 → v1.3.0

## Summary
- Migrated: 15 documents
- Created: 8 feature directories
- Grouped: 3 multi-document features
- Updated: 12 cross-references

## Feature Directories Created
- 0001-authentication (research + plan)
- 0002-rate-limiting (research only)
- 0003-webhook-system (plan only)
[...]

## Manual Review Needed
- Cross-reference in thoughts/0001-authentication/plan.md line 45
  references deleted file - verify still valid
- Custom frontmatter preserved in 0002-rate-limiting/research.md

## Cleanup (Optional)
Original files preserved in thoughts/shared/
After verification, can delete: `rm -rf thoughts/shared/`
```

## Important Guidelines

- **Never force groupings** - Always ask user
- **Preserve originals** - Never delete source files
- **Show dry-run first** - Let user review before applying
- **Document decisions** - Generate clear upgrade report
- **Be conservative** - When unsure, ask user
