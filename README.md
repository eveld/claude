# Claude Workflows Plugin

Custom research, planning, and implementation workflows for Claude Code with intelligent agent-awareness.

## Overview

This plugin provides:
- **Slash Commands**: `/research`, `/plan`, `/implement` for explicit workflow invocation
- **Skills**: Atomic, reusable capabilities that Claude autonomously discovers
- **Agent-Awareness**: Skills that guide Claude to use specialized agents consistently
- **Subagents**: Specialized agents for codebase exploration and research

## Installation

### Via Plugin System

```bash
# Add the marketplace
/plugin marketplace add eveld/claude

# Install the plugin
/plugin install eveld-workflows@eveld-claude --scope user
```

### For Development

```bash
# Test locally without installing
claude --plugin-dir /Users/erik/code/erik/claude
```

## Features

### Slash Commands

- `/research [query]` - Comprehensive codebase research with automated documentation
- `/plan [ticket/description]` - Interactive implementation planning with phased approach
- `/implement [plan-path]` - Execute implementation plans with verification

### Skills (11 Total)

**Tier 1 - Agent Discovery Fix**:
- `agent-awareness` - Master guide for when to use specialized agents
- `before-file-search` - Intercepts grep/glob to recommend codebase-locator
- `before-code-analysis` - Intercepts multi-file reading to recommend codebase-analyzer
- `before-spawning-task` - Ensures correct subagent_type selection

**Tier 2 - Core Workflows**:
- `spawn-research-agents` - Orchestrate research agents in parallel
- `spawn-planning-agents` - Orchestrate planning agents effectively
- `write-research-doc` - Structure research documents with frontmatter
- `write-plan-doc` - Structure implementation plans with phases
- `discover-project-commands` ⭐ - Find actual make/npm commands (prevents suggesting non-existent commands)

**Tier 3 - Supporting**:
- `gather-project-metadata` - Collect git commit, branch, repo info
- `verify-implementation` - Verify code changes work (uses discover-project-commands)

### Specialized Agents

- `codebase-locator` - Find WHERE code lives in the codebase
- `codebase-analyzer` - Understand HOW code works
- `codebase-pattern-finder` - Find SIMILAR implementation examples
- `thoughts-locator` - Discover documentation and notes
- `thoughts-analyzer` - Extract insights from documents
- `web-search-researcher` - External research and documentation
- `jira-locator` - JIRA issue discovery

## Problems Solved

### Problem 1: Claude Ignores Specialized Agents

**Before**: Claude would often ignore specialized agents and use basic tools (grep, glob) directly, resulting in:
- Inefficient searches
- Incomplete results
- Context pollution

**After**: Agent-awareness skills intercept Claude's decision-making and guide toward specialized agents, ensuring:
- Consistent use of appropriate tools
- Better search results
- Cleaner context management

### Problem 2: Suggesting Non-Existent Commands

**Before**: Claude would suggest verification commands that don't exist:
- `make test-integration` (when only `make test` exists)
- `npm run typecheck` (when no such script is defined)
- Invalid commands in plans requiring manual correction

**After**: `discover-project-commands` skill finds actual available commands:
- Verifies make targets and npm scripts exist
- Suggests closest equivalents for missing commands
- Offers to create useful missing commands
- Ensures plans are immediately actionable

## Architecture

```
commands/          # Thin orchestration layers
skills/            # Atomic, reusable capabilities
agents/            # Specialized subagents
scripts/           # Utility scripts
```

See [thoughts/shared/research/2025-12-23-01-migration-to-skills-architecture.md](thoughts/shared/research/2025-12-23-01-migration-to-skills-architecture.md) for detailed architecture documentation.

## Development Status

**Current Status**: Planning phase

See the architecture document for the complete implementation plan.

## License

[Your License Here]
