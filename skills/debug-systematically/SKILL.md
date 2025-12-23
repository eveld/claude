---
name: debug-systematically
description: Use when encountering errors or bugs to follow a systematic debugging process instead of jumping to conclusions.
---

# Debug Systematically

Follow a structured debugging process when encountering errors or unexpected behavior.

## Debugging Process

### 1. Reproduce
**Goal**: Confirm the error consistently occurs

- Run the failing command/test again
- Document exact steps to reproduce
- Note any error messages verbatim
- Check if error is consistent or intermittent

**Example**:
```bash
# Reproduce the error
make test

# Document output
Error: undefined method 'foo' on line 42
```

### 2. Isolate
**Goal**: Narrow down to specific component/function

- Identify which component is failing
- Remove unrelated code to isolate issue
- Check if error occurs with minimal input
- Use binary search to find breaking change

**Example**:
```bash
# Test individual components
go test ./pkg/auth/handler_test.go -v -run TestLogin

# Isolate to specific function
go test ./pkg/auth -v -run TestLogin/valid_credentials
```

### 3. Hypothesize
**Goal**: Form testable theories about the cause

- Based on error message, what could cause this?
- What changed recently that might affect this?
- What assumptions might be wrong?
- What edge cases aren't handled?

**Examples**:
- Hypothesis 1: Nil pointer - missing initialization
- Hypothesis 2: Type mismatch - wrong function signature
- Hypothesis 3: Race condition - concurrent access

### 4. Test Hypotheses
**Goal**: Verify each hypothesis systematically

- Test one hypothesis at a time
- Add logging/debugging to verify assumptions
- Check related code for similar patterns
- Look at test failures for clues

**Example**:
```go
// Test hypothesis 1: nil pointer
if handler.service == nil {
    log.Printf("DEBUG: service is nil")
}

// Test hypothesis 2: check types
log.Printf("DEBUG: user type=%T, expected=*User", user)
```

### 5. Fix
**Goal**: Apply fix and verify it resolves the issue

- Implement the fix for confirmed root cause
- Run the originally failing test/command
- Verify fix doesn't break other functionality
- Clean up any debug logging

**Example**:
```go
// Fix: Initialize service before use
func NewHandler() *Handler {
    return &Handler{
        service: NewAuthService(), // was missing
    }
}
```

### 6. Prevent
**Goal**: Add tests to prevent regression

- Add test case for the bug
- Add tests for related edge cases
- Document the fix if non-obvious
- Update error handling if needed

**Example**:
```go
func TestHandlerWithNilService(t *testing.T) {
    // Ensure handler initialization is correct
    h := NewHandler()
    require.NotNil(t, h.service)
}
```

## When NOT to Skip Steps

**Don't jump to conclusions**:
- ❌ "This must be a nil pointer, let me add a nil check"
- ✅ "Let me reproduce the error and check what's actually nil"

**Don't make multiple changes at once**:
- ❌ Change 3 things, then test
- ✅ Change one thing, test, then proceed

**Don't assume error messages are wrong**:
- ❌ "That error doesn't make sense, ignore it"
- ✅ "That error is telling me exactly what's wrong"

## Tools for Debugging

### Logging
```go
log.Printf("DEBUG: variable=%+v", variable)
```

### Debugging Tools
```bash
# Go
dlv debug ./cmd/app

# Node
node --inspect-brk app.js

# Python
python -m pdb app.py
```

### Test Isolation
```bash
# Run single test
go test -v -run TestSpecificFunction
npm test -- --testNamePattern="specific test"
pytest tests/test_file.py::test_function
```

## Example Workflow

**Problem**: Test failing with "unexpected nil pointer"

**Step 1 - Reproduce**:
```bash
make test
# Output: TestLogin: unexpected nil pointer at handler.go:42
```

**Step 2 - Isolate**:
```bash
go test ./pkg/auth -v -run TestLogin
# Isolated to auth package, Login function
```

**Step 3 - Hypothesize**:
- H1: handler.service not initialized
- H2: user.Session is nil
- H3: request.Context() returning nil

**Step 4 - Test**:
```go
// Add logging at handler.go:42
log.Printf("DEBUG: handler=%+v", handler)
// Output shows handler.service is nil
```

**Step 5 - Fix**:
```go
// In NewHandler()
return &Handler{
    service: NewAuthService(), // Fix: was missing
}
```

**Step 6 - Prevent**:
```go
func TestNewHandler(t *testing.T) {
    h := NewHandler()
    require.NotNil(t, h.service)
}
```

## Benefits

- Systematic approach prevents wasted effort
- Confirms root cause before fixing
- Prevents introducing new bugs
- Documents debugging process for future reference
