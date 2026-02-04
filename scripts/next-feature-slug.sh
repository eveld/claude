#!/usr/bin/env bash
set -euo pipefail

# Find next feature number
NEXT_NUM=$(ls -1 thoughts/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1 || echo "0000")
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM} + 1)))

# Get suggested description from argument or prompt
SUGGESTED="${1:-}"
if [ -z "$SUGGESTED" ]; then
    echo "Next feature number: $NEXT_NUM"
    read -p "Enter feature description (kebab-case): " SUGGESTED
fi

# Validate and normalize description
DESC=$(echo "$SUGGESTED" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

if [ -z "$DESC" ]; then
    echo "Error: Description cannot be empty" >&2
    exit 1
fi

if [ ${#DESC} -lt 3 ] || [ ${#DESC} -gt 50 ]; then
    echo "Error: Description must be 3-50 characters" >&2
    exit 1
fi

# Output slug
echo "${NEXT_NUM}-${DESC}"
