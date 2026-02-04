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
Use research topics and plan titles to suggest feature groupings, then use AskUserQuestion:

**Example**:
```
Found 3 related documents:
- thoughts/shared/research/2026-01-15-01-jwt-tokens.md
- thoughts/shared/research/2026-01-20-01-oauth-flow.md
- thoughts/shared/plans/2026-01-22-01-authentication-system.md

Recommendation: Group as feature 0005-authentication
- research.md: Combine JWT + OAuth research (most recent approach)
- plan.md: Use authentication system plan

AskUserQuestion:
  question: "Accept proposed grouping for authentication documents?"
  header: "Grouping"
  options:
    - "Accept" - Use recommended grouping (0005-authentication)
    - "Modify" - Let me specify different grouping or feature name
```

### 4. Cross-Reference Updates
- Scan documents for references to old paths
- Propose updates to new paths
- Example: `thoughts/shared/research/2026-01-15-01-auth.md` → `thoughts/shared/0005-authentication/research.md`

### 5. Edge Case Handling
Present edge cases to user using AskUserQuestion:

**Non-standard frontmatter**:
```
AskUserQuestion:
  question: "Document has custom field 'owner: alice'. How should we handle it?"
  header: "Frontmatter"
  options:
    - "Preserve" - Keep custom field in migrated document
    - "Remove" - Use only standard frontmatter fields
```

**Orphaned documents**:
```
AskUserQuestion:
  question: "Found plan without related research. How should we migrate it?"
  header: "Orphaned Doc"
  options:
    - "Standalone" - Create separate feature directory
    - "Group" - Pair with existing related research
```

### 6. Migration Execution
- Run `scripts/migrate-thoughts.sh` for standard cases
- Apply user-approved groupings
- Update cross-references to point to new paths
- Don't modify frontmatter (no new metadata fields)
- Preserve originals in legacy locations

### 7. Report Generation and Cleanup
Generate migration report showing what was done:
```markdown
# Migration Report: v1.2.0 → v1.3.0

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
```

**After showing report, ask user about cleanup using AskUserQuestion**:
```
AskUserQuestion:
  question: "Migration complete. Delete the original files from legacy locations?"
  header: "Cleanup"
  options:
    - "Yes, delete legacy files" - Remove thoughts/shared/research/ and thoughts/shared/plans/ directories
    - "No, keep them" - Preserve original files as reference
```

If user selects "Yes, delete legacy files":
```bash
rm -rf thoughts/shared/research/ thoughts/shared/plans/
git add thoughts/
git commit -m "chore: remove legacy document structure after v1.3.0 migration"
```

## Important Guidelines

- **Never force groupings** - Always ask user
- **Preserve originals** - Never delete source files
- **Show dry-run first** - Let user review before applying
- **Document decisions** - Generate clear upgrade report
- **Be conservative** - When unsure, ask user
