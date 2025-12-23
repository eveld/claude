---
name: discover-test-patterns
description: Use during planning to discover and document test patterns and conventions for writing consistent tests.
---

# Discover Test Patterns

Automatically discover and document test patterns used in the project for reference during planning and implementation.

## What to Discover

### Test File Organization
- Location patterns (e.g., `*_test.go`, `*.test.ts`, `test_*.py`)
- Directory structure (e.g., `tests/`, `__tests__/`, alongside source)
- Framework being used

### Common Patterns
Find and document:
- How tests are structured (describe/it, test functions, etc.)
- Assertion style (testify, chai, pytest, etc.)
- Mocking approach (mockery, jest.mock, unittest.mock, etc.)
- Setup/teardown patterns
- Table-driven test examples

### Framework Detection
Identify testing frameworks:
- **Go**: testing, testify, ginkgo
- **TypeScript/JavaScript**: Jest, Mocha, Vitest
- **Python**: pytest, unittest
- **Rust**: built-in test framework

## Discovery Process

1. **Find test files**: Use glob patterns to locate tests
2. **Read examples**: Read 2-3 representative test files
3. **Extract patterns**: Identify common structures and styles
4. **Document**: Use template to create reference doc

## Output Format

Write to: `thoughts/notes/testing.md`

Use the template from `templates/testing-reference.md` and populate with discovered patterns.

## Example Output Structure

```markdown
---
last_updated: 2025-12-23T10:00:00Z
last_updated_by: Claude
project: my-project
---

# Test Patterns Reference

Last discovered: 2025-12-23

## Go Test Patterns

### File Organization
- **Location**: `*_test.go` files alongside source
- **Framework**: testify/require
- **Example**: `internal/auth/handler_test.go`

### Common Pattern: Table-Driven Tests
**Found in**: `internal/auth/handler_test.go:45-78`

```go
func TestAuthHandler(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        // test cases
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            require.Equal(t, tt.expected, result)
        })
    }
}
```

### Assertion Style
- Use `require` for assertions that should stop test
- Use `assert` for non-critical checks

### Mocking Approach
- Mockery-generated mocks in `mocks/` directory
- Interface-based mocking pattern
```

## When to Use

Automatically invoked by the `plan` command if `thoughts/notes/testing.md` doesn't exist.
