---
name: follow-test-patterns
description: Use when writing tests to ensure they follow project conventions. References patterns from thoughts/notes/testing.md.
---

# Follow Test Patterns

Reference discovered test patterns when writing tests to ensure consistency with project conventions.

## When to Use

- Before writing any test file
- When implementing test-related phases in plans
- When user asks you to add tests

## Workflow

### 1. Check for Pattern Document
```bash
if [ -f thoughts/notes/testing.md ]; then
  # Read and follow patterns
else
  # Prompt user to run discover-test-patterns first
  echo "No test patterns found. Run discover-test-patterns skill first."
fi
```

### 2. Read Pattern Document

Read `thoughts/notes/testing.md` fully to understand:
- File naming conventions
- Testing framework and imports
- Test structure (table-driven, etc.)
- Assertion style
- Mocking approach

### 3. Apply Patterns to New Tests

Use the discovered patterns for:

**File Naming**:
- Follow the pattern (e.g., `*_test.go`, `*.test.ts`)
- Place alongside source or in test directory as per convention

**Imports**:
- Use same testing framework (testify, jest, pytest)
- Import same assertion libraries

**Test Structure**:
- If codebase uses table-driven tests, use that pattern
- If codebase uses describe/it blocks, use that pattern
- Match indentation and formatting

**Assertions**:
- Use same assertion style (require.Equal vs assert.Equal)
- Follow error message conventions

**Mocking**:
- Use same mocking library (mockery, jest.mock, unittest.mock)
- Follow interface/class mocking patterns found in codebase

### 4. Verify Consistency

After writing tests, verify:
- File name matches convention
- Framework imports are correct
- Test structure matches examples
- Assertions use same style
- Tests are in correct location

## Example

If `thoughts/notes/testing.md` shows:
```
## Go Test Patterns
- File: `*_test.go` alongside source
- Framework: testify/require
- Pattern: Table-driven tests
```

Then write:
```go
package handlers

import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestNewFeature(t *testing.T) {
    tests := []struct {
        name string
        input FeatureInput
        want FeatureOutput
    }{
        {name: "valid case", input: ..., want: ...},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := NewFeature(tt.input)
            require.Equal(t, tt.want, got)
        })
    }
}
```

## Benefits

- Tests automatically match project style
- Reduces review feedback
- Faster test writing with clear examples
- Consistency across all new tests
