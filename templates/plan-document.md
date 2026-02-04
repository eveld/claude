# {FEATURE_NAME} Implementation Plan

<!-- Feature: {FEATURE_SLUG} -->
<!-- Created: {ISO_TIMESTAMP} -->

## Overview
{BRIEF_DESCRIPTION}

## Current State Analysis
{WHAT_EXISTS_NOW}

## Desired End State
{SPECIFICATION_AND_VERIFICATION}

### Key Discoveries:
- {FINDING_WITH_FILE_LINE}
- {PATTERN_TO_FOLLOW}
- {CONSTRAINT}

## What We're NOT Doing
{OUT_OF_SCOPE_ITEMS}

## Implementation Approach
{HIGH_LEVEL_STRATEGY}

## Project References
- Commands: See `thoughts/notes/commands.md` (last updated: {DATE})
- Test Patterns: See `thoughts/notes/testing.md` (last updated: {DATE})

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

## Milestone 1: {MILESTONE_NAME}

**Goal**: {USER_FACING_OUTCOME}
**Testable**: {HOW_USER_CAN_VERIFY}

### Phase 1.1: {PHASE_NAME}

**Estimated Complexity**: Low / Medium / High
**Token Estimate**: ~{ESTIMATE}k tokens in main agent
**Agent Strategy**: {PARALLEL_ANALYSIS | SEQUENTIAL | MINIMAL}

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

## Testing Strategy

### Unit Tests:
{UNIT_TEST_APPROACH}

### Integration Tests:
{INTEGRATION_TEST_APPROACH}

### Manual Testing Steps:
1. {SPECIFIC_VERIFICATION_STEP}
2. {ANOTHER_STEP}

## Performance Considerations
{PERFORMANCE_IMPLICATIONS}

## Migration Notes
{DATA_MIGRATION_STRATEGY}

## References
- Original ticket: `{TICKET_PATH}`
- Related research: `{RESEARCH_DOCS}`
- Similar implementation: `{FILE_LINE_REFERENCE}`
