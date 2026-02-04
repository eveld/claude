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
- New skills: `determine-feature-slug`, `upgrade-plugin`
- New templates: Feature slug support in research and plan templates
- Upgrade command: `/workflows:upgrade` for version migrations
- Version tracking: `migrations/version.txt`

### Changed
- Document-writing skills now create feature directories
- Commands support both old (`thoughts/shared/`) and new directory structures
- Plan template includes feature slug metadata
- Research template includes feature_slug in frontmatter
- thoughts-locator agent searches both old and new structures
- thoughts-analyzer agent handles both directory formats

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

## [1.2.1] - 2026-02-03

### Added
- Extracted PR description template to `templates/pr-description.md`
- Extracted commit message template to `templates/commit-message.md`

### Changed
- `write-pr-description` skill now references template file
- `write-commit-message` skill now references template file
