---
name: determine-feature-slug
description: Determine feature slug interactively by auto-detecting next number and prompting user for description
---

# Determine Feature Slug

Interactively determine the next feature slug for personal workspace in the thoughts directory structure.

## How It Works

1. **Determine Namespace**:
   - Default to git user: `git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-'`
   - Or accept namespace parameter
   - Personal workspace: `thoughts/{namespace}/`
   - Shared workspace: `thoughts/shared/` (used by share-docs skill)

2. **Find Next Number**:
   - Scan `thoughts/{namespace}/` directory for existing feature directories
   - Pattern: `^[0-9]{4}-.*`
   - Find highest number and add 1
   - Default to 0001 if no features exist

3. **Suggest Description**:
   - From research question: Extract key terms, convert to kebab-case
   - From plan title: Extract feature name, convert to kebab-case
   - Fallback: Prompt without suggestion

4. **Prompt User with AskUserQuestion**:
   - Show suggested slug as an option
   - User can accept suggestion or select "Other" to provide custom description
   - Example:
     ```
     AskUserQuestion:
       question: "Choose feature slug description (will be: erik/0004-[description])"
       header: "Feature Name"
       options:
         - "authentication-system" - Suggested based on context
     ```
   - Validate: Only lowercase letters, numbers, hyphens

5. **Return Result**:
   - Format: `{namespace}/NNNN-description`
   - Create directory: `thoughts/{namespace}/NNNN-description/`

## Example Usage

```bash
# Determine namespace (default to git user)
NAMESPACE=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Auto-detect next number in personal namespace
NEXT_NUM=$(ls -1 thoughts/${NAMESPACE}/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1)
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM:-0} + 1)))

# Suggest from context (research question, plan title)
SUGGESTED_DESC=$(echo "$RESEARCH_QUESTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

# Prompt user with AskUserQuestion
# Present suggested slug as option, user can select "Other" for custom input
# AskUserQuestion returns the selected value
DESC="$SUGGESTED_DESC"  # Use result from AskUserQuestion

# Create directory in personal namespace
mkdir -p "thoughts/${NAMESPACE}/${NEXT_NUM}-${DESC}"
echo "${NAMESPACE}/${NEXT_NUM}-${DESC}"
```

## Validation

- Namespace must be valid (lowercase, hyphens, from git user.name)
- Number must be 4 digits, zero-padded
- Description must be kebab-case (lowercase, hyphens only)
- Directory must not already exist in namespace
- Description length: 3-50 characters

## Collaboration Model

**Personal namespace**: `thoughts/{username}/NNNN-slug/`
- Each developer has own numbering sequence
- No conflicts between developers
- Work-in-progress documents

**Shared namespace**: `thoughts/shared/NNNN-slug/`
- Assigned by `share-docs` skill when publishing
- Canonical team numbering
- Published documents

This skill always creates documents in personal namespace. Use `share-docs` to promote to shared.
