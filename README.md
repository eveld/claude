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
- **`/workflows:plan <research-file>`** - Create implementation plan, auto-discover project commands/tests, save to `thoughts/shared/plans/`
- **`/workflows:implement <plan-file>`** - Execute plan phase by phase with verification

### Directory Structure (v1.3.0+)

Starting with v1.3.0, documents use personal/shared namespaces for collaboration:

```
thoughts/
├── erik/                    # Personal workspace (WIP)
│   ├── 0001-auth-system/
│   │   ├── research.md
│   │   ├── plan.md
│   │   └── changelog.md
│   └── 0002-api-redesign/
│       └── research.md
├── alice/                   # Another developer's workspace
│   └── 0001-cache-layer/
│       └── research.md
├── shared/                  # Published team documents
│   ├── 0042-auth-system/   # Shared from erik/0001
│   │   ├── research.md
│   │   ├── plan.md
│   │   └── changelog.md
│   ├── 0043-cache-layer/   # Shared from alice/0001
│   │   └── research.md
│   ├── research/            # Legacy: Old research documents
│   └── plans/               # Legacy: Old implementation plans
└── notes/                   # Project-wide references
    ├── commands.md
    └── testing.md
```

**Collaboration Model**:
- **Personal namespace** (`thoughts/{username}/`): Work-in-progress, each developer has own numbering
- **Shared namespace** (`thoughts/shared/`): Published docs with canonical team numbering
- **No conflicts**: Personal numbering never conflicts between developers
- **Explicit sharing**: Use `/share-docs` to promote personal docs to shared space

**Backward Compatibility**: Old `thoughts/shared/` structure continues to work.

### Sharing Documents

When ready to share personal documents with the team:

```bash
/share-docs thoughts/erik/0001-auth-system

# Workflow:
# 1. Pulls latest from git
# 2. Finds next shared number (e.g., 0042)
# 3. Copies erik/0001-auth-system → shared/0042-auth-system
# 4. Updates frontmatter in both copies
# 5. Commits and pushes immediately
# 6. Reports: ✅ Shared erik/0001-auth-system → shared/0042-auth-system
```

**Benefits**:
- Zero numbering conflicts during development
- Atomic sharing with git push
- Clear distinction between WIP and published docs
- Personal copy preserved with reference to shared location

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

### Agent Orchestration

Implementation uses agents to conserve context:
- **Analysis agents** (parallel) - Gather patterns and architecture
- **Test writer agent** - Generate tests following conventions
- **Verification agent** - Run checks and return summary

This keeps the main agent under 40k tokens per phase while enabling larger, more complex phases.

**Token savings**: 60% reduction per phase (92k → 40k in main agent)

See `skills/spawn-implementation-agents/SKILL.md` for full pattern.

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
