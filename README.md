# Claude Workflows Plugin

Custom research, planning, and implementation workflows for Claude Code with intelligent agent awareness.

## Features

### Core Commands
- `/research` - Comprehensive codebase research with parallel agent orchestration
- `/plan` - Interactive implementation planning with project-specific discovery
- `/implement` - Systematic plan execution with automatic verification

### Intelligent Agent Awareness
Claude automatically uses specialized agents instead of basic tools:
- `codebase-locator` - Find WHERE code lives
- `codebase-analyzer` - Understand HOW code works
- `codebase-pattern-finder` - Find similar implementations
- `thoughts-locator` - Discover documentation
- `thoughts-analyzer` - Extract insights from docs
- `web-search-researcher` - External research
- `error-analyzer` - Deep error analysis

### New Capabilities
- Project command discovery → `thoughts/notes/commands.md`
- Test pattern discovery → `thoughts/notes/testing.md`
- Conventional commit messages
- Structured PR descriptions
- Systematic debugging process

## Installation

### Prerequisites
- Claude Code CLI installed
- Git repository (recommended)

### Quick Start

1. **Clone the repository**:
```bash
git clone https://github.com/eveld/claude.git
cd claude
```

2. **Switch to new setup**:
```bash
./scripts/switch-setup.sh new
```

3. **Verify installation**:
```bash
./scripts/switch-setup.sh status
```

### Installation via Plugin System (Future)

When available:
```bash
/plugin marketplace add eveld/claude
/plugin install eveld-workflows@eveld-claude
```

## Usage

### Research Command

Conduct comprehensive codebase research:

```bash
/research how does authentication work in the codebase?
```

**What happens**:
1. Claude spawns specialized agents in parallel
2. Agents locate, analyze, and document findings
3. Results compiled into structured document
4. Saved to `thoughts/shared/research/YYYY-MM-DD-01-*.md`

**Example output**:
- Frontmatter with git metadata
- Research question and summary
- Detailed findings with file:line references
- Key discoveries and patterns

### Plan Command

Create detailed implementation plans:

```bash
/plan thoughts/tickets/add-email-notifications.md
```

**What happens**:
1. Claude reads ticket and spawns planning agents
2. Discovers available commands → `thoughts/notes/commands.md`
3. Discovers test patterns → `thoughts/notes/testing.md`
4. Collaborates on approach
5. Creates structured plan with phases and success criteria
6. Saved to `thoughts/shared/plans/YYYY-MM-DD-01-*.md`

**Plan includes**:
- Current state analysis
- Desired end state with verification
- What we're NOT doing (scope control)
- Phases with specific changes
- Automated vs manual success criteria
- References to commands.md and testing.md

### Implement Command

Execute approved implementation plans:

```bash
/implement thoughts/shared/plans/YYYY-MM-DD-01-feature-name.md
```

**What happens**:
1. Claude reads plan and reference documents
2. Implements phase by phase
3. Follows test patterns from `thoughts/notes/testing.md`
4. Verifies using commands from `thoughts/notes/commands.md`
5. Updates checkboxes in plan as it progresses

### Autonomous Skill Usage

Skills work without explicit commands:

**Finding files**:
```
User: "Find all authentication code"
Claude: [Uses codebase-locator agent automatically]
```

**Creating documents**:
```
User: "Can you document these findings?"
Claude: [Uses write-research-doc skill automatically]
```

**Committing code**:
```
User: "Commit these changes"
Claude: [Uses write-commit-message skill for conventional commits]
```

## Architecture

### Directory Structure

```
github.com/eveld/claude/
├── .claude-plugin/          # Plugin metadata
│   ├── plugin.json
│   └── marketplace.json
├── agents/                  # Specialized subagents (7)
│   ├── codebase-locator.md
│   ├── codebase-analyzer.md
│   ├── codebase-pattern-finder.md
│   ├── thoughts-locator.md
│   ├── thoughts-analyzer.md
│   ├── web-search-researcher.md
│   └── error-analyzer.md
├── commands/                # Workflow orchestration (3)
│   ├── research.md
│   ├── plan.md
│   └── implement.md
├── skills/                  # Reusable capabilities (16)
│   ├── agent-awareness/
│   ├── before-file-search/
│   ├── before-code-analysis/
│   ├── before-spawning-task/
│   ├── spawn-research-agents/
│   ├── spawn-planning-agents/
│   ├── write-research-doc/
│   ├── write-plan-doc/
│   ├── discover-project-commands/
│   ├── discover-test-patterns/
│   ├── follow-test-patterns/
│   ├── gather-project-metadata/
│   ├── verify-implementation/
│   ├── write-commit-message/
│   ├── write-pr-description/
│   └── debug-systematically/
├── templates/               # Document templates (4)
│   ├── research-document.md
│   ├── plan-document.md
│   ├── commands-reference.md
│   └── testing-reference.md
└── scripts/                 # Utility scripts
    └── switch-setup.sh
```

### How It Works

**Slash Commands** → Workflow orchestration
- User invokes with `/research`, `/plan`, `/implement`
- Commands compose skills to achieve goals
- Thin orchestration layer

**Skills** → Reusable capabilities
- Claude discovers and uses autonomously
- Provide domain knowledge and guidance
- Composable across different contexts

**Agents** → Specialized sub-tasks
- Isolated context windows
- Focused toolsets (Grep, Glob, Read, LS)
- Parallel execution for efficiency

### Three Tiers of Skills

**Tier 1 - Agent Awareness** (Fix discovery):
- `agent-awareness` - Master guide
- `before-file-search` - Intercept grep/glob
- `before-code-analysis` - Intercept file reading
- `before-spawning-task` - Ensure correct agent

**Tier 2 - Core Workflows** (Enable commands):
- `spawn-research-agents` - Research orchestration
- `spawn-planning-agents` - Planning orchestration
- `write-research-doc` - Research formatting
- `write-plan-doc` - Plan formatting
- `discover-project-commands` - Find available commands
- `discover-test-patterns` - Find test conventions
- `follow-test-patterns` - Apply conventions
- `write-commit-message` - Conventional commits
- `write-pr-description` - Structured PRs
- `debug-systematically` - Systematic debugging

**Tier 3 - Supporting** (Utilities):
- `gather-project-metadata` - Collect git info
- `verify-implementation` - Run verification

## Rollback

If you need to switch back to the old setup:

```bash
./scripts/switch-setup.sh old
```

This restores your previous `~/.claude/` configuration.

To check current status:

```bash
./scripts/switch-setup.sh status
```

## Troubleshooting

### Claude still using grep/glob instead of agents

1. Check skills are installed:
```bash
ls ~/.claude/skills/*/SKILL.md
```

2. Verify agent-awareness skill exists:
```bash
cat ~/.claude/skills/agent-awareness/SKILL.md
```

3. Try switching again:
```bash
./scripts/switch-setup.sh old
./scripts/switch-setup.sh new
```

### Commands not found

Verify commands are installed:
```bash
ls ~/.claude/commands/
```

Should show: `research.md`, `plan.md`, `implement.md`

### Documents not created in correct location

Check directory exists:
```bash
mkdir -p thoughts/shared/research thoughts/shared/plans thoughts/notes
```

## References

- Research document: `thoughts/shared/research/2025-12-23-01-migration-to-skills-architecture.md`
- Implementation plan: `thoughts/shared/plans/2025-12-23-01-skills-architecture-migration.md`
- Claude Code docs: https://docs.anthropic.com/claude/claude-code
