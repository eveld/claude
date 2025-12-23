---
name: before-file-search
description: Use BEFORE running grep or glob commands. Reminds you to use codebase-locator agent instead of basic file search tools.
---

# Before File Search

**STOP**: You're about to use grep or glob.

## Use codebase-locator Instead

The `codebase-locator` agent is specifically designed for finding files and components. It's more efficient and comprehensive than grep/glob.

### Instead of:
```
Grep(pattern="authentication", ...)
Glob(pattern="**/auth*.js")
```

### Do this:
```
Task(
  subagent_type="codebase-locator",
  prompt="Find all authentication-related files",
  description="Locate auth files"
)
```

## When Basic Tools Are OK

Only use grep/glob when:
- User explicitly asks for a simple file listing
- You need to check if a specific file exists
- You're doing a quick verification of a known path

For all exploratory searches, use `codebase-locator`.
