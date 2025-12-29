# Claude Workflows Plugin

Research, planning, and implementation workflows for Claude Code.

This plugin provides three workflow commands for codebase research, implementation planning, and execution. It includes 24 skills that guide Claude to use specialized agents instead of basic tools, and 17 agents with isolated contexts for focused tasks like codebase exploration and platform debugging.

The plugin automatically discovers project-specific commands and test patterns, generates structured documents, and provides tools for debugging GCP, Kubernetes, and Linear issues.

## Installation

```bash
/plugin marketplace add eveld/claude
/plugin install workflows@eveld-claude
```

Manual installation:
```bash
git clone https://github.com/eveld/claude.git
ln -s $(pwd) ~/.claude/plugins/workflows
```

## Commands

- **`/workflows:research <question>`** - Research codebase using parallel agents, save to `thoughts/shared/research/`
- **`/workflows:plan <ticket-file>`** - Create implementation plan, auto-discover project commands/tests, save to `thoughts/shared/plans/`
- **`/workflows:implement <plan-file>`** - Execute plan phase by phase with verification

## Skills (24)

Skills guide Claude's behavior automatically:

**Agent Awareness:**
- Guide Claude to use specialized agents instead of grep/glob/read
- Intercept basic tool usage patterns

**Platform Debugging:**
- `gcp-logs` - Query GCP Cloud Logging
- `k8s-query` - Query Kubernetes resources
- `k8s-debug` - Launch debug containers in pods
- `linear-issues` - Fetch Linear tickets
- `linear-update` - Update Linear tickets

**Workflows:**
- `discover-project-commands` - Auto-discover make/npm/build commands
- `discover-test-patterns` - Auto-discover test conventions
- `follow-test-patterns` - Apply project test patterns
- `write-research-doc` - Format research documents
- `write-plan-doc` - Format implementation plans
- `write-commit-message` - Conventional commit format
- `write-pr-description` - Structured PR descriptions
- `debug-systematically` - 6-step debugging process

See `skills/` directory for complete list.

## Agents (17)

Specialized agents with isolated contexts for focused tasks:

**Codebase:**
- `codebase-locator` - Find files and components
- `codebase-analyzer` - Understand code implementation
- `codebase-pattern-finder` - Find similar patterns
- `thoughts-locator` - Find documentation
- `thoughts-analyzer` - Extract insights from docs
- `error-analyzer` - Analyze errors and stack traces
- `web-search-researcher` - External research

**Platform Debugging (3-stage pipeline: locate → analyze → find patterns):**
- `gcp-locator/analyzer/pattern-finder` - GCP Cloud Logging
- `k8s-locator/analyzer/pattern-finder` - Kubernetes diagnostics
- `linear-locator/analyzer/pattern-finder` - Linear issue tracking

## License

MIT
