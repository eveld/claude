---
name: determine-feature-slug
description: Determine feature slug interactively by auto-detecting next number and prompting user for description
---

# Determine Feature Slug

Interactively determine the next feature slug for the thoughts directory structure.

## How It Works

1. **Find Next Number**:
   - Scan `thoughts/` directory for existing feature directories
   - Pattern: `^[0-9]{4}-.*`
   - Find highest number and add 1
   - Default to 0001 if no features exist

2. **Suggest Description**:
   - From research question: Extract key terms, convert to kebab-case
   - From plan title: Extract feature name, convert to kebab-case
   - Fallback: Prompt without suggestion

3. **Prompt User**:
   - Show suggested slug: "Next slug: 0004-authentication-system"
   - Ask: "Accept this slug or provide custom description?"
   - Validate: Only lowercase letters, numbers, hyphens

4. **Return Result**:
   - Format: `NNNN-description`
   - Create directory: `thoughts/NNNN-description/`

## Example Usage

```bash
# Auto-detect and suggest
NEXT_NUM=$(ls -1 thoughts/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1)
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM:-0} + 1)))

# Suggest from context (research question, plan title)
SUGGESTED_DESC=$(echo "$RESEARCH_QUESTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

# Prompt user
echo "Suggested slug: ${NEXT_NUM}-${SUGGESTED_DESC}"
echo "Press Enter to accept, or type custom description:"
read USER_DESC
DESC=${USER_DESC:-$SUGGESTED_DESC}

# Create directory
mkdir -p "thoughts/${NEXT_NUM}-${DESC}"
echo "${NEXT_NUM}-${DESC}"
```

## Validation

- Number must be 4 digits, zero-padded
- Description must be kebab-case (lowercase, hyphens only)
- Directory must not already exist
- Description length: 3-50 characters
