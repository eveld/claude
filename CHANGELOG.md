# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-02-03

### Added
- Personal/shared namespace collaboration model
  - Personal workspace: `thoughts/{username}/NNNN-description/`
  - Shared workspace: `thoughts/shared/NNNN-description/`
- Changelog tracking system (`changelog.md` per feature)
- Milestone grouping in implementation plans
- Agent orchestration for context window management (60% token reduction)
- New skills: `determine-feature-slug`, `share-docs`, `update-changelog`, `spawn-implementation-agents`, `upgrade-plugin`
- New agent: `test-writer` for isolated test generation
- New templates: `changelog-document.md`
- Version tracking: `migrations/version.txt`

### Changed
- Document-writing skills now create documents in personal namespace by default
- Commands support personal, shared, and legacy directory structures
- Plan template includes milestone sections and token estimates
- Implement command uses agent orchestration workflow
- Research/plan templates include namespace and sharing metadata
- thoughts-locator/thoughts-analyzer agents search across namespaces

### Migration

**To upgrade from v1.2.0 to v1.3.0:**

1. Run `/workflows:upgrade` (detects v1.2.0 → v1.3.0 automatically)

2. Claude will analyze your `thoughts/shared/` directory:
   - Count research and plan documents
   - Identify related documents by topic/date
   - Propose groupings (e.g., "auth research + auth plan → 0001-authentication")

3. Review proposed groupings:
   - Accept suggested groupings
   - Modify feature names if desired
   - Decide on standalone vs grouped features

4. Claude migrates documents to shared namespace:
   - Create `thoughts/shared/NNNN-description/` directories
   - Copy documents (originals preserved in `thoughts/shared/research/`, `thoughts/shared/plans/`)
   - Update frontmatter with `feature_slug: "shared/NNNN-description"`
   - Fix cross-references to new paths

5. Verify migration:
   - Check new `thoughts/shared/NNNN-*/` directories
   - Test commands with new paths
   - Original files remain in legacy locations

**Version detection:**
- v1.2.0/v1.2.2: Only `thoughts/shared/research/` and `thoughts/shared/plans/` exist
- v1.3.0: `thoughts/shared/NNNN-*/` or `thoughts/{username}/NNNN-*/` directories exist

**New workflow after upgrade:**
- Create new docs in personal namespace: `thoughts/{username}/NNNN-*/`
- Share to team: Use `/share-docs` to copy to `thoughts/shared/NNNN-*/`
- Migrated docs go directly to shared (they're already team documents)

**Breaking changes:** None - backward compatible

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
