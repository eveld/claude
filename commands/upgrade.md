# Upgrade Plugin Version

Upgrade the workflows plugin from one version to another, handling both automated migrations and edge cases that require reasoning.

## Initial Response

When invoked, automatically detect versions and show upgrade path:
```
Workflows Plugin Upgrade

Detected current version: v1.2.0
Latest available version: v1.3.0 (from CHANGELOG.md)

Upgrade path: v1.2.0 → v1.3.0

Changes in v1.3.0:
- Feature-centric directory structure
- Changelog tracking system
- Milestone-based planning
- Agent orchestration

Proceed with upgrade? [Yes/Cancel]
```

**No parameters needed**: Command automatically upgrades to latest version from CHANGELOG.md

## Workflow

### Step 1: Detect Current and Target Versions
- **Create version file if missing**:
  - If `migrations/version.txt` doesn't exist, create it
  - Detect from indicators: `thoughts/shared/` exists = v1.2.0, else = v1.3.0
  - If already on v1.3.0, exit with "Already on latest version"
- **Read current version**: Parse `current:` from `migrations/version.txt`
- **Validate version against indicators**:
  - If file says v1.2.0 but `thoughts/NNNN-*/` directories exist, ask user:
    ```
    Your installation state is unclear:
    - Version file says v1.2.0
    - But feature directories exist (v1.3.0+ pattern)

    Did you manually migrate or create feature directories?
    Options:
    1. Assume v1.3.0 (skip migration)
    2. Re-detect from indicators
    3. Cancel and let me investigate
    ```
  - If file says v1.3.0 but `thoughts/shared/` exists, that's OK (backward compatible)
- **Read target version**: Latest version from CHANGELOG.md (first `## [X.Y.Z]` entry)
- **Show upgrade path**: "Current: v1.2.0, Target: v1.3.0"
- **Context**: Read `migrated_from:` line for upgrade report

### Step 2: Calculate Version Delta
- Read version-specific upgrade definitions
- Determine what changed between versions:
  - **v1.2.0 → v1.3.0**: Directory structure, changelog system, milestones, agents
  - **v1.3.0 → v1.4.0** (future): [whatever changes in that version]
- Identify specific migrations needed for this delta
- Show user what will change:
  ```
  Upgrading from v1.2.0 to v1.3.0:

  Changes in v1.3.0:
  - New directory structure (thoughts/NNNN-description/)
  - Changelog tracking system
  - Milestone-based planning
  - Agent orchestration patterns

  Your installation needs:
  - Migrate 15 documents from thoughts/shared/
  - No changelog or milestone updates (those are for new plans)
  ```

### Step 3: Analyze What Needs Upgrading
- Scan for documents in old format
- Identify edge cases:
  - Documents with non-standard frontmatter
  - Documents that should be grouped together
  - Cross-references that need updating
  - Related research and plans
- Count total migrations needed

### Step 4: Run Automated Scripts
- Use helper scripts for standard cases
- For v1.2 → v1.3: Run `scripts/migrate-thoughts.sh --dry-run`
- Show what will be migrated automatically
- Present statistics: X documents, Y feature directories

### Step 5: Identify Manual Cases
- Find documents that need human judgment:
  - Should these 3 research docs be grouped into one feature?
  - This plan references removed files - update or leave?
  - Custom frontmatter fields - preserve or standardize?
- Present findings to user with recommendations

### Step 6: Propose Groupings
- Use research topics to suggest feature groupings
- Example: "Found 2 research docs and 1 plan about authentication - group as `0005-authentication`?"
- Use AskUserQuestion for decisions

### Step 7: Apply Changes
- Run automated migrations
- Apply user-approved manual changes
- Update frontmatter
- Fix cross-references
- Preserve original files

### Step 8: Generate Report
- List what was migrated
- Show new directory structure
- Note any issues or recommendations
- Suggest cleanup (optional deletion of old files)

## Migration System

The command reads CHANGELOG.md to understand version changes and migration steps.

### File Structure
```
CHANGELOG.md              # Standard changelog with migration sections
migrations/
├── version.txt           # Tracks installed version
└── scripts/              # Optional automated migration scripts
    └── v1.2-to-v1.3.sh
```

### CHANGELOG.md Format

Standard Keep a Changelog format with added Migration section:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-02-03

### Added
- Feature-centric directory structure (`thoughts/NNNN-description/`)
- Changelog tracking system (`changelog.md` per feature)
- Milestone grouping in implementation plans
- Agent orchestration for context window management
- New skills: `determine-feature-slug`, `update-changelog`, `spawn-implementation-agents`
- New agent: `test-writer` for isolated test generation
- New templates: `changelog-document.md`

### Changed
- Document-writing skills now create feature directories instead of shared/
- Commands support both old and new directory structures
- Plan template includes milestone sections
- Implement command uses agent orchestration pattern

### Migration

**From v1.2.0 to v1.3.0:**

1. **Automated**: Run `/workflows:upgrade`
2. **Analysis**: Claude analyzes documents in `thoughts/shared/`
3. **Grouping**: Claude proposes groupings for related research/plans
4. **Review**: User reviews and approves groupings
5. **Migration**: Standard documents migrated automatically
6. **Edge cases**: Claude handles cross-references and custom frontmatter
7. **Preservation**: Original files remain in `thoughts/shared/`

**Version detection:**
- v1.2.0: `thoughts/shared/` exists, no `thoughts/NNNN-*/` directories
- v1.3.0: `thoughts/NNNN-*/` directories exist, `changelog-document.md` template exists

**Breaking changes:** None (backward compatible)

**Rollback:** Not needed - old structure continues working

## [1.2.2] - 2026-02-03

### Removed
- Verification section from PR description template

## [1.2.1] - 2026-02-03

### Added
- Extracted PR description template to `templates/pr-description.md`
- Extracted commit message template to `templates/commit-message.md`

### Changed
- `write-pr-description` skill now references template file
- `write-commit-message` skill now references template file
```

### How It Works

**Claude reads CHANGELOG.md like a human would:**

1. **Detects current version** (from `migrations/version.txt` or by checking directory structure)
2. **Finds releases** between current and target version in CHANGELOG.md
3. **Reads Migration sections** - plain markdown instructions
4. **Interprets and executes** steps using reasoning
5. **Updates version marker** after successful upgrade

**Example**: Upgrading from v1.2.0 to v1.3.0

```
Claude reads CHANGELOG.md:

## [1.3.0] - 2026-02-03
### Migration
1. Run `/workflows:upgrade`
2. Claude analyzes documents in `thoughts/shared/`
3. Claude proposes groupings for related research/plans
4. User reviews and approves groupings
5. Standard documents migrated automatically
...

Claude executes:
✓ Step 1: Already running
✓ Step 2: Scanning thoughts/shared/ ... found 15 documents
✓ Step 3: Proposing groupings ... [shows proposals]
⏸ Step 4: Waiting for user approval
```

**No JSON parsing, no complex logic** - just Claude reading and following markdown instructions like a human would.

### Benefits

- **Standard format**: Uses Keep a Changelog conventions
- **Human readable**: CHANGELOG.md is primary documentation
- **Flexible**: Claude interprets migration steps, not rigid JSON
- **Transparent**: User can read CHANGELOG to understand changes
- **Extensible**: Add new versions easily
- **Incremental**: Can upgrade across multiple versions

## Version-Specific Upgrades

### v1.2.0 → v1.3.0: Directory Structure

**What changes**:
- `thoughts/shared/research/*.md` → `thoughts/NNNN-description/research.md`
- `thoughts/shared/plans/*.md` → `thoughts/NNNN-description/plan.md`
- Frontmatter adds `feature_slug` field
- New templates, skills, and agents added

**Automated**:
- Standard documents with proper frontmatter
- Single research or plan docs

**Requires reasoning**:
- Multiple related documents (grouping decision)
- Documents with cross-references
- Non-standard frontmatter

### Future Upgrades

Add new entries to CHANGELOG.md:
- Template format changes
- New frontmatter fields
- Breaking changes to conventions
- Tool/agent restructuring

Command automatically handles new upgrade paths based on the definition file.

## Important Notes

- Always preserve original files
- Show dry-run preview before applying
- Use TodoWrite to track upgrade progress
- Generate upgrade report for user review
