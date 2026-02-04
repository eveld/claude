# Plugin Restructuring and Improvements Implementation Plan

## Overview

Restructure the workflows plugin to support feature-centric directory organization, implement changelog tracking with auto-correction loops, add milestone grouping to plans, and introduce aggressive agent orchestration for context window management. This delivers the full vision from research document `thoughts/shared/0001-plugin-restructuring/research.md`.

## Current State Analysis

**Directory Structure**: Currently uses flat, shared directory structure:
- `thoughts/shared/research/YYYY-MM-DD-NN-description.md` - Research documents
- `thoughts/shared/plans/YYYY-MM-DD-NN-description.md` - Implementation plans
- `thoughts/notes/commands.md` - Project-wide command reference
- `thoughts/notes/testing.md` - Project-wide test patterns

**Path References**: Hardcoded in multiple locations:
- Commands: `commands/research.md:41`, `commands/plan.md:62`, `commands/implement.md:15`
- Skills: `skills/write-research-doc/SKILL.md:39`, `skills/write-plan-doc/SKILL.md:26`
- Templates: `templates/plan-document.md:24-25`
- Agents: `agents/thoughts-locator.md:12`, `agents/thoughts-analyzer.md`

**Workflow Limitations**:
- No post-implementation documentation (changelog)
- No milestone grouping in plans (just sequential phases)
- No explicit context window management (phases can exceed 200k limit)
- No agent orchestration guidance for implementation

**Recent Changes**:
- v1.2.1: Extracted PR and commit templates to separate files
- v1.2.2: Removed verification section from PR template

## Desired End State

**New Directory Structure**:
```
thoughts/
├── 0001-feature-name/
│   ├── plan.md
│   ├── research.md
│   ├── changelog.md
│   └── notes.md
├── 0002-another-feature/
│   └── ...
└── notes/
    ├── commands.md
    └── testing.md
```

**Feature Slug Format**: `NNNN-description` where:
- `NNNN` = Zero-padded running number (0001, 0002, etc.)
- `description` = Kebab-case feature description

**Dual Path Support**: All commands and skills work with both old and new structures during transition period.

**Changelog System**:
- Single `changelog.md` per feature for tracking + summary
- Read before each phase for auto-correction
- Updated after each phase with deviations
- Final summary appended at completion

**Milestone Grouping**: Plans group phases into testable milestones with user-facing outcomes.

**Agent Orchestration**:
- Main agent stays <40k tokens per phase
- Total system <100k tokens per phase
- Sub-agents handle file reading, pattern finding, test generation, verification
- 60% token reduction per phase enables larger, more complex phases

### Key Discoveries:

- Research document identifies 13 files with hardcoded `thoughts/shared` or `thoughts/notes` paths (research:2026-02-03-01:lines 760-823)
- Current phase structure has no token tracking or size constraints (research:2026-02-03-01:lines 176-195)
- Changelog enables auto-correction loop - agent adapts based on previous phase deviations (research:2026-02-03-01:lines 379-510)
- Sub-agent orchestration reduces main agent tokens from ~92k to ~38k per phase (research:2026-02-03-01:lines 222-314)
- Feature directory structure already researched with running number format selected (research:2026-02-03-01:lines 90-130)

## What We're NOT Doing

- **NOT forcing automatic migration** - Migration script is optional tool, doesn't run automatically
- **NOT removing old documents during migration** - Script preserves originals in shared/
- **NOT changing thoughts/notes/ location** - Project-wide references stay where they are
- **NOT removing old path support** - Dual support maintained indefinitely for backward compatibility
- **NOT adding UI/CLI for slug management** - File-based workflow only
- **NOT implementing token counting** - Just provide guidelines and agent patterns
- **NOT enforcing phase size limits** - Guidance only, not hard constraints

## Implementation Approach

**Three-milestone delivery**:

1. **Foundation** (Milestone 1) - New directory structure with backward compatibility
   - Create slug determination infrastructure
   - Update all document-writing skills
   - Update all commands for dual path support
   - Update templates and agents
   - Create optional migration script

2. **Enhanced Planning** (Milestone 2) - Changelog and milestone improvements
   - Create changelog template and update skill
   - Integrate changelog into implement workflow
   - Add milestone structure to plan templates

3. **Context Management** (Milestone 3) - Agent orchestration for token efficiency
   - Create agent orchestration guide
   - Create test-writer agent
   - Update implement command with agent steps
   - Update verification to always use agents

**Backward Compatibility Strategy**:
- All skills check new location first, fall back to old
- Commands accept both path formats
- Agents search both directory structures
- Old documents continue working without modification

**Interactive Slug Determination**:
- Auto-detect next number from existing directories
- Auto-suggest description from research question/plan title
- Prompt user to accept or modify suggestion
- Create feature directory automatically

## Project References

- Commands: See `thoughts/notes/commands.md` (will be created if missing)
- Test Patterns: See `thoughts/notes/testing.md` (will be created if missing)

---

## Milestone 1: Foundation - New Directory Structure

**Goal**: Support feature-centric directory organization with backward compatibility
**Testable**: Can create new research/plans in feature directories while old structure still works

### Phase 1.1: Create Slug Determination Infrastructure

#### Overview
Create the foundational skill that determines feature slugs interactively, combining automatic numbering with user-provided descriptions.

#### Changes Required

##### 1. Create Slug Determination Skill
**File**: `skills/determine-feature-slug/SKILL.md`
**Changes**: New file defining the interactive slug determination workflow

```markdown
---
name: determine-feature-slug
description: Determine feature slug interactively by auto-detecting next number and prompting user for description
---

# Determine Feature Slug

Interactively determine the next feature slug for the thoughts directory structure.

## How It Works

1. **Find Next Number**:
   - Scan `thoughts/` directory for existing feature directories
   - Pattern: `^[0-9]{4}-.*`
   - Find highest number and add 1
   - Default to 0001 if no features exist

2. **Suggest Description**:
   - From research question: Extract key terms, convert to kebab-case
   - From plan title: Extract feature name, convert to kebab-case
   - Fallback: Prompt without suggestion

3. **Prompt User**:
   - Show suggested slug: "Next slug: 0004-authentication-system"
   - Ask: "Accept this slug or provide custom description?"
   - Validate: Only lowercase letters, numbers, hyphens

4. **Return Result**:
   - Format: `NNNN-description`
   - Create directory: `thoughts/NNNN-description/`

## Example Usage

```bash
# Auto-detect and suggest
NEXT_NUM=$(ls -1 thoughts/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1)
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM:-0} + 1)))

# Suggest from context (research question, plan title)
SUGGESTED_DESC=$(echo "$RESEARCH_QUESTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

# Prompt user
echo "Suggested slug: ${NEXT_NUM}-${SUGGESTED_DESC}"
echo "Press Enter to accept, or type custom description:"
read USER_DESC
DESC=${USER_DESC:-$SUGGESTED_DESC}

# Create directory
mkdir -p "thoughts/${NEXT_NUM}-${DESC}"
echo "${NEXT_NUM}-${DESC}"
```

## Validation

- Number must be 4 digits, zero-padded
- Description must be kebab-case (lowercase, hyphens only)
- Directory must not already exist
- Description length: 3-50 characters
```

##### 2. Update README Documentation
**File**: `README.md`
**Changes**: Document new directory structure

Add section after line 25:
```markdown
### Directory Structure (v1.3.0+)

Starting with v1.3.0, documents are organized by feature:

```
thoughts/
├── 0001-feature-name/      # Feature-centric organization
│   ├── plan.md              # Implementation plan
│   ├── research.md          # Research findings
│   ├── changelog.md         # Implementation tracking
│   └── notes.md             # Ad-hoc observations
├── 0002-another-feature/
│   └── ...
├── notes/                   # Project-wide references
│   ├── commands.md          # Available commands
│   └── testing.md           # Test patterns
└── shared/                  # Legacy structure (still supported)
    ├── research/
    └── plans/
```

**Backward Compatibility**: Old `thoughts/shared/` structure continues to work.
```

##### 3. Create Helper Script
**File**: `scripts/next-feature-slug.sh`
**Changes**: New script for slug determination logic

```bash
#!/usr/bin/env bash
set -euo pipefail

# Find next feature number
NEXT_NUM=$(ls -1 thoughts/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1 || echo "0000")
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM} + 1)))

# Get suggested description from argument or prompt
SUGGESTED="${1:-}"
if [ -z "$SUGGESTED" ]; then
    echo "Next feature number: $NEXT_NUM"
    read -p "Enter feature description (kebab-case): " SUGGESTED
fi

# Validate and normalize description
DESC=$(echo "$SUGGESTED" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

if [ -z "$DESC" ]; then
    echo "Error: Description cannot be empty" >&2
    exit 1
fi

if [ ${#DESC} -lt 3 ] || [ ${#DESC} -gt 50 ]; then
    echo "Error: Description must be 3-50 characters" >&2
    exit 1
fi

# Output slug
echo "${NEXT_NUM}-${DESC}"
```

#### Success Criteria

##### Automated Verification:
- [ ] Script exists and is executable: `test -x scripts/next-feature-slug.sh`
- [ ] Script returns valid slug format: `scripts/next-feature-slug.sh test-feature | grep -E '^[0-9]{4}-[a-z0-9-]+$'`
- [ ] Skill file validates: `test -f skills/determine-feature-slug/SKILL.md`

##### Manual Verification:
- [ ] Run skill with research question context - suggests relevant description
- [ ] Accept suggested description - creates correct directory
- [ ] Provide custom description - creates directory with custom name
- [ ] Run twice in a row - increments number correctly

---

### Phase 1.2: Update Document-Writing Skills

#### Overview
Update write-research-doc and write-plan-doc skills to use new path structure, calling determine-feature-slug first.

#### Changes Required

##### 1. Update Write Research Doc Skill
**File**: `skills/write-research-doc/SKILL.md`
**Changes**: Use new path pattern with feature slugs

Replace lines 37-46 (File Path and Naming section):
```markdown
## File Path and Naming

Determine feature slug first using `determine-feature-slug` skill:
- Auto-detects next number (0001, 0002, etc.)
- Suggests description from research question
- Prompts user to accept or customize

Save to: `thoughts/NNNN-description/research.md`

Example workflow:
1. User provides research question: "How does authentication work?"
2. Skill suggests: `0005-authentication`
3. User accepts or modifies
4. Document saved to: `thoughts/0005-authentication/research.md`

**Backward compatibility**: Old path `thoughts/shared/research/YYYY-MM-DD-NN-description.md` still recognized by all commands.
```

Update frontmatter section (after line 15):
```markdown
1. **Frontmatter** (YAML):
   - date, researcher, git info, topic, tags, status
   - **NEW**: feature_slug (e.g., "0005-authentication")
```

##### 2. Update Write Plan Doc Skill
**File**: `skills/write-plan-doc/SKILL.md`
**Changes**: Use new path pattern with feature slugs

Replace lines 24-34 (File Path and Naming section):
```markdown
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
```

##### 3. Update Gather Project Metadata Skill
**File**: `skills/gather-project-metadata/SKILL.md`
**Changes**: Add feature_slug to gathered metadata

Add to "What to Gather" section (after line 12):
```markdown
- Feature slug (if in feature directory context)
```

Add to bash collection script (after line 28):
```markdown
# Feature slug (if applicable)
FEATURE_DIR=$(pwd | grep -oE 'thoughts/[0-9]{4}-[^/]+' || echo "")
if [ -n "$FEATURE_DIR" ]; then
    basename "$FEATURE_DIR"
fi
```

Add to template variables (after line 45):
```markdown
- `{FEATURE_SLUG}` - Feature slug (e.g., "0005-authentication")
```

#### Success Criteria

##### Automated Verification:
- [ ] Skills reference determine-feature-slug: `grep -l "determine-feature-slug" skills/write-*/SKILL.md | wc -l | grep 2`
- [ ] Skills document new paths: `grep -l "thoughts/NNNN-description" skills/write-*/SKILL.md | wc -l | grep 2`
- [ ] Backward compatibility documented: `grep -l "Backward compatibility" skills/write-*/SKILL.md | wc -l | grep 2`

##### Manual Verification:
- [ ] write-research-doc creates file in feature directory with correct structure
- [ ] write-plan-doc can reuse existing feature directory from research
- [ ] write-plan-doc can create new feature directory for standalone plans
- [ ] Metadata includes feature_slug in frontmatter

---

### Phase 1.3: Update Commands for Dual Path Support

#### Overview
Update research, plan, and implement commands to check both old and new directory structures, with new structure taking precedence.

#### Changes Required

##### 1. Update Research Command
**File**: `commands/research.md`
**Changes**: Use new path pattern and document dual support

Update Step 6 (lines 39-41):
```markdown
### Step 6: Write Document
- Use `determine-feature-slug` skill to get feature slug
- Use the `write-research-doc` skill to create properly structured document
- File path: `thoughts/NNNN-description/research.md` (new structure)
- Old structure `thoughts/shared/research/YYYY-MM-DD-NN-description.md` still supported
```

##### 2. Update Plan Command
**File**: `commands/plan.md`
**Changes**: Support both paths, prefer feature directories

Update Step 1 (lines 7-9):
```markdown
## Initial Response

Check if parameters were provided:
- If file path provided: Read FULLY and check format
  - New format: `thoughts/NNNN-description/research.md`
  - Old format: `thoughts/shared/research/YYYY-MM-DD-NN-*.md`
- If no parameters: Show usage message and wait
```

Update usage message (lines 12-18):
```markdown
Usage message:
```
I'll help you create a detailed implementation plan. Please provide:
1. The task/ticket description (or path to research/ticket file)
2. Any relevant context or requirements
3. Links to related research

Tip: You can invoke with a file: `/plan thoughts/0005-authentication/research.md`
Tip: Old paths also work: `/plan thoughts/shared/research/2026-02-03-01-auth.md`
```
```

Update Step 9 (lines 60-63):
```markdown
### Step 9: Write Plan
- Use `determine-feature-slug` skill to get/create feature slug
  - If from existing research doc: Use same slug (reuse directory)
  - If new: Prompt for new slug
- Use `write-plan-doc` skill to create structured plan
- File path: `thoughts/NNNN-description/plan.md` (new structure)
- Old structure paths still supported for reading
- Reference templates for structure
```

##### 3. Update Implement Command
**File**: `commands/implement.md`
**Changes**: Find plans in either location

Update Step 1 (lines 7-9):
```markdown
## Initial Response

Check if parameters were provided:
- If plan file provided: Detect format and read FULLY
  - New format: `thoughts/NNNN-description/plan.md`
  - Old format: `thoughts/shared/plans/YYYY-MM-DD-NN-*.md`
- If no parameters: Show usage message and wait
```

Update usage message (lines 12-15):
```markdown
Usage message:
```
I'll help you implement an approved plan. Please provide the path to the plan file.

Example (new format): `/implement thoughts/0005-authentication/plan.md`
Example (old format): `/implement thoughts/shared/plans/2026-02-03-01-auth.md`
```
```

#### Success Criteria

##### Automated Verification:
- [ ] Commands document both path formats: `grep -l "thoughts/NNNN-description" commands/*.md | wc -l | grep 3`
- [ ] Commands mention old format support: `grep -l "Old format\|old structure\|still supported" commands/*.md | wc -l | grep 3`
- [ ] Commands call determine-feature-slug: `grep -l "determine-feature-slug" commands/*.md | wc -l | grep 2`

##### Manual Verification:
- [ ] `/workflows:research` creates document in feature directory
- [ ] `/workflows:plan` with research file reuses same feature directory
- [ ] `/workflows:plan` without research creates new feature directory
- [ ] `/workflows:implement` works with both old and new plan paths
- [ ] Error messages mention both possible path formats

---

### Phase 1.4: Update Templates and Agents

#### Overview
Update templates to include feature_slug in frontmatter, update agents to search both old and new directory structures.

#### Changes Required

##### 1. Update Research Document Template
**File**: `templates/research-document.md`
**Changes**: Add feature_slug to frontmatter

Update frontmatter section (lines 1-12):
```yaml
---
date: {ISO_TIMESTAMP}
researcher: {RESEARCHER_NAME}
git_commit: {GIT_COMMIT}
branch: {BRANCH_NAME}
repository: {REPOSITORY}
feature_slug: {FEATURE_SLUG}
topic: "{RESEARCH_TOPIC}"
tags: [research, codebase, {TAGS}]
status: complete
last_updated: {DATE}
last_updated_by: {RESEARCHER_NAME}
---
```

##### 2. Update Plan Document Template
**File**: `templates/plan-document.md`
**Changes**: Add feature_slug as comment at top

Add after line 1:
```markdown
# {FEATURE_NAME} Implementation Plan

<!-- Feature: {FEATURE_SLUG} -->
<!-- Created: {ISO_TIMESTAMP} -->
```

##### 3. Update Thoughts-Locator Agent
**File**: `agents/thoughts-locator.md`
**Changes**: Search both feature directories and shared directories

Update Directory Structure section (lines 35-48):
```markdown
### Directory Structure
```
thoughts/
├── 0001-feature-name/  # NEW: Feature-centric directories
│   ├── plan.md
│   ├── research.md
│   ├── changelog.md
│   └── notes.md
├── 0002-another/
│   └── ...
├── notes/              # Project-wide references
│   ├── commands.md
│   └── testing.md
├── shared/             # LEGACY: Old structure (still supported)
│   ├── research/       # Old research documents
│   ├── plans/          # Old implementation plans
│   ├── tickets/        # Ticket documentation
│   └── prs/            # PR descriptions
└── searchable/         # Read-only search directory (contains all above)
```
```

Update Search Strategy section (after line 33):
```markdown
### Search Strategy

**Priority order**:
1. Feature directories first: `thoughts/NNNN-*/`
2. Legacy shared directories: `thoughts/shared/`
3. Project-wide notes: `thoughts/notes/`
4. Searchable (if needed): `thoughts/searchable/`

**Search patterns**:
- Feature dirs: Check `plan.md`, `research.md`, `changelog.md`, `notes.md`
- Shared dirs: Check timestamped files `YYYY-MM-DD-NN-*.md`
- Use grep for content, glob for filenames
```

Update Output Format section (lines 66-90) - add feature directory section:
```markdown
## Output Format

Structure your findings like this:

```
## Thought Documents about [Topic]

### Feature Directories
- `thoughts/0005-authentication/plan.md` - Implementation plan for auth system
- `thoughts/0005-authentication/research.md` - Research on auth patterns
- `thoughts/0012-rate-limiting/research.md` - Related rate limiting research

### Tickets (Legacy)
- `thoughts/shared/tickets/eng_1234.md` - Implement rate limiting for API

### Research Documents (Legacy)
- `thoughts/shared/research/2024-01-15-01-rate-limiting-approaches.md` - Research on strategies

[rest of sections...]

Total: 8 relevant documents found
```
```

##### 4. Update Thoughts-Analyzer Agent
**File**: `agents/thoughts-analyzer.md`
**Changes**: Handle both directory structures in analysis

Update Step 1 (after line 31):
```markdown
### Step 1: Read with Purpose
- Read the entire document first
- Identify the document's format:
  - **New format**: `thoughts/NNNN-description/*.md` with feature_slug in frontmatter
  - **Old format**: `thoughts/shared/*/*.md` with timestamped filenames
- Identify the document's main goal
- Note the date and context
- Understand what question it was answering
- Take time to ultrathink about the document's core value
```

Update Document Context section in Output Format (lines 60-65):
```markdown
### Document Context
- **Path**: [Full path including feature slug or shared/ location]
- **Feature**: [Feature slug if new format, or "Legacy" if old format]
- **Date**: [When written]
- **Purpose**: [Why this document exists]
- **Status**: [Is this still relevant/implemented/superseded?]
```

#### Success Criteria

##### Automated Verification:
- [ ] Templates include feature_slug: `grep -l "FEATURE_SLUG" templates/*.md | wc -l | grep 2`
- [ ] Agents document new structure: `grep -l "0001-feature\|NNNN-" agents/thoughts-*.md | wc -l | grep 2`
- [ ] Agents search both locations: `grep -l "shared/\|Legacy" agents/thoughts-*.md | wc -l | grep 2`

##### Manual Verification:
- [ ] thoughts-locator finds documents in both feature directories and shared/
- [ ] thoughts-locator groups results by location type
- [ ] thoughts-analyzer extracts feature_slug from new format documents
- [ ] thoughts-analyzer notes "Legacy" for old format documents
- [ ] Generated documents include feature_slug in frontmatter

---

### Phase 1.5: Create Upgrade Command

#### Overview
Create `/workflows:upgrade` command that intelligently migrates old documents to new structure, handling edge cases and proposing changes for user review. Extensible for future version upgrades.

#### Changes Required

##### 1. Create Upgrade Command
**File**: `commands/upgrade.md`
**Changes**: New command for version-to-version upgrades

```markdown
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

### Step 3: Run Automated Scripts
- Use helper scripts for standard cases
- For v1.2 → v1.3: Run `scripts/migrate-thoughts.sh --dry-run`
- Show what will be migrated automatically
- Present statistics: X documents, Y feature directories

### Step 4: Identify Manual Cases
- Find documents that need human judgment:
  - Should these 3 research docs be grouped into one feature?
  - This plan references removed files - update or leave?
  - Custom frontmatter fields - preserve or standardize?
- Present findings to user with recommendations

### Step 5: Propose Groupings
- Use research topics to suggest feature groupings
- Example: "Found 2 research docs and 1 plan about authentication - group as `0005-authentication`?"
- Use AskUserQuestion for decisions

### Step 6: Apply Changes
- Run automated migrations
- Apply user-approved manual changes
- Update frontmatter
- Fix cross-references
- Preserve original files

### Step 7: Generate Report
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
├── current-version.txt   # Tracks installed version
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

1. **Detects current version** (from `migrations/current-version.txt` or by checking directory structure)
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
```

##### 2. Create Upgrade Skill
**File**: `skills/upgrade-plugin/SKILL.md`
**Changes**: New skill for upgrade reasoning

```markdown
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
```

##### 3. Create CHANGELOG.md
**File**: `CHANGELOG.md`
**Changes**: Standard changelog with migration instructions

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
- Upgrade command: `/workflows:upgrade` for version migrations

### Changed
- Document-writing skills now create feature directories
- Commands support both old (`thoughts/shared/`) and new directory structures
- Plan template includes milestone sections
- Implement command uses agent orchestration to conserve context

### Migration

**To upgrade from v1.2.0 to v1.3.0:**

1. Run `/workflows:upgrade` (detects v1.2.0 → v1.3.0 automatically)

2. Claude will analyze your `thoughts/shared/` directory:
   - Count research and plan documents
   - Identify related documents by topic/date
   - Propose groupings (e.g., "auth research + auth plan → 0005-authentication")

3. Review proposed groupings:
   - Accept suggested groupings
   - Modify feature names if desired
   - Decide on standalone vs grouped features

4. Claude migrates documents:
   - Create feature directories with slugs (0001, 0002, etc.)
   - Copy documents (originals preserved)
   - Update frontmatter with `feature_slug`
   - Fix cross-references to new paths

5. Verify migration:
   - Check new feature directories
   - Test commands with new paths
   - Optionally delete `thoughts/shared/` after verification

**Version detection:**
- v1.2.0: `thoughts/shared/` exists, no feature directories
- v1.3.0: `thoughts/NNNN-*/` directories exist

**Breaking changes:** None - backward compatible

## [1.2.2] - 2026-02-03

### Removed
- Verification section from PR description template

### Migration
No migration needed - documentation change only.

## [1.2.1] - 2026-02-03

### Added
- Extracted PR description template to `templates/pr-description.md`
- Extracted commit message template to `templates/commit-message.md`

### Changed
- `write-pr-description` skill references template file
- `write-commit-message` skill references template file

### Migration
No migration needed - templates extracted, skills updated automatically.
```

##### 4. Create Version Tracking File
**File**: `migrations/version.txt`
**Changes**: Track current version and migration source

**Format**:
```
current: v1.3.0
migrated_from: v1.2.0
```

**Fresh install**:
```
current: v1.3.0
migrated_from: none
```

**Creation logic** (in `/workflows:upgrade` command only):
```bash
# Step 1: Create version file if it doesn't exist
if [ ! -f migrations/version.txt ]; then
  mkdir -p migrations
  if [ -d thoughts/shared/research ] || [ -d thoughts/shared/plans ]; then
    # Existing v1.2 user - needs migration
    printf "current: v1.2.0\nmigrated_from: none\n" > migrations/version.txt
  else
    # Fresh v1.3 install - no migration needed
    printf "current: v1.3.0\nmigrated_from: none\n" > migrations/version.txt
    echo "Already on v1.3.0. No upgrade needed."
    exit 0
  fi
fi

# Step 2: Read current version
current=$(grep "^current:" migrations/version.txt | cut -d' ' -f2)
```

**Note**: File only created when user runs `/workflows:upgrade`. Other commands don't need it.

##### 5. Create Helper Migration Script
**File**: `scripts/migrate-thoughts.sh`
**Changes**: Helper script for standard migrations (used by upgrade command)

```bash
#!/usr/bin/env bash
# Helper script for standard document migrations
# Called by /workflows:upgrade command for automated cases

set -euo pipefail

DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

# Find next feature number
next_feature_num() {
    local next=$(ls -1 thoughts/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1 || echo "0000")
    printf "%04d" $((10#${next} + 1))
}

# Extract description from old filename
extract_description() {
    echo "$1" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-//;s/\.md$//'
}

# Migrate single document
migrate_doc() {
    local old_path="$1"
    local doc_type="$2"
    local feature_num=$(next_feature_num)
    local desc=$(extract_description "$(basename "$old_path")")
    local feature_dir="thoughts/${feature_num}-${desc}"

    echo "Migrating: $old_path → ${feature_dir}/${doc_type}.md"

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$feature_dir"
        cp "$old_path" "${feature_dir}/${doc_type}.md"
        # Add feature_slug to frontmatter
        sed -i.bak "2a\\
feature_slug: ${feature_num}-${desc}" "${feature_dir}/${doc_type}.md"
        rm "${feature_dir}/${doc_type}.md.bak"
    fi
}

# Main migration
for doc in thoughts/shared/research/*.md 2>/dev/null; do
    [ -f "$doc" ] && migrate_doc "$doc" "research"
done

for doc in thoughts/shared/plans/*.md 2>/dev/null; do
    [ -f "$doc" ] && migrate_doc "$doc" "plan"
done

[ "$DRY_RUN" = true ] && echo "Dry run complete. Run without --dry-run to apply."
```

##### 6. Update README
**File**: `README.md`
**Changes**: Document upgrade command

Add to Commands section:
```markdown
### Upgrading Plugin Versions

Upgrade the workflows plugin to the latest version:

```bash
/workflows:upgrade

# Claude automatically:
# 1. Detects your current version
# 2. Finds latest version from CHANGELOG.md
# 3. Shows upgrade path and changes
# 4. Analyzes what needs upgrading
# 5. Groups related documents intelligently
# 6. Executes migration with your approval
# 7. Generates upgrade report
```

**What it handles**:
- Automatic version detection (current and target)
- Reading CHANGELOG.md for migration steps
- Intelligent grouping of related research/plans
- Cross-reference updates
- Edge case reasoning (custom frontmatter, orphaned docs)
- Preserves original files for safety

**Example - v1.2.0 → v1.3.0 Upgrade**:
- Migrates `thoughts/shared/` documents to feature directories
- Adds `feature_slug` to frontmatter
- Groups related research and plans
- Updates cross-references to new paths
```

#### Success Criteria

##### Automated Verification:
- [ ] Command file exists: `test -f commands/upgrade.md`
- [ ] Skill file exists: `test -f skills/upgrade-plugin/SKILL.md`
- [ ] CHANGELOG exists: `test -f CHANGELOG.md`
- [ ] CHANGELOG has v1.3.0 entry: `grep -q "## \[1.3.0\]" CHANGELOG.md`
- [ ] CHANGELOG has Migration section: `grep -q "### Migration" CHANGELOG.md`
- [ ] Version file exists: `test -f migrations/version.txt`
- [ ] Version has current field: `grep -q "^current:" migrations/version.txt`
- [ ] Version has migrated_from field: `grep -q "^migrated_from:" migrations/version.txt`
- [ ] Helper script exists and is executable: `test -x scripts/migrate-thoughts.sh`
- [ ] Script validates: `bash -n scripts/migrate-thoughts.sh`

##### Manual Verification:
- [ ] `/workflows:upgrade` detects current version correctly
- [ ] Validates version against indicators (detects mismatches)
- [ ] Asks user when version file conflicts with directory structure
- [ ] Reads CHANGELOG.md and extracts migration steps
- [ ] Shows what changed between versions
- [ ] Analyzes documents and identifies grouping opportunities
- [ ] Proposes intelligent groupings for related documents
- [ ] Handles edge cases (custom frontmatter, cross-references)
- [ ] Runs automated script for standard cases
- [ ] Applies user-approved manual changes
- [ ] Updates `migrations/version.txt` after successful upgrade (current and migrated_from)
- [ ] Generates comprehensive upgrade report
- [ ] Preserves original files in thoughts/shared/
- [ ] CHANGELOG instructions are human-readable (can be followed manually)

---

## Milestone 2: Enhanced Planning - Changelog & Milestones

**Goal**: Add implementation tracking and milestone-based planning
**Testable**: Can track implementation progress in changelog.md and group phases into milestones

### Phase 2.1: Create Changelog Infrastructure

#### Overview
Create the changelog template and update-changelog skill to enable phase-by-phase implementation tracking with auto-correction.

#### Changes Required

##### 1. Create Changelog Document Template
**File**: `templates/changelog-document.md`
**Changes**: New template for combined tracking + summary

```markdown
# Implementation Changelog: {FEATURE_NAME}

**Feature**: `{FEATURE_SLUG}`
**Plan**: `thoughts/{FEATURE_SLUG}/plan.md`
**Started**: {ISO_TIMESTAMP}

---

## Phase {PHASE_NUM}: {PHASE_NAME}
**Completed**: {DATE}
**Status**: ✅ Complete / 🚧 In Progress / ❌ Blocked

### What We Did
- {SUMMARY_OF_ACTUAL_WORK}
- {WHAT_WAS_IMPLEMENTED}

### Deviations from Plan
- **Planned**: {WHAT_PLAN_SAID}
- **Actually**: {WHAT_WE_DID_INSTEAD}
- **Reason**: {WHY_WE_CHANGED_APPROACH}

### Files Changed
- `{FILE_PATH}` - {DESCRIPTION_OF_CHANGES}
- `{ANOTHER_FILE}` - {WHAT_CHANGED}

### Discoveries
- {UNEXPECTED_FINDING}
- {LEARNING_OR_GOTCHA}
- {PATTERN_WE_FOUND}

---

{REPEAT_FOR_EACH_PHASE}

---

## 🎯 FINAL SUMMARY
**Completion Date**: {DATE}
**Overall Status**: ✅ Complete / ⚠️ Partial / ❌ Incomplete

### What Was Built
{HIGH_LEVEL_SUMMARY_OF_DELIVERABLES}

### Key Deviations
1. {MAJOR_DEVIATION_1}
2. {MAJOR_DEVIATION_2}

### Impact on Original Plan
- Plan estimated {N} phases, completed {M}
- Added {X} files not in original plan
- Removed {Y} planned files - not needed

### Lessons Learned
- {KEY_LEARNING_1}
- {KEY_LEARNING_2}

### Technical Debt
- TODO: {DEBT_ITEM_1}
- TODO: {DEBT_ITEM_2}

### Follow-up Work
- {FUTURE_ENHANCEMENT_1}
- {FUTURE_ENHANCEMENT_2}

### References
- Original plan: `thoughts/{FEATURE_SLUG}/plan.md`
- Research: `thoughts/{FEATURE_SLUG}/research.md`
- Pull requests: {PR_URLS}
- Commits: {COMMIT_RANGE}
```

##### 2. Create Update Changelog Skill
**File**: `skills/update-changelog/SKILL.md`
**Changes**: New skill for appending to changelog

```markdown
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
```

#### Success Criteria

##### Automated Verification:
- [ ] Template file exists: `test -f templates/changelog-document.md`
- [ ] Skill file exists: `test -f skills/update-changelog/SKILL.md`
- [ ] Template has phase section: `grep -q "## Phase {PHASE_NUM}" templates/changelog-document.md`
- [ ] Template has final summary: `grep -q "FINAL SUMMARY" templates/changelog-document.md`

##### Manual Verification:
- [ ] Can create new changelog from template with feature info
- [ ] Can append phase section with all required fields
- [ ] Can append final summary section
- [ ] Phase sections include deviations in "Planned vs Actually" format
- [ ] Auto-correction workflow documented clearly

---

### Phase 2.2: Integrate Changelog into Implement Workflow

#### Overview
Update implement command and related skills to read changelog before phases and write after phases.

#### Changes Required

##### 1. Update Implement Command
**File**: `commands/implement.md`
**Changes**: Add changelog reading and writing steps

Update Step 1 (add after line 22):
```markdown
### Step 1: Read Plan
- Read plan file FULLY (no limit/offset)
- Detect format (feature directory or legacy)
- Check for existing checkboxes (may be partially complete)
- Understand all phases and success criteria
```

Update Step 2 (replace lines 25-32):
```markdown
### Step 2: Read Context Documents
- **Read changelog** if it exists: `thoughts/NNNN-description/changelog.md`
  - Understand what's been completed so far
  - Note deviations from previous phases
  - Adapt current phase based on actual state (auto-correction)
  - If changelog doesn't exist, this is the first phase

- Check if plan references `thoughts/notes/commands.md`
  - If yes and exists: Read it
  - If yes but doesn't exist: Use `discover-project-commands` skill, then read

- Check if plan references `thoughts/notes/testing.md`
  - If yes and exists: Read it
  - If yes but doesn't exist: Use `discover-test-patterns` skill, then read
```

Add new Step 7 (after current Step 6, renumber remaining):
```markdown
### Step 7: Update Changelog
- Use `update-changelog` skill to append phase completion
- Include:
  - What was actually done
  - Deviations from plan (planned vs actually, reason)
  - Files changed
  - Discoveries made during implementation
- If this was the last phase: Also append FINAL SUMMARY section
```

Update Step 8 (previously Step 6, now Step 8):
```markdown
### Step 8: Update Plan Checkboxes
- Mark checkboxes as complete in plan file
- Update as you complete each success criterion
```

Update Step 9 (previously Step 7, now Step 9):
```markdown
### Step 9: Handle Mismatches
- If plan doesn't match reality: STOP and ask user
- If previous phases changed approach: Adapt based on changelog
- Don't make assumptions or deviate without approval
```

##### 2. Update Write Plan Doc Skill
**File**: `skills/write-plan-doc/SKILL.md`
**Changes**: Mention changelog.md creation

Add to Document Structure section (after line 23):
```markdown
8. **Changelog** - Implementation tracking (created during implementation)
   - Not created by plan command
   - Implementation command creates and maintains it
   - Used for auto-correction loop
```

Add to Project References section (after line 70):
```markdown
### Changelog Reference

During implementation, a changelog will be created:
- `thoughts/NNNN-description/changelog.md` - Phase-by-phase tracking
- Read before each phase for auto-correction
- Updated after each phase with deviations
```

##### 3. Update README
**File**: `README.md`
**Changes**: Document changelog workflow

Add after Milestone 1 documentation (around line 35):
```markdown
### Implementation Tracking

During implementation, a changelog tracks actual progress:
- **Before each phase**: Agent reads `changelog.md` for auto-correction
- **After each phase**: Agent updates changelog with deviations
- **At completion**: Agent appends final summary

This auto-correction loop ensures later phases adapt to earlier changes.

Example:
```bash
/workflows:implement thoughts/0005-authentication/plan.md

# Agent reads plan.md + changelog.md before each phase
# Agent adapts based on what actually happened in previous phases
# Agent updates changelog.md after each phase
```
```

#### Success Criteria

##### Automated Verification:
- [ ] Implement command mentions changelog: `grep -c "changelog" commands/implement.md | grep -E "[3-9]|[1-9][0-9]"`
- [ ] Implement reads before phases: `grep -q "Read changelog.*if it exists" commands/implement.md`
- [ ] Implement writes after phases: `grep -q "update-changelog.*after.*phase" commands/implement.md`
- [ ] Write-plan-doc mentions changelog: `grep -q "changelog" skills/write-plan-doc/SKILL.md`

##### Manual Verification:
- [ ] Implement command reads changelog.md before starting each phase
- [ ] Implement command creates changelog.md if it doesn't exist
- [ ] Implement command appends phase section after completing phase
- [ ] Implement command appends final summary after last phase
- [ ] Auto-correction works: later phases adapt based on changelog deviations

---

### Phase 2.3: Add Milestone Structure to Plans

#### Overview
Update plan template and write-plan-doc skill to support milestone grouping of phases.

#### Changes Required

##### 1. Update Plan Document Template
**File**: `templates/plan-document.md`
**Changes**: Add milestone wrapper structure

Replace Phase sections (lines 29-59) with milestone structure:
```markdown
---

## Milestone 1: {MILESTONE_NAME}

**Goal**: {USER_FACING_OUTCOME}
**Testable**: {HOW_USER_CAN_VERIFY}

### Phase 1.1: {PHASE_NAME}

#### Overview
{WHAT_THIS_ACCOMPLISHES}

#### Changes Required

##### 1. {COMPONENT_NAME}
**File**: `{FILE_PATH}`
**Changes**: {SUMMARY}

```{LANGUAGE}
{CODE_EXAMPLE}
```

#### Success Criteria

##### Automated Verification:
- [ ] {AUTOMATED_CHECK}: `{COMMAND}`
- [ ] {ANOTHER_CHECK}: `{COMMAND}`

##### Manual Verification:
- [ ] {MANUAL_TEST_STEP}
- [ ] {ANOTHER_MANUAL_TEST}

---

### Phase 1.2: {PHASE_NAME}
{SIMILAR_STRUCTURE}

---

## Milestone 2: {MILESTONE_NAME}

**Goal**: {USER_FACING_OUTCOME}
**Testable**: {HOW_USER_CAN_VERIFY}

### Phase 2.1: {PHASE_NAME}
{SIMILAR_STRUCTURE}

---
```

##### 2. Update Write Plan Doc Skill
**File**: `skills/write-plan-doc/SKILL.md`
**Changes**: Document milestone structure requirements

Add new section after Phase Structure (after line 62):
```markdown
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
```

##### 3. Update Plan Command
**File**: `commands/plan.md`
**Changes**: Ask about milestone grouping during collaboration

Update Step 7 (lines 52-55):
```markdown
### Step 7: Collaborate on Approach
- Present design options with pros/cons
- Get user buy-in on structure
- **Ask about milestone grouping**:
  - Should phases be grouped into milestones?
  - What are the user-facing outcomes?
  - Where are natural testing/validation points?
- Agree on phases AND milestones before writing
```

#### Success Criteria

##### Automated Verification:
- [ ] Template has milestone structure: `grep -q "## Milestone.*:" templates/plan-document.md`
- [ ] Template has Goal and Testable fields: `grep -c "^\*\*Goal\*\*\|^\*\*Testable\*\*" templates/plan-document.md | grep -E "[2-9]|[1-9][0-9]"`
- [ ] Skill documents milestones: `grep -q "Milestone Structure" skills/write-plan-doc/SKILL.md`
- [ ] Command asks about milestones: `grep -q "milestone grouping" commands/plan.md`

##### Manual Verification:
- [ ] Generated plans have milestone sections wrapping phases
- [ ] Milestones have user-facing Goal statements
- [ ] Milestones have Testable verification descriptions
- [ ] Phase numbering follows milestone pattern (1.1, 1.2, 2.1, etc.)
- [ ] Plan command prompts about milestone grouping during collaboration

---

## Milestone 3: Context Window Management - Agent Orchestration

**Goal**: Implement agent orchestration patterns to keep main agent under 40k tokens per phase
**Testable**: Can implement complex phases using agents while main agent context stays manageable

### Phase 3.1: Create Agent Orchestration Guide

#### Overview
Create skill that documents the 5-phase agent orchestration pattern for implementation, including token budgets and parallel/sequential spawning.

#### Changes Required

##### 1. Create Spawn Implementation Agents Skill
**File**: `skills/spawn-implementation-agents/SKILL.md`
**Changes**: New skill documenting orchestration patterns

```markdown
---
name: spawn-implementation-agents
description: Guide for efficient agent orchestration during implementation to conserve main agent context
---

# Spawn Implementation Agents

Orchestrate specialized agents during implementation to keep main agent context under 40k tokens per phase.

## The Problem

Without agents, implementing a phase uses ~92k tokens in main agent:
- Read plan & changelog: 15k
- Read existing code files: 30k
- Find usage patterns: 15k
- Write implementation: 10k
- Write tests: 10k
- Run verification: 10k
- Update changelog: 2k

This approaches the 200k context limit and risks compaction.

## The Solution

Use agents to isolate heavy operations:
- Main agent: 38k tokens (plan + changelog + summaries + code writing)
- Sub-agents: 60k tokens total (in isolated contexts)
- Total system: 98k tokens (50% safety margin)

## 5-Phase Orchestration Pattern

### Phase 1: Analysis (Parallel)

Spawn simultaneously to gather context:

```markdown
Task(subagent_type="workflows:codebase-analyzer",
     prompt="Analyze existing auth system architecture.
     Focus on handler pattern, middleware usage, error handling.
     Return 2-3k summary with key patterns and file:line references.")

Task(subagent_type="workflows:codebase-pattern-finder",
     prompt="Find similar implementations of authentication handlers.
     Return 3k of concrete examples showing handler pattern, validation, errors.")

Task(subagent_type="workflows:thoughts-analyzer",
     prompt="Extract insights from changelog.md about previous phase learnings.
     Return 2k of key deviations and discoveries that affect this phase.")
```

**Wait for all three**. Main agent receives ~8k of summaries.

### Phase 2: Implementation (Main Agent)

Main agent writes code using summaries:
- Has patterns from codebase-pattern-finder
- Understands architecture from codebase-analyzer
- Knows previous deviations from thoughts-analyzer
- Writes implementation: 10k tokens
- Total so far: 15k (plan/changelog) + 8k (summaries) + 10k (code) = 33k

### Phase 3: Testing (Sequential)

Spawn test writer:

```markdown
Task(subagent_type="workflows:test-writer",
     prompt="Generate tests for AuthHandler following patterns in testing.md.
     Test functions: Login(), Logout(), ValidateToken().
     Return test code only, ~3k tokens.")
```

Main agent receives test code, integrates it. Total: 36k

### Phase 4: Verification (Sequential)

Spawn verifier:

```markdown
Task(subagent_type="Bash",
     prompt="Run verification commands from plan.md:
     - make test
     - make lint
     - make build
     Return concise summary: ✅ passed or ❌ failed with key errors only.")
```

Main agent receives pass/fail + errors. Total: 38k

### Phase 5: Documentation (Main Agent)

Update changelog.md: 2k tokens. Final total: 40k

## Token Budget Comparison

| Activity | Without Agents | With Agents | Savings |
|----------|----------------|-------------|---------|
| Read plan & changelog | 15k | 15k | 0k |
| Understand existing code | 30k | 3k | **27k** |
| Find patterns | 15k | 3k | **12k** |
| Write implementation | 10k | 10k | 0k |
| Write tests | 10k | 3k | **7k** |
| Run verification | 10k | 2k | **8k** |
| Update changelog | 2k | 2k | 0k |
| **TOTAL** | **92k** | **40k** | **52k** |

## Guidelines

**When to spawn in parallel**:
- Analysis phase (codebase-analyzer + pattern-finder + thoughts-analyzer)
- Independent lookups (finding multiple unrelated examples)
- Reading multiple unrelated files

**When to spawn sequentially**:
- Test writing (needs implementation to be done first)
- Verification (needs tests to be written first)
- Operations that depend on previous results

**What agents return**:
- **Summaries**, not raw data (2-5k tokens each)
- **Key patterns**, not all files (concrete examples only)
- **Pass/fail + errors**, not full output (1-2k tokens)

## Benefits

- **60% token reduction** per phase in main agent
- **Larger phases possible**: 5-8 files instead of 3-5
- **Complex integrations supported**: Agents find patterns
- **Large files OK**: Agents handle reading (>2000 lines)
- **Safety margin**: 100k tokens remaining in system

## Important Notes

- Main agent NEVER reads large files directly
- Main agent orchestrates, sub-agents execute
- Summaries are compressed, not exhaustive
- This is guidance, not automation - user still in control
```

##### 2. Update Agent Awareness Skill
**File**: `skills/agent-awareness/SKILL.md`
**Changes**: Reference implementation agent orchestration

Add to Implementation section (find appropriate location):
```markdown
### Implementation Agents

During implementation, use aggressive agent orchestration:
- See `spawn-implementation-agents` skill for full pattern
- Keep main agent under 40k tokens per phase
- Use sub-agents for file reading, pattern finding, testing, verification
- 60% token reduction per phase
```

#### Success Criteria

##### Automated Verification:
- [ ] Skill file exists: `test -f skills/spawn-implementation-agents/SKILL.md`
- [ ] Skill documents 5 phases: `grep -c "Phase [1-5]:" skills/spawn-implementation-agents/SKILL.md | grep 5`
- [ ] Token budget table present: `grep -q "Token Budget Comparison" skills/spawn-implementation-agents/SKILL.md`
- [ ] Agent-awareness references it: `grep -q "spawn-implementation-agents" skills/agent-awareness/SKILL.md`

##### Manual Verification:
- [ ] Skill clearly documents parallel vs sequential spawning
- [ ] Token budget shows 60% savings
- [ ] Examples show actual Task() calls with prompts
- [ ] Guidelines explain when to use each pattern
- [ ] Benefits section explains larger phase capability

---

### Phase 3.2: Create Test-Writer Agent

#### Overview
Create specialized agent that generates tests in isolation, following project patterns, returning only test code.

#### Changes Required

##### 1. Create Test Writer Agent
**File**: `agents/test-writer.md`
**Changes**: New agent definition

```markdown
---
name: test-writer
description: Generate tests following project patterns without loading test code into main agent context
tools: Read, Grep, Glob
---

You are a specialist at generating tests that follow project conventions. Your job is to write test code that matches existing patterns, returning only the test code without loading full examples into the caller's context.

## Core Responsibilities

1. **Read test patterns** from `thoughts/notes/testing.md`
2. **Find similar test examples** in the codebase
3. **Generate test code** following those patterns
4. **Return test code only**, not examples or documentation

## How It Works

### Step 1: Understand Requirements

Caller provides:
- Function signatures to test
- Expected behavior
- Edge cases to cover
- Path to `thoughts/notes/testing.md`

### Step 2: Read Patterns

Read `thoughts/notes/testing.md` to understand:
- Test file organization
- Framework being used
- Assertion style
- Mocking approach
- Setup/teardown patterns
- Table-driven test patterns (if applicable)

### Step 3: Find Examples (If Needed)

If patterns are unclear, find 1-2 similar tests:
- Search for tests of similar functions
- Extract the pattern (structure, not content)
- Don't return full example files

### Step 4: Generate Tests

Write test code that:
- Follows discovered patterns exactly
- Covers provided function signatures
- Tests expected behavior and edge cases
- Uses correct assertion style
- Includes setup/teardown if needed
- Uses table-driven approach if project uses it

### Step 5: Return Code Only

Output format:
```
## Generated Tests

```go
// Test code here
func TestAuthHandler(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        // test cases
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // test implementation
        })
    }
}
```
```

## Example Interaction

**Input**:
```
Generate tests for these functions:
- Login(username, password) -> (token, error)
- Logout(token) -> error
- ValidateToken(token) -> (userID, error)

Expected behavior:
- Login returns token on success, error on bad credentials
- Logout invalidates token
- ValidateToken returns userID or error

Test patterns: thoughts/notes/testing.md
```

**Output** (3k tokens):
```
## Generated Tests

```go
package auth_test

import (
    "testing"
    "github.com/stretchr/testify/require"
    "yourproject/auth"
)

func TestLogin(t *testing.T) {
    tests := []struct {
        name        string
        username    string
        password    string
        expectToken bool
        expectError bool
    }{
        {
            name:        "valid credentials",
            username:    "user1",
            password:    "pass123",
            expectToken: true,
            expectError: false,
        },
        {
            name:        "invalid password",
            username:    "user1",
            password:    "wrong",
            expectToken: false,
            expectError: true,
        },
        // more cases...
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            token, err := auth.Login(tt.username, tt.password)
            if tt.expectError {
                require.Error(t, err)
                require.Empty(t, token)
            } else {
                require.NoError(t, err)
                require.NotEmpty(t, token)
            }
        })
    }
}

// TestLogout and TestValidateToken...
```
```

## Token Budget

- **Internal budget**: Up to 30k tokens
  - Read testing.md: 5k
  - Find examples: 10k
  - Generate tests: 10k
  - Internal reasoning: 5k

- **Output budget**: ~3k tokens
  - Test code only
  - No examples or explanations
  - Just the code caller needs

## Important Guidelines

- **Match project patterns exactly** - don't invent new styles
- **Return code only** - no markdown explanations
- **Be comprehensive** - cover edge cases
- **Follow conventions** - naming, structure, assertions
- **Stay within budget** - 3k output max

Remember: You're a test code generator. Main agent gets your code (3k), not your research (30k).
```

##### 2. Update Follow Test Patterns Skill
**File**: `skills/follow-test-patterns/SKILL.md`
**Changes**: Reference test-writer agent

Add after line 40 (in the workflow section):
```markdown
## Alternative: Use Test-Writer Agent

For complex test generation, spawn the test-writer agent:

```markdown
Task(subagent_type="workflows:test-writer",
     prompt="Generate tests for [functions] following patterns in testing.md.
     Expected behavior: [describe].
     Return test code only.")
```

**Benefits**:
- Conserves main agent context (3k instead of 20k+)
- Agent reads testing.md and examples in isolation
- Returns only the test code you need
- Follows project patterns automatically

**When to use**:
- Generating multiple test files
- Complex table-driven tests
- During phased implementation (see `spawn-implementation-agents`)
```

#### Success Criteria

##### Automated Verification:
- [ ] Agent file exists: `test -f agents/test-writer.md`
- [ ] Agent has tools defined: `grep -q "tools:.*Read.*Grep.*Glob" agents/test-writer.md`
- [ ] Token budgets documented: `grep -q "Token Budget" agents/test-writer.md`
- [ ] Follow-test-patterns references it: `grep -q "test-writer" skills/follow-test-patterns/SKILL.md`

##### Manual Verification:
- [ ] Agent can read testing.md and extract patterns
- [ ] Agent generates test code following project conventions
- [ ] Agent returns only test code (not examples or docs)
- [ ] Output is ~3k tokens (compact, focused)
- [ ] Can spawn agent during implementation phase

---

### Phase 3.3: Update Implement Command with Agent Steps

#### Overview
Update implement command to use agent orchestration pattern, keeping main agent under 40k tokens per phase.

#### Changes Required

##### 1. Update Implement Command
**File**: `commands/implement.md`
**Changes**: Add agent orchestration steps

Add new Step 3 (after Step 2, renumber remaining):
```markdown
### Step 3: Analyze with Agents (NEW)

**DO NOT read files directly in main context**

Before implementing, spawn analysis agents in parallel:

```markdown
Task(subagent_type="workflows:codebase-analyzer",
     prompt="Analyze [component] architecture for this phase.
     Return 2-3k summary with key patterns and integration points.")

Task(subagent_type="workflows:codebase-pattern-finder",
     prompt="Find similar implementations of [feature].
     Return 3k of concrete examples.")

Task(subagent_type="workflows:thoughts-analyzer",
     prompt="Extract insights from changelog.md about previous phases.
     Return 2k of deviations and learnings relevant to this phase.")
```

**Wait for all agents to complete**. Main agent receives summaries (~8k tokens total).

**See `spawn-implementation-agents` skill** for full orchestration pattern.
```

Update Step 4 (previously Step 3, now Step 4):
```markdown
### Step 4: Implement Changes (Main Agent)

Write code based on:
- Patterns from codebase-pattern-finder
- Architecture from codebase-analyzer
- Previous learnings from thoughts-analyzer
- Plan specifications

**Do not read additional files** - use agent summaries instead.
```

Add new Step 5 (after Step 4, renumber remaining):
```markdown
### Step 5: Write Tests with Agent (NEW)

**DO NOT write tests directly in main context**

Spawn test-writer agent:

```markdown
Task(subagent_type="workflows:test-writer",
     prompt="Generate tests for [functions] following patterns in testing.md.
     Expected behavior: [describe from plan].
     Edge cases: [list from plan].
     Return test code only.")
```

Main agent receives test code (~3k tokens), integrates into test files.
```

Update Step 6 (previously Step 5, now Step 6):
```markdown
### Step 6: Verify with Agent (UPDATED)

**DO NOT run verification directly in main context**

Spawn verification agent (use `verify-implementation` skill):

```markdown
Task(subagent_type="Bash",
     prompt="Run verification commands from plan.md success criteria:
     - [list automated checks]
     Return concise summary: ✅ passed or ❌ failed with key errors only.")
```

Main agent receives summary (1-2k tokens) instead of raw output (10k+).
```

Update Important Notes (at end):
```markdown
## Token Management

Each phase should keep main agent under 40k tokens:
- Plan + changelog: 15k
- Agent summaries: 8k
- Implementation: 10k
- Test integration: 3k
- Verification summary: 2k
- Changelog update: 2k
- **Total: ~40k**

Sub-agents use 60k tokens in isolated contexts (total system: <100k).

See `spawn-implementation-agents` skill for detailed guidance.
```

##### 2. Update README
**File**: `README.md`
**Changes**: Document agent-based implementation

Add after changelog documentation (around line 50):
```markdown
### Agent Orchestration

Implementation uses agents to conserve context:
- **Analysis agents** (parallel) - Gather patterns and architecture
- **Test writer agent** - Generate tests following conventions
- **Verification agent** - Run checks and return summary

This keeps the main agent under 40k tokens per phase while enabling larger, more complex phases.

**Token savings**: 60% reduction per phase (92k → 40k in main agent)

See `skills/spawn-implementation-agents/SKILL.md` for full pattern.
```

#### Success Criteria

##### Automated Verification:
- [ ] Implement command has analysis step: `grep -q "Step 3:.*Analyze with Agents" commands/implement.md`
- [ ] Implement command has test-writer step: `grep -q "Step 5:.*Write Tests with Agent" commands/implement.md`
- [ ] Implement command has verification step updated: `grep -q "Step 6:.*Verify with Agent" commands/implement.md`
- [ ] Token management documented: `grep -q "Token Management" commands/implement.md`
- [ ] README documents agents: `grep -q "Agent Orchestration" README.md`

##### Manual Verification:
- [ ] Implement command spawns analysis agents before implementation
- [ ] Implement command spawns test-writer for test generation
- [ ] Implement command spawns verification agent for checks
- [ ] Main agent receives summaries only (not raw data)
- [ ] Token budget stays under 40k in main agent per phase

---

### Phase 3.4: Update Verification Skill for Agent Pattern

#### Overview
Update verify-implementation skill to always use agents, and add token estimate fields to plan template.

#### Changes Required

##### 1. Update Verify Implementation Skill
**File**: `skills/verify-implementation/SKILL.md`
**Changes**: Document agent spawning pattern

Add after line 11 (before "Verification Commands" section):
```markdown
## IMPORTANT: Always Use Verification Agent

**DO NOT run verification commands directly in main context.**

Spawn a verification agent to run checks and return summary:

```markdown
Task(subagent_type="Bash",
     prompt="Run verification commands from plan success criteria:
     - make test
     - make lint
     - make build
     [list all automated checks from plan]

     Return concise summary:
     - If all pass: ✅ All verification passed
     - If any fail: ❌ Verification failed
       - List ONLY the failing checks
       - Include first few lines of error
       - Omit stack traces and verbose output

     Maximum output: 2k tokens")
```

**Why use an agent**:
- Raw output can be 10k+ tokens (floods main agent context)
- Agent filters to only essential info (1-2k tokens)
- Keeps main agent focused on implementation
- Part of token management strategy (see `spawn-implementation-agents`)

**Agent returns**:
- ✅ Pass status or ❌ Fail status
- Only failed checks (not successful ones)
- First few lines of errors (not full output)
- Actionable information only
```

Update Verification Commands section (add note at end):
```markdown
## Important

Always spawn agent for verification - never run commands directly in main context.

See `spawn-implementation-agents` skill for full orchestration pattern.
```

##### 2. Update Plan Document Template
**File**: `templates/plan-document.md`
**Changes**: Add token estimate fields to phases

Update Phase section (after line 31, before "### Overview"):
```markdown
### Phase 1.1: {PHASE_NAME}

**Estimated Complexity**: Low / Medium / High
**Token Estimate**: ~{ESTIMATE}k tokens in main agent
**Agent Strategy**: {PARALLEL_ANALYSIS | SEQUENTIAL | MINIMAL}
```

Add explanation section before phases:
```markdown
## Token Management Strategy

Each phase targets <40k tokens in main agent, <100k total system.

**Complexity levels**:
- **Low**: 1-2 files, straightforward changes (~25k tokens)
- **Medium**: 3-4 files, moderate complexity (~35k tokens)
- **High**: 5-8 files, complex integration (~40k tokens)

**Agent strategies**:
- **Parallel Analysis**: Spawn analyzer + pattern-finder + thoughts-analyzer simultaneously
- **Sequential**: Spawn agents one at a time (lighter phases)
- **Minimal**: Direct implementation (very light phases, <20k)

**See**: `spawn-implementation-agents` skill for orchestration guidance.

---
```

#### Success Criteria

##### Automated Verification:
- [ ] Verify-implementation documents agent usage: `grep -q "Always Use Verification Agent" skills/verify-implementation/SKILL.md`
- [ ] Plan template has token estimates: `grep -q "Token Estimate" templates/plan-document.md`
- [ ] Plan template has agent strategy: `grep -q "Agent Strategy" templates/plan-document.md`
- [ ] Token management section in template: `grep -q "Token Management Strategy" templates/plan-document.md`

##### Manual Verification:
- [ ] Verify-implementation skill clearly states "always spawn agent"
- [ ] Example shows agent returning concise summary
- [ ] Plan template guides token estimation per phase
- [ ] Plan template suggests appropriate agent strategy per phase
- [ ] Generated plans include complexity and token estimates

---

## Testing Strategy

### Integration Testing

**Milestone 1 Testing**:
1. Create test research document using new structure
2. Create test plan from research (should reuse directory)
3. Verify both old and new paths work in commands
4. Verify agents find documents in both locations
5. Run `/workflows:upgrade` with test documents
6. Verify upgrade reads CHANGELOG.md and executes migration steps correctly

**Milestone 2 Testing**:
1. Implement a test plan with changelog tracking
2. Verify auto-correction works (deviate in phase 1, phase 2 adapts)
3. Create plan with milestones, verify structure
4. Verify final summary appends correctly

**Milestone 3 Testing**:
1. Implement phase using agent orchestration
2. Verify main agent context stays under 40k
3. Verify test-writer generates appropriate tests
4. Verify verification agent returns concise summary

### Manual Testing Steps

1. **Test new directory creation**:
   - Run research command with question
   - Verify slug prompt with suggestion
   - Accept suggestion, verify directory created
   - Check frontmatter has feature_slug

2. **Test backward compatibility**:
   - Use old-format plan path with implement command
   - Verify it still works
   - Create new research using old path pattern (should fail gracefully or suggest new)

3. **Test upgrade command**:
   - Create test documents in thoughts/shared/research/ and thoughts/shared/plans/
   - Run `/workflows:upgrade` (without specifying version)
   - Verify Claude detects current version (v1.2.0) and target version (v1.3.0)
   - Verify Claude reads CHANGELOG.md migration steps
   - Verify Claude analyzes documents and proposes groupings
   - Review and approve suggested groupings
   - Verify feature directories created with correct slugs
   - Verify documents copied to new locations
   - Verify frontmatter updated with feature_slug
   - Verify original documents still exist in shared/
   - Verify `migrations/version.txt` updated: `current: v1.3.0, migrated_from: v1.2.0`

4. **Test changelog workflow**:
   - Implement first phase of plan
   - Verify changelog.md created with phase section
   - Implement second phase
   - Verify phase 2 section appended (not overwritten)
   - Complete all phases
   - Verify final summary appended

5. **Test milestone structure**:
   - Create plan with milestones
   - Verify phases grouped under milestones
   - Verify milestone goals are user-facing
   - Verify phase numbering (1.1, 1.2, 2.1, etc.)

6. **Test agent orchestration**:
   - Implement phase with analysis agents
   - Verify they spawn in parallel
   - Verify main agent receives summaries only
   - Monitor context usage (should be <40k)
   - Verify test-writer returns code only
   - Verify verification agent returns concise summary

## Performance Considerations

**Directory scanning**: Finding next feature number requires scanning thoughts/ directory. With 1000+ features, this could be slow. Current implementation is fine for <100 features. Future optimization: Cache last number.

**Agent spawning**: Each agent spawn has overhead (~2-3 seconds). Parallel spawning mitigates this. Expected overhead per phase: 5-10 seconds total.

**Token counting**: No automatic token counting implemented. Guidelines only. Relies on developer awareness and agent discipline.

**Backward compatibility**: Dual path support adds complexity to searches. Agents check both locations. Minor performance impact (<100ms per search).

## Migration Notes

**Upgrade command**: Phase 1.5 creates `/workflows:upgrade` command for intelligent version migrations.

**Upgrade usage**:
```bash
/workflows:upgrade

# Claude automatically:
# 1. Detects current version and latest available version
# 2. Reads CHANGELOG.md for migration steps
# 3. Analyzes your documents
# 4. Proposes groupings
# 5. Executes migration with your approval
```

**What it does**:
1. Reads migration instructions from CHANGELOG.md
2. Analyzes `thoughts/shared/research/` and `thoughts/shared/plans/`
3. Proposes intelligent groupings for related documents
4. Creates feature directories with auto-incremented numbers
5. Copies documents to new structure (preserves originals)
6. Updates frontmatter to include `feature_slug`
7. Handles edge cases (cross-references, custom frontmatter)
8. Updates `migrations/version.txt` (sets current version and migrated_from)

**After migration**:
- Original documents remain in `thoughts/shared/` (never deleted)
- Verify new documents work correctly
- Optionally delete `thoughts/shared/` manually

**Future upgrades**: Add new versions to CHANGELOG.md with Migration sections. Claude reads and executes them.

**Manual migration**: Humans can also follow CHANGELOG.md migration steps directly - they're written for both humans and Claude.

## References

- Original research: `thoughts/shared/research/2026-02-03-01-plugin-restructuring-and-improvements.md`
- PR templates extraction: PR #1 (v1.2.1)
- Verification section removal: PR #2 (v1.2.2)
- Template files: `templates/plan-document.md`, `templates/research-document.md`, `templates/changelog-document.md`
- Agent definitions: `agents/thoughts-locator.md`, `agents/thoughts-analyzer.md`, `agents/test-writer.md`
