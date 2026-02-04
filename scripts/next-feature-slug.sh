#!/usr/bin/env bash
set -euo pipefail

# Determine namespace (default to git user)
NAMESPACE="${1:-}"
if [ -z "$NAMESPACE" ]; then
    NAMESPACE=$(git config user.name 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' || echo "default")
fi

# Find next feature number in personal namespace
NEXT_NUM=$(ls -1 "thoughts/${NAMESPACE}/" 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1 || echo "0000")
NEXT_NUM=$(printf "%04d" $((10#${NEXT_NUM} + 1)))

# Get suggested description from second argument or prompt
SUGGESTED="${2:-}"
if [ -z "$SUGGESTED" ]; then
    echo "Namespace: ${NAMESPACE}"
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

# Create directory in personal namespace
mkdir -p "thoughts/${NAMESPACE}/${NEXT_NUM}-${DESC}"

# Output slug with namespace
echo "${NAMESPACE}/${NEXT_NUM}-${DESC}"
