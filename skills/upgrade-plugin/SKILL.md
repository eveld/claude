---
name: upgrade-plugin
description: Generic migration orchestrator that reads CHANGELOG.md to understand and execute version-specific migrations
---

# Upgrade Plugin

Orchestrate project-level migrations by reading CHANGELOG.md as the single source of truth for migration steps.

## When to Use

Called by `/workflows:upgrade` command to handle the upgrade process.

## How It Works

### 1. Detect Current Version

Read `thoughts/.version` in the project directory:
```
current: v1.2.2
migrated_from: v1.2.1
migration_date: 2026-02-03
```

If file doesn't exist, detect from directory structure and create it.

### 2. Read CHANGELOG

Read `CHANGELOG.md` from the plugin directory to understand:
- What changed in the target version
- Migration steps required
- Version detection patterns
- What to ask the user

The CHANGELOG contains all version-specific migration logic.

### 3. Execute Migration

Follow the migration steps described in CHANGELOG:
- Ask user questions using AskUserQuestion (for groupings, edge cases, cleanup)
- Copy/move files as described
- Update cross-references
- Preserve originals until user confirms cleanup

### 4. Update Version File

After successful migration, update `thoughts/.version`:
```
current: v1.3.0
migrated_from: v1.2.2
migration_date: 2026-02-04
```

## Key Principles

- **CHANGELOG is source of truth** - All version-specific logic lives there
- **Project-level tracking** - Each project has its own `thoughts/.version`
- **Ask, don't assume** - Use AskUserQuestion for all decisions
- **Preserve data** - Never delete without user confirmation
- **Generate reports** - Show what was done after migration

## Example Workflow

```
1. User runs /workflows:upgrade
2. Skill reads thoughts/.version → "v1.2.2"
3. Skill reads CHANGELOG.md → finds v1.3.0 migration section
4. Skill follows migration steps from CHANGELOG
5. Skill asks user questions via AskUserQuestion
6. Skill executes migration
7. Skill updates thoughts/.version → "v1.3.0"
8. Skill generates report
```

This design means the skill never needs updating - only CHANGELOG changes per version.
