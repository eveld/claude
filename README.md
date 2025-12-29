# Claude Workflows Plugin

Custom research, planning, and implementation workflows for Claude Code with intelligent agent awareness.

## Features

### Core Commands
- `/workflows:research` - Comprehensive codebase research with parallel agent orchestration
- `/workflows:plan` - Interactive implementation planning with project-specific discovery
- `/workflows:implement` - Systematic plan execution with automatic verification

### Intelligent Agent Awareness
Claude automatically uses specialized agents instead of basic tools:

**Codebase Agents:**
- `codebase-locator` - Find WHERE code lives
- `codebase-analyzer` - Understand HOW code works
- `codebase-pattern-finder` - Find similar implementations
- `thoughts-locator` - Discover documentation
- `thoughts-analyzer` - Extract insights from docs
- `web-search-researcher` - External research
- `error-analyzer` - Deep error analysis

**Platform Debugging Agents** (conserve context during complex investigations):
- `gcp-locator` / `gcp-analyzer` / `gcp-pattern-finder` - GCP Cloud Logging analysis
- `k8s-locator` / `k8s-analyzer` / `k8s-pattern-finder` - Kubernetes diagnostics
- `linear-locator` / `linear-analyzer` / `linear-pattern-finder` - Linear issue analysis

Each domain follows 3-stage pipeline:
1. **Locator** - Fetch data broadly (logs, resources, issues)
2. **Analyzer** - Filter and diagnose specific services/resources
3. **Pattern-finder** - Correlate across multiple sources, find patterns

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

2. **Install the plugin**:
```bash
# Copy to Claude plugins directory
cp -r . ~/.claude/plugins/workflows/

# Or use symlink for development
ln -s $(pwd) ~/.claude/plugins/workflows
```

3. **Verify installation**:
```bash
# Check skills are available
ls ~/.claude/plugins/workflows/skills/
```

### Installation via Plugin System

```bash
/plugin marketplace add eveld/claude
/plugin install workflows@eveld-claude
```

## Usage

### Research Command

Conduct comprehensive codebase research:

```bash
/workflows:research how does authentication work in the codebase?
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
/workflows:plan thoughts/tickets/add-email-notifications.md
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
/workflows:implement thoughts/shared/plans/YYYY-MM-DD-01-feature-name.md
```

**What happens**:
1. Claude reads plan and reference documents
2. Implements phase by phase
3. Follows test patterns from `thoughts/notes/testing.md`
4. Verifies using commands from `thoughts/notes/commands.md`
5. Updates checkboxes in plan as it progresses

## Project Directory Structure

When using the workflows plugin, the following directory structure is created in your project:

```
your-project/
├── thoughts/
│   ├── shared/
│   │   ├── research/        # Research documents from /workflows:research
│   │   └── plans/           # Implementation plans from /workflows:plan
│   └── notes/
│       ├── commands.md      # Auto-discovered project commands
│       └── testing.md       # Auto-discovered test patterns
└── [your project files...]
```

**Note**: The `thoughts/` directory is created automatically when you use the plugin commands. It stores research, plans, and project metadata in your working directory.

### Autonomous Skill Usage

Skills work without explicit commands:

**Finding files**:
```
User: "Find all authentication code"
Claude: [Uses codebase-locator agent automatically]
```

**Platform debugging**:
```
User: "Get details for Linear ticket ENG-1234"
Claude: [Uses linear-awareness → linear-issues skill]

User: "Show me GCP errors for api-gateway"
Claude: [Uses gcp-awareness → gcp-logs skill]

User: "Check if production pods are running"
Claude: [Uses k8s-awareness → k8s-query skill]

User: "Debug the crashing pod api-gateway-xyz"
Claude: [Uses k8s-awareness → k8s-debug skill]

User: "Add my findings to ENG-1234"
Claude: [Uses linear-awareness → linear-update skill]

User: "Investigate production errors across service-a and backend"
Claude: [Uses debugging-awareness → spawns gcp-locator + gcp-analyzer + gcp-pattern-finder agents]

User: "Find why multiple pods are ImagePullBackOff"
Claude: [Uses k8s-awareness → spawns k8s-locator + k8s-pattern-finder agents]

User: "Find recurring VCS permission errors in Linear"
Claude: [Uses linear-awareness → spawns linear-locator + linear-pattern-finder agents]
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
├── agents/                  # Specialized subagents (17)
│   ├── codebase-locator.md
│   ├── codebase-analyzer.md
│   ├── codebase-pattern-finder.md
│   ├── thoughts-locator.md
│   ├── thoughts-analyzer.md
│   ├── web-search-researcher.md
│   ├── error-analyzer.md
│   ├── gcp-locator.md
│   ├── gcp-analyzer.md
│   ├── gcp-pattern-finder.md
│   ├── k8s-locator.md
│   ├── k8s-analyzer.md
│   ├── k8s-pattern-finder.md
│   ├── linear-locator.md
│   ├── linear-analyzer.md
│   └── linear-pattern-finder.md
├── commands/                # Workflow orchestration (3)
│   ├── research.md
│   ├── plan.md
│   └── implement.md
├── skills/                  # Reusable capabilities (24)
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
│   ├── debug-systematically/
│   ├── debugging-awareness/
│   ├── gcp-awareness/
│   ├── gcp-logs/
│   ├── k8s-awareness/
│   ├── k8s-debug/
│   ├── k8s-query/
│   ├── linear-awareness/
│   ├── linear-issues/
│   └── linear-update/
└── templates/               # Document templates (4)
    ├── research-document.md
    ├── plan-document.md
    ├── commands-reference.md
    └── testing-reference.md
```

### How It Works

**Slash Commands** → Workflow orchestration
- User invokes with `/workflows:research`, `/workflows:plan`, `/workflows:implement`
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

**Tier 1 - Agent Awareness & Platform Discovery** (Fix discovery):
- `agent-awareness` - Master guide for codebase agents
- `before-file-search` - Intercept grep/glob
- `before-code-analysis` - Intercept file reading
- `before-spawning-task` - Ensure correct agent
- `gcp-awareness` - Guide for GCP debugging skills
- `k8s-awareness` - Guide for Kubernetes debugging skills
- `linear-awareness` - Guide for Linear ticket management skills
- `debugging-awareness` - Master platform debugging workflow

**Tier 2 - Core Workflows & Platform Tools** (Enable commands and debugging):
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
- `gcp-logs` - GCP Cloud Logging queries
- `k8s-query` - Kubernetes resource queries
- `k8s-debug` - K8s debug containers
- `linear-issues` - Linear issue/ticket queries
- `linear-update` - Linear issue updates

**Tier 3 - Supporting** (Utilities):
- `gather-project-metadata` - Collect git info
- `verify-implementation` - Run verification

## Troubleshooting

### Claude still using grep/glob instead of agents

1. Check skills are installed:
```bash
ls ~/.claude/plugins/workflows/skills/*/SKILL.md
```

2. Verify agent-awareness skill exists:
```bash
cat ~/.claude/plugins/workflows/skills/agent-awareness/SKILL.md
```

3. Restart Claude Code to reload the plugin

### Commands not found

Verify plugin is installed:
```bash
ls ~/.claude/plugins/workflows/commands/
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
