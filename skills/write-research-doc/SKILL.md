---
name: write-research-doc
description: Use when documenting research findings to create properly structured research documents with frontmatter, sections, and file references.
---

# Write Research Document

Create structured research documents following project conventions.

## Document Structure

Use the template from `templates/research-document.md`:

1. **Frontmatter** (YAML):
   - date, researcher, git info, topic, tags, status
   - **NEW**: feature_slug (e.g., "0005-authentication")

2. **Research Question**:
   - Original user query verbatim

3. **Summary**:
   - High-level findings (2-3 paragraphs)

4. **Detailed Findings**:
   - Organized by component/area
   - Include file:line references
   - Explain purpose and implementation

5. **Key Discoveries**:
   - Bullet list of important findings

6. **Implementation Patterns**:
   - Common patterns found

7. **References**:
   - Links to source files and related docs

## File Path and Naming

Determine feature slug first using `determine-feature-slug` skill:
- Auto-detects next number (0001, 0002, etc.)
- Suggests description from research question
- Prompts user to accept or customize

Save to: `thoughts/NNNN-description/research.md`

Example workflow:
1. User provides research question: "How does authentication work?"
2. Skill suggests: `0005-authentication`
3. User accepts or modifies
4. Document saved to: `thoughts/0005-authentication/research.md`

**Backward compatibility**: Old path `thoughts/shared/research/YYYY-MM-DD-NN-description.md` still recognized by all commands.

## Metadata Collection

Use `gather-project-metadata` skill to get:
- Timestamp
- Git commit and branch
- Repository name

## File References

Always include specific file:line references:
- `src/auth/handler.go:45` - Format for references
- Use actual line numbers where functions/types are defined

## Path Corrections

Watch for these common mistakes:
- ✅ `thoughts/shared/research/` - Correct for shared research
- ❌ `thoughts/searchable/` - Old path, don't use
- ✅ `thoughts/notes/` - Correct for reference documents
