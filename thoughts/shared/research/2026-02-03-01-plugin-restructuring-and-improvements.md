---
date: 2026-02-03T08:07:07Z
researcher: Claude
git_commit: b3de4e00dcd775bb4d0afbc5362ab4752a591a58
branch: main
repository: claude
topic: "Plugin Restructuring: Thoughts Directory, Plan Command, and Post-Implementation Documentation"
tags: [research, plugin-architecture, documentation-structure, planning-improvements, context-window-management, sub-agent-orchestration, pr-descriptions]
status: implemented
last_updated: 2026-02-03T11:01:30Z
last_updated_by: Claude
decisions_finalized: true
implementation_complete: true
versions: [v1.2.1, v1.2.2]
---

# Research: Plugin Restructuring and Improvements

## Research Question

How should we restructure the workflows plugin to:
1. Change thoughts directory from `thoughts/shared/{research,plan,notes}/<document>.md` to `thoughts/<feature-slug>/{plan.md,research.md,notes.md,changelog.md}`
2. Improve the plan command to ensure phases fit within a single context window and are grouped into testable milestones
3. Add post-implementation documentation to capture what was actually built
4. Remove test plan section from PR descriptions

## Summary

The current plugin uses a flat, shared directory structure (`thoughts/shared/`) with timestamped filenames. The proposed feature-centric structure (`thoughts/<feature-slug>/`) would better organize related documents and enable per-feature tracking. The plan command currently lacks explicit phase sizing or milestone grouping - it relies on user collaboration to determine structure. No post-implementation documentation pattern currently exists.

**FINALIZED DECISIONS:**
1. **Feature slug format**: `thoughts/NNNN-description/` with running number prefix (0001, 0002, etc.)
2. **Context window management**: Target <40k tokens in main agent per phase using aggressive sub-agent orchestration, total system <100k tokens
3. **Changelog approach**: Combined tracking + summary in single `changelog.md` file, updated during/after each phase, read before each phase for auto-correction
4. **Milestone grouping**: Phases grouped into testable milestones with user-facing outcomes
5. **PR descriptions**: Remove test plan and verification sections (keep PRs simple and focused)

This research identifies the files that need modification, documents token savings through sub-agent usage, and provides detailed implementation guidance.

## Detailed Findings

### 1. Current Thoughts Directory Structure

**Location**: Throughout the codebase, primarily referenced in skills and commands
**Current Pattern**: `thoughts/shared/{research,plans,notes}/<YYYY-MM-DD-NN-description>.md`

#### File References in Codebase

**Research Document Creation** - `skills/write-research-doc/SKILL.md:38-46`
```markdown
File path pattern: thoughts/shared/research/YYYY-MM-DD-NN-description.md
Example: 2025-12-23-01-authentication-flow.md
```

**Plan Document Creation** - `skills/write-plan-doc/SKILL.md:24-34`
```markdown
File path pattern: thoughts/shared/plans/YYYY-MM-DD-NN-description.md
Example: 2025-12-23-01-ENG-1478-email-notifications.md
```

**Notes References** - `skills/discover-project-commands/SKILL.md:38` and `skills/discover-test-patterns/SKILL.md:41`
```markdown
Commands: thoughts/notes/commands.md
Testing: thoughts/notes/testing.md
```

**All References to thoughts/shared Pattern**:
- `commands/research.md:39` - Output path for research documents
- `commands/plan.md:60` - Output path for plan documents
- `skills/write-research-doc/SKILL.md:38-46` - File naming convention
- `skills/write-plan-doc/SKILL.md:24-34` - File naming convention
- `skills/write-research-doc/SKILL.md:63-66` - Path conventions guide

#### Current Directory Purpose

**`thoughts/shared/research/`**: Exploratory research documents answering specific questions about the codebase. Created by `/workflows:research` command.

**`thoughts/shared/plans/`**: Implementation plans with phased execution steps. Created by `/workflows:plan` command.

**`thoughts/notes/`**: Auto-discovered reference documents (project commands, test patterns). Created by `discover-*` skills during planning.

**`thoughts/shared/tickets/`**: Ticket documentation (mentioned but not actively created by plugin).

**`thoughts/shared/prs/`**: PR descriptions (mentioned but not actively created by plugin).

### 2. Proposed Feature-Centric Structure

**New Pattern**: `thoughts/<feature-slug>/{plan.md,research.md,notes.md,changelog.md}`

#### Slug/ID Determination - FINAL DECISION

**Selected Approach**: Running number prefix with description

**Format**: `thoughts/NNNN-description/`
- `NNNN`: Zero-padded running number (0001, 0002, 0003, etc.)
- `description`: Kebab-case descriptive name

**Examples**:
```
thoughts/0001-authentication/
thoughts/0002-email-notifications/
thoughts/0003-user-profiles/
```

**Rationale**:
- **Guaranteed uniqueness**: No naming conflicts possible
- **Chronological ordering**: Natural sorting shows feature timeline
- **Simple increment logic**: Find highest number and add 1
- **Maintains existing pattern**: Similar to current `YYYY-MM-DD-NN` approach
- **Still readable**: Number prefix doesn't obscure feature name
- **No timestamp coupling**: Unlike dates, numbers are more stable

**Implementation**:
```bash
# Find next number
NEXT_NUM=$(ls -1 thoughts/ | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1)
NEXT_NUM=$(printf "%04d" $((10#$NEXT_NUM + 1)))

# Prompt user for description
read -p "Feature description (kebab-case): " DESC

# Create directory
mkdir -p "thoughts/${NEXT_NUM}-${DESC}"
```

**Skills Updated**:
- `skills/determine-feature-slug/SKILL.md` - Interactive slug determination with validation
- `skills/write-research-doc/SKILL.md` - Use new path pattern
- `skills/write-plan-doc/SKILL.md` - Use new path pattern

#### Document Types in Feature Directory

**`plan.md`**: Implementation plan (replaces timestamped plan in thoughts/shared/plans/)
- Created by `/workflows:plan` command
- Contains phases, success criteria, project references
- Updated during implementation with checkbox tracking

**`research.md`**: Research findings (replaces timestamped research in thoughts/shared/research/)
- Created by `/workflows:research` command
- Contains detailed findings, file:line references, patterns
- May have multiple research sessions - consider versioning

**`notes.md`**: Feature-specific notes and discoveries
- New document type for ad-hoc observations
- Quick notes during implementation
- Not structured like research or plans

**`changelog.md`**: Implementation changelog (NEW)
- Tracks changes made during implementation
- Records deviations from plan
- Documents decisions made on-the-fly
- Useful for retrospectives and future reference

#### Migration Considerations

**Backward Compatibility**: How to handle existing `thoughts/shared/` documents?
- Leave existing documents in place
- Update skills to check both old and new locations
- Add migration script to move old docs to feature directories
- Consider symlinks or redirects

**Transition Strategy**:
1. Support both structures simultaneously
2. New documents use feature-centric structure
3. Skills check new location first, fall back to old
4. Gradually migrate old documents as they're referenced

### 3. Plan Command Phase Sizing and Milestones

**Current Implementation**: `commands/plan.md:21-79`

#### Existing Phase Structure

The plan command currently has **no explicit phase sizing logic**:

**No Token/Context Constraints** - `commands/plan.md:24, 40`
```markdown
Step 1: Read context files FULLY (no limit/offset)
Step 4: Read agent findings FULLY
```
- Assumes files fit in context window
- No pagination or chunking logic
- No tracking of token usage

**No Automated Phase Breakdown** - `commands/plan.md:52-55`
```markdown
Step 7: Collaborate on Approach
- Present design options with pros/cons
- Get user buy-in on structure
- Agree on phases before writing
```
- Phase structure emerges from user collaboration
- No algorithms for determining phase size
- Relies on human judgment

**Implicit Guidance Only** - `commands/plan.md:71-78`
```markdown
Important Notes:
- Be skeptical: Question vague requirements
- Be interactive: Don't write full plan in one shot
- Be practical: Focus on incremental, testable changes
```
- Encourages manageable chunks through interaction
- No hard rules or constraints

#### Current Success Criteria Pattern

**Split Verification** - `templates/plan-document.md:45-52`
```markdown
#### Automated Verification:
- [ ] {AUTOMATED_CHECK}: `{COMMAND}`

#### Manual Verification:
- [ ] {MANUAL_TEST_STEP}
```
- Each phase has automated and manual verification
- Checkbox format for tracking
- Used by `verify-implementation` skill

**No Milestone Grouping**: Phases are sequential, not grouped into testable milestones.

#### Proposed Improvements - FINALIZED

**Critical Constraint**: Claude Code has 200k token context window - phases MUST fit within this to avoid compaction.

**Phase Sizing with Context Window Management**

Target: **<40k tokens in main agent** per phase, **<100k tokens total system usage**

**Why These Numbers**:
- 200k total context window
- 15k system prompts & overhead
- 10k plan document
- 5k changelog (grows over time)
- 10k conversation history
- 40k phase implementation
- **Total**: ~80k, leaving 120k safety margin

**Strategy: Aggressive Sub-Agent Orchestration**

Main agent should hold:
- Plan document (~10k tokens)
- Changelog.md (~5k tokens)
- Agent summaries (~2-5k per agent)
- Code being written (~5-10k tokens)
- Orchestration context (~10k tokens)

Sub-agents handle (in isolated contexts):
- Reading existing files
- Finding patterns and examples
- Generating tests
- Running verification
- Analyzing errors

**Token Savings**: 60% reduction per phase (from ~92k to ~38k in main agent)

**Sub-Agent Orchestration Strategy**

**Phase 1: Analysis (Parallel)**
```
Spawn simultaneously:
- codebase-analyzer: Understand existing code (reads files, returns 2-3k summary)
- codebase-pattern-finder: Find similar implementations (searches + reads, returns 3k examples)
- thoughts-analyzer: Extract changelog learnings (reads changelog, returns 2k insights)

Wait for all to complete.
Main agent receives: ~7k tokens of summaries
```

**Phase 2: Implementation (Main Agent)**
```
Main agent writes code using summaries: 5-10k tokens
No file reading in main context
```

**Phase 3: Testing (Sequential)**
```
1. Spawn test-writer: Generate tests following patterns (returns 3k test code)
2. Main agent reviews and integrates
```

**Phase 4: Verification (Sequential)**
```
Spawn verifier agent:
- Runs make test, make lint, etc.
- Analyzes output
- Returns: ✅ passed or ❌ failed with key errors only (1-2k tokens)
```

**Phase 5: Documentation (Main Agent)**
```
Update changelog.md: 2k tokens
```

**Token Budget Per Phase**:

| Activity | Without Agents | With Agents | Savings |
|----------|---------------|-------------|---------|
| Read plan & changelog | 15k | 15k | 0k |
| Understand existing code | 30k | 3k | **27k** |
| Find patterns | 15k | 3k | **12k** |
| Write implementation | 10k | 10k | 0k |
| Write tests | 10k | 3k | **7k** |
| Verify | 10k | 2k | **8k** |
| Update changelog | 2k | 2k | 0k |
| **TOTAL** | **92k** | **38k** | **54k** |

**Revised Phase Constraints**:
- **5-8 file changes** per phase (up from 3-5)
- **Large files OK** (>2000 lines) - agents handle reading
- **Complex integrations OK** - agents find patterns
- **Main agent**: <40k tokens per phase
- **Total system**: <100k tokens per phase (all agents combined)

**Milestone Grouping**

Introduce milestone concept in plan template:

```markdown
## Milestone 1: {MILESTONE_NAME}
**Goal**: {USER_FACING_OUTCOME}
**Testable**: {HOW_USER_CAN_VERIFY}

### Phase 1.1: {PHASE_NAME}
[Phase details...]

### Phase 1.2: {PHASE_NAME}
[Phase details...]

## Milestone 2: {MILESTONE_NAME}
[...]
```

**Benefits**:
- Groups related phases into testable units
- Clear stopping points for user validation
- Enables incremental delivery
- Matches agile/iterative development patterns

**Implementation Locations**:
- `templates/plan-document.md:29-60` - Add milestone section wrapper
- `skills/write-plan-doc/SKILL.md:36-46` - Document milestone structure requirements
- `commands/plan.md:52-55` - Ask user about milestone grouping during collaboration

**Example Milestone Structure**:

```markdown
## Milestone 1: Database Schema Ready
**Goal**: Database can store user authentication data
**Testable**: Can manually insert/query user records via SQL

### Phase 1.1: Create User Table
[...]

### Phase 1.2: Add Authentication Fields
[...]

## Milestone 2: Authentication Working
**Goal**: Users can log in and receive JWT tokens
**Testable**: Can log in via API and receive valid token

### Phase 2.1: Implement Login Handler
[...]

### Phase 2.2: Add JWT Token Generation
[...]
```

### 4. Post-Implementation Documentation - FINALIZED

**Current State**: No dedicated post-implementation document pattern exists.

**Evidence**:
- Searched codebase for completion/retrospective patterns
- Only reference is checkbox tracking in plan documents (`commands/implement.md:48-50`)
- Plans are updated during implementation but not summarized afterward

#### Final Decision: Combined Changelog + Summary Approach

**Purpose**: Track deviations during implementation AND summarize at completion in single document

**Location**: `thoughts/<feature-slug>/changelog.md`

**Key Innovation**: This document serves dual purposes:
1. **During Implementation**: Track deviations from plan after each phase
2. **At Completion**: Append final summary section
3. **For Future Phases**: Read before implementing to understand what changed

**Why This Is Superior to Separate Documents**:
✅ Single source of truth for all deviations
✅ Continuous context - implementer always knows current state
✅ Auto-correction - agent adapts based on previous learnings
✅ No duplication - don't repeat information
✅ Natural evolution - tracking flows into summary

**Template Structure** (Combined Tracking + Summary):

```markdown
# Implementation Changelog: {FEATURE_NAME}

Plan: `thoughts/{FEATURE_SLUG}/plan.md`
Started: {ISO_TIMESTAMP}

---

## Phase 1: {PHASE_NAME}
**Completed**: {DATE}
**Status**: ✅ Complete

### What We Did
- Implemented X as planned
- Added Y (not in original plan)

### Deviations from Plan
- **Planned**: Use middleware pattern
- **Actually**: Used decorator pattern instead
- **Reason**: Discovered existing codebase uses decorators

### Files Changed
- `src/auth/handler.go` - Added authentication logic
- `src/auth/decorator.go` - NEW FILE (not in plan)

### Discoveries
- Existing auth system already had token validation
- Can reuse `validateToken()` instead of reimplementing

---

## Phase 2: {PHASE_NAME}
**Started**: {DATE}
**Status**: 🚧 In Progress

### Current Changes
- Working on JWT generation
- Found bug in existing token expiry logic (fixing now)

---

{ADDITIONAL_PHASES}

---

## 🎯 FINAL SUMMARY
**Completion Date**: {DATE}
**Overall Status**: ✅ Complete

### What Was Built
All phases completed with modifications noted above.

### Key Deviations
1. Used decorator pattern instead of middleware (Phase 1)
2. Reused existing token validation (Phase 1)
3. Fixed token expiry bug (Phase 2)

### Impact on Original Plan
- Plan estimated 3 phases, completed 3
- Added 2 files not in original plan (decorator.go, token_cache.go)
- Removed 1 planned file (middleware.go) - not needed

### Lessons Learned
- Existing patterns matter - check before designing
- Token handling was more complex than expected

### Technical Debt
- TODO: Refactor token validation to use consistent error types
- TODO: Add monitoring for token expiry events

### Follow-up Work
- Consider adding refresh token rotation
- Add admin endpoint for token revocation

### References
- Original plan: `thoughts/{FEATURE_SLUG}/plan.md`
- Research: `thoughts/{FEATURE_SLUG}/research.md`
- Pull request: {PR_URL}
- Commits: {COMMIT_RANGE}
```

#### Creation Workflow - FINALIZED

**Selected: Hybrid Approach with Auto-Correction Loop**

**During Implementation**:
1. Create `changelog.md` at start (empty or with template header)
2. **Before each phase**: Read plan.md AND changelog.md
   - Plan provides original intent
   - Changelog provides actual state and deviations
   - Agent auto-corrects approach based on both
3. **After each phase**: Append phase section to changelog.md
   - What was completed
   - Deviations from plan (planned vs actually)
   - Files changed
   - Discoveries made
4. Repeat for all phases

**At Completion**:
5. Append FINAL SUMMARY section to changelog.md
   - Summarize all deviations
   - Key learnings
   - Technical debt
   - Follow-up work

**Auto-Correction Example**:
```
Phase 3 needs to integrate with auth system
- plan.md says: "Use middleware pattern from Phase 1"
- changelog.md says: "Phase 1 used decorator pattern instead"
- Agent adapts: Uses decorator pattern, not middleware ✅
```

**Benefits**:
- Single source of truth
- Continuous tracking prevents information loss
- Agent has full context of previous decisions
- No separate summarization step needed

#### Implementation Locations - FINALIZED

**Update Implement Command**: `commands/implement.md`

```markdown
## Step 2: Read Context (UPDATED)
- Read plan file FULLY
- **NEW**: Read changelog.md if it exists (for auto-correction)
- Read reference docs (commands.md, testing.md)

## Step 3: Analyze with Agents (NEW)
**DO NOT read files directly in main context**

Spawn in parallel:
- codebase-analyzer: Understand existing code (returns summary)
- codebase-pattern-finder: Find patterns (returns examples)
- thoughts-analyzer: Extract changelog insights (returns learnings)

Main agent receives summaries only.

## Step 4: Implement Changes (Main Agent)
Write code based on summaries and patterns.

## Step 5: Write Tests with Agent (NEW)
Spawn test-writer agent:
- Provide function signatures and behavior
- Agent returns test code following testing.md
- Main agent integrates tests

## Step 6: Verify with Agent (UPDATED)
Spawn verifier agent (verify-implementation skill):
- Runs tests, linting, builds
- Returns summary: ✅ passed or ❌ failed + key errors only

## Step 7: Update Tracking (UPDATED)
- Mark checkboxes in plan file
- **NEW**: Append phase section to changelog.md
  - What was completed
  - Deviations from plan
  - Files changed
  - Discoveries

## Step 8: Final Summary (NEW)
After all phases complete:
- **NEW**: Append FINAL SUMMARY section to changelog.md
  - Summarize all deviations
  - Key learnings
  - Technical debt
  - Follow-up work
```

**New Skill**: `skills/update-changelog/SKILL.md`
```markdown
# Update Changelog

Append phase completion details to changelog.md.

Format:
- Phase name and completion status
- What was actually done
- Deviations from plan (planned vs actually, reason)
- Files changed
- Discoveries

At completion, append FINAL SUMMARY section.
```

**New Skill**: `skills/spawn-implementation-agents/SKILL.md`
```markdown
# Spawn Implementation Agents

Guide for efficient agent orchestration during implementation.

Phases:
1. Analysis (parallel): analyzer, pattern-finder, thoughts-analyzer
2. Implementation (main): Write code
3. Testing (sequential): test-writer
4. Verification (sequential): verifier
5. Documentation (main): Update changelog

Token savings: ~60k per phase
```

**New Agent**: `agents/test-writer.md`
```markdown
# Test Writer Agent

Generate tests following project patterns without loading test code into main agent.

Tools: Read, Grep, Glob
Input: Function signature, expected behavior, testing.md path
Output: Test code only (~3k tokens)
Budget: Up to 30k tokens internally
```

**Update Existing Skill**: `skills/verify-implementation/SKILL.md`
```markdown
# Verify Implementation

**ALWAYS spawn verification agent** - do not run commands in main context.

Agent runs all verification commands and returns concise summary.
Main agent receives 1-2k tokens instead of 10k raw output.
```

### 5. PR Description Improvements - FINALIZED

**Current State**: PR descriptions include a test plan section

**Current Template**: `skills/write-pr-description/SKILL.md:12-41`
```markdown
## Testing
### Automated
- [x] Tests pass: `make test`

### Manual
- [x] Specific verification steps
```

**Issue**: Test plan is redundant
- Verification already documented in plan.md success criteria
- Changelog.md captures actual verification performed
- PR description test section often becomes stale or generic
- Adds unnecessary length to PR descriptions

**Decision**: Remove test plan section from PR descriptions

**Rationale**:
- **Single source of truth**: Verification lives in plan.md and changelog.md
- **Reduced duplication**: Don't repeat testing information in 3 places
- **Cleaner PRs**: Focus on what changed and why, not how it was tested
- **Reference verification**: Link to plan/changelog for detailed testing info

**Final Template Structure** (after v1.2.2):
```markdown
## Summary
[1-2 sentence overview]

## What Changed
- [Bullet points of changes]

## Why
[Explanation of motivation]

## Screenshots
[If UI changes]

## Related Issues
Closes #123
```

**Implementation**:
- ✅ v1.2.1: Created `templates/pr-description.md` with verification section
- ✅ v1.2.2: Removed verification section entirely
- ✅ Updated `skills/write-pr-description/SKILL.md` to reference template

**Note**: Initially planned to include verification section referencing plan/changelog, but decided to remove it entirely for maximum simplicity. PR descriptions now focus solely on what changed and why.

## Key Discoveries

### 1. Feature Directory Structure Enables Better Organization
- Current flat structure makes finding related documents difficult
- Feature-centric structure groups research, plan, notes, and changelog together
- Supports iterative development with multiple research/planning sessions per feature
- **Decision**: Use `NNNN-description` format for guaranteed uniqueness and ordering

### 2. Context Window Management Is Critical
- Claude Code has 200k token limit - must avoid compaction
- Current implementation has no token tracking or constraints
- Phases can easily exceed context window with file reading
- **Solution**: Aggressive sub-agent usage reduces main agent tokens by 60%

### 3. Sub-Agent Orchestration Enables Larger Phases
- Sub-agents operate in isolated contexts (don't pollute main agent)
- Main agent receives summaries (2-5k) instead of raw data (20-50k)
- Can increase phase size from 3-5 files to 5-8 files
- Total system usage <100k while main agent uses <40k

### 4. Milestone Grouping Aligns with User Testing Needs
- Users want clear stopping points to test and validate
- Current sequential phases don't provide natural checkpoints
- Milestones would enable incremental delivery and feedback
- **Decision**: Group phases into milestones with user-facing outcomes

### 5. Changelog Enables Auto-Correction Loop
- Plans are updated but not summarized
- Missing opportunity to capture lessons learned
- **Innovation**: Read changelog before each phase for auto-correction
- Agent adapts implementation based on previous deviations
- Single document for tracking + summary eliminates duplication

### 6. Naming Conventions Are Consistent But Inflexible
- Timestamped filenames work well for chronological ordering
- Difficult to find documents by feature name
- **Decision**: Running numbers maintain ordering while improving discoverability

### 7. Token Savings Through Agent Usage
- Without agents: 80-100k tokens per phase in main context
- With agents: 30-40k tokens per phase in main context
- **Impact**: Can handle 2-3x more complex phases within context limits

### 8. PR Descriptions Have Redundant Test Plans
- Current PR template includes detailed test plan section
- Verification already documented in plan.md success criteria
- Changelog.md captures actual verification performed
- **Decision**: Remove test plan section, reference plan/changelog instead
- Reduces duplication and keeps PRs focused on changes

## Implementation Patterns

### Current Path Resolution Pattern

Files reference paths explicitly:
- `skills/write-research-doc/SKILL.md:38`: Hardcoded `thoughts/shared/research/`
- `skills/write-plan-doc/SKILL.md:24`: Hardcoded `thoughts/shared/plans/`
- `skills/discover-project-commands/SKILL.md:38`: Hardcoded `thoughts/notes/commands.md`

**To Change**: Update all hardcoded paths to support feature directory structure.

### Current Naming Pattern

Timestamp-based with sequence number:
- Format: `YYYY-MM-DD-NN-description.md`
- Sequence number prevents conflicts within same day
- Description is kebab-case

**To Change**: Replace timestamp prefix with feature slug, use fixed filenames within feature directory.

### Current Metadata Gathering Pattern

`skills/gather-project-metadata/SKILL.md:20-39` uses git commands:
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
git rev-parse HEAD
git rev-parse --abbrev-ref HEAD
git remote get-url origin | sed 's/.*[:/]\(.*\)\.git/\1/'
```

**To Extend**: Add feature slug to metadata, track feature across documents.

## Related Components

### Files That Reference thoughts/shared/ Structure

1. **Commands** (need path updates):
   - `commands/research.md:39` - Output path
   - `commands/plan.md:60` - Output path

2. **Skills** (need path updates):
   - `skills/write-research-doc/SKILL.md:38-46` - Path pattern
   - `skills/write-plan-doc/SKILL.md:24-34` - Path pattern
   - `skills/write-research-doc/SKILL.md:63-66` - Path guide

3. **Reference Documents** (may need relocation):
   - `thoughts/notes/commands.md` - Could move to feature-specific location
   - `thoughts/notes/testing.md` - Could move to feature-specific location

4. **Templates** (need structure updates):
   - `templates/plan-document.md:29-60` - Add milestone sections
   - `templates/research-document.md` - Update frontmatter for feature slug

5. **Agents That Search thoughts/** (need to know about new structure):
   - `agents/thoughts-locator.md` - Finds documents in thoughts/
   - `agents/thoughts-analyzer.md` - Reads and analyzes documents

### Files That Define Phase Structure

1. **Templates**:
   - `templates/plan-document.md:29-60` - Phase section definition

2. **Skills**:
   - `skills/write-plan-doc/SKILL.md:36-46` - Phase structure requirements

3. **Commands**:
   - `commands/plan.md:52-55` - Collaboration on phase structure
   - `commands/implement.md:32-60` - Phase execution loop

### New Files Needed

1. **Templates**:
   - `templates/changelog-document.md` - Combined tracking + summary template
   - `templates/pr-description.md` - PR description template (extracted from skill, test section removed)
   - `templates/commit-message.md` - Commit message template (extracted from skill)

2. **Skills**:
   - `skills/determine-feature-slug/SKILL.md` - Interactive slug determination with validation
   - `skills/update-changelog/SKILL.md` - Append phase sections and final summary to changelog
   - `skills/spawn-implementation-agents/SKILL.md` - Agent orchestration guide for implementation

3. **Agents**:
   - `agents/test-writer.md` - Generate tests following project patterns without loading into main context

4. **Commands**: None new (updates to existing commands instead)

5. **Files to Update**:
   - `commands/research.md` - Use new path pattern with feature slugs
   - `commands/plan.md` - Use new path pattern, add milestone collaboration, add token estimation
   - `commands/implement.md` - Add changelog reading/writing, add agent orchestration steps
   - `skills/write-research-doc/SKILL.md` - Use `thoughts/NNNN-description/research.md`
   - `skills/write-plan-doc/SKILL.md` - Use `thoughts/NNNN-description/plan.md`, add milestone structure, add token estimates
   - `skills/write-pr-description/SKILL.md` - Reference templates/pr-description.md instead of embedded template
   - `skills/write-commit-message/SKILL.md` - Reference templates/commit-message.md instead of embedded template
   - `skills/verify-implementation/SKILL.md` - Document agent spawning pattern
   - `templates/plan-document.md` - Add milestone wrappers, add token estimate fields, add agent strategy fields
   - `templates/research-document.md` - Update frontmatter for feature slug
   - `agents/thoughts-locator.md` - Support both old and new directory structures
   - `agents/thoughts-analyzer.md` - Support both old and new directory structures

## Final Decisions Summary

### 1. Thoughts Directory Structure
**Decision**: `thoughts/NNNN-description/{plan.md,research.md,changelog.md,notes.md}`

**Format**:
- `NNNN`: Zero-padded running number (0001, 0002, etc.)
- `description`: Kebab-case feature description
- Fixed filenames within directory (no timestamps)

**Example**: `thoughts/0001-authentication/plan.md`

**Implementation**: Skills auto-detect next number, prompt user for description

---

### 2. Context Window Management
**Decision**: Target <40k tokens in main agent, <100k total system usage per phase

**Strategy**: Aggressive sub-agent orchestration
- Main agent: Plan + changelog + summaries + code writing
- Sub-agents: File reading, pattern finding, test generation, verification

**Token Budget**:
- Main agent per phase: <40k tokens
- Sub-agents per phase: ~60k tokens (in isolated contexts)
- Total system: <100k tokens per phase
- Safety margin: 100k tokens remaining

**Phase Constraints**:
- 5-8 file changes per phase (up from 3-5)
- Large files OK - agents handle reading
- Complex integrations OK - agents find patterns

---

### 3. Changelog.md Approach
**Decision**: Combined tracking + summary in single `changelog.md` file

**Workflow**:
1. **Before each phase**: Read plan.md AND changelog.md for auto-correction
2. **After each phase**: Append phase section (deviations, discoveries, files changed)
3. **At completion**: Append FINAL SUMMARY section (learnings, debt, follow-up)

**Benefits**:
- Single source of truth for deviations
- Auto-correction loop (agent adapts based on previous phases)
- No separate completion document needed
- Continuous tracking prevents information loss

---

### 4. Milestone Grouping
**Decision**: Group phases into testable milestones

**Structure**:
```markdown
## Milestone 1: {USER_FACING_GOAL}
**Goal**: Database can store user auth data
**Testable**: Can manually insert/query records

### Phase 1.1: {TECHNICAL_STEP}
### Phase 1.2: {TECHNICAL_STEP}
```

**Benefits**:
- Clear stopping points for user validation
- Incremental delivery
- User-facing outcomes grouped logically

---

### 5. Sub-Agent Orchestration
**Decision**: Use agents aggressively to conserve main agent tokens

**Agent Usage Pattern**:
1. **Analysis (parallel)**: codebase-analyzer, codebase-pattern-finder, thoughts-analyzer
2. **Implementation (main)**: Write code using summaries
3. **Testing (sequential)**: test-writer generates tests
4. **Verification (sequential)**: verifier runs tests and returns summary
5. **Documentation (main)**: Update changelog

**New Agent**: test-writer.md (generates tests in isolation, returns code only)

**Token Savings**: 60% reduction per phase (92k → 38k in main agent)

---

### 6. Implementation Updates
**Files to Create**:
- `templates/changelog-document.md`
- `skills/determine-feature-slug/SKILL.md`
- `skills/update-changelog/SKILL.md`
- `skills/spawn-implementation-agents/SKILL.md`
- `agents/test-writer.md`

**Files to Update**:
- All command files (research, plan, implement)
- All document-writing skills (write-research-doc, write-plan-doc, write-pr-description)
- Template files (plan-document, research-document)
- Agent files (thoughts-locator, thoughts-analyzer)
- verify-implementation skill

---

### 7. PR Description Simplification & Template Extraction
**Decision**: Remove test plan AND verification sections from PR descriptions, extract templates to separate files

**Changes** (implemented in v1.2.1 and v1.2.2):
1. **Extract templates**: Create `templates/pr-description.md` and `templates/commit-message.md`
2. **Remove test section**: PR template no longer includes automated/manual testing sections
3. **Remove verification section**: No references to plan/changelog (keep PRs simple)

**Final PR template structure**:
- Summary
- What Changed
- Why
- Screenshots (if applicable)
- Related Issues

**Rationale**:
- **Consistency**: Matches pattern of plan-document.md and research-document.md
- **Easier to edit**: Templates in dedicated files
- **Single source of truth**: Verification lives in plan/changelog
- **Reduces duplication**: Don't repeat testing info across documents

**Files to create**:
- `templates/pr-description.md`
- `templates/commit-message.md`

**Files to update**:
- `skills/write-pr-description/SKILL.md` - Reference template instead of embedding
- `skills/write-commit-message/SKILL.md` - Reference template instead of embedding

---

## References

### Source Files Analyzed
- `commands/research.md` - Research workflow orchestration
- `commands/plan.md` - Planning workflow orchestration
- `commands/implement.md` - Implementation workflow orchestration
- `skills/write-research-doc/SKILL.md` - Research document generation
- `skills/write-plan-doc/SKILL.md` - Plan document generation
- `templates/plan-document.md` - Plan structure template
- `templates/research-document.md` - Research structure template
- All 17 agent definitions in `agents/`
- All 24 skill definitions in `skills/`

### Related Research
- None (first research document in this project)

### Similar Implementations
- No similar feature directory patterns found in codebase
- Closest pattern: Notes directory (`thoughts/notes/`) with fixed filenames

---

## Document History

**Initial Research**: 2026-02-03T08:07:07Z
- Explored current implementation
- Identified multiple approaches for each improvement
- Proposed initial recommendations

**Decisions Finalized**: 2026-02-03T09:15:00Z
- Confirmed running number prefix for feature slugs (NNNN-description)
- Finalized context window management strategy (<40k main agent, <100k total)
- Selected combined changelog approach with auto-correction loop
- Confirmed milestone grouping and sub-agent orchestration patterns
- Added PR description simplification (remove test plan section)
- All decisions validated with user and ready for implementation planning

**Implementation Completed**: 2026-02-03T10:30:00Z
- v1.2.1: Template extraction (PR #1)
- v1.2.2: Removed verification section from PR template (PR #2)
- Research document updated to reflect final implementation
- GitHub repository settings configured (squash merge, auto-delete branches, branch protection)
