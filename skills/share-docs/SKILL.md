---
name: share-docs
description: Share personal documents to the shared namespace with atomic git commit and push
---

# Share Documents

Promote personal documents to the shared namespace for team collaboration. This skill handles numbering, frontmatter updates, and git operations atomically.

## When to Use

- When a research document is complete and ready for team review
- When a plan is finalized and ready for team implementation
- When you want to publish your work to collaborators

## Workflow

### 1. Validate Personal Document

Check that the personal document exists and is ready to share:
- Path format: `thoughts/{username}/NNNN-slug/`
- Contains required files (research.md, plan.md, etc.)
- Frontmatter is complete
- No `shared_as` field yet (not already shared)

### 2. Pull Latest Changes

```bash
git pull
```

Get latest shared documents to determine next available number.

### 3. Find Next Shared Number

Scan `thoughts/shared/` for highest number:

```bash
NEXT_SHARED=$(ls -1 thoughts/shared/ 2>/dev/null | grep -E '^[0-9]{4}-' | sort -r | head -1 | cut -d'-' -f1 || echo "0000")
NEXT_SHARED=$(printf "%04d" $((10#${NEXT_SHARED} + 1)))
```

### 4. Copy to Shared

Copy entire personal directory to shared with new number:

```bash
# Example: thoughts/erik/0001-auth-system → thoughts/shared/0042-auth-system
cp -r thoughts/{username}/{NNNN}-{slug} thoughts/shared/${NEXT_SHARED}-{slug}
```

### 5. Update Frontmatter in Both Copies

**Personal copy** (`thoughts/erik/0001-auth-system/research.md`):
```yaml
---
feature_slug: "erik/0001-auth-system"
shared_as: "0042-auth-system"
shared_date: "2026-02-04"
status: shared
# ... other fields unchanged
---
```

**Shared copy** (`thoughts/shared/0042-auth-system/research.md`):
```yaml
---
feature_slug: "0042-auth-system"
original_slug: "erik/0001-auth-system"
shared_date: "2026-02-04"
status: published
# ... other fields unchanged
---
```

Update frontmatter in all markdown files within both directories (research.md, plan.md, changelog.md, etc.).

### 6. Commit and Push

Atomic operation to claim the shared number:

```bash
git add thoughts/shared/${NEXT_SHARED}-${slug} thoughts/${username}/${NNNN}-${slug}
git commit -m "feat: share ${slug} (was ${username}/${NNNN})"
git push
```

**Important**: If push fails due to conflict (someone else pushed a shared doc), retry from step 2.

### 7. Report Result

```
✅ Shared ${username}/${NNNN}-${slug} → shared/${NEXT_SHARED}-${slug}

Personal copy marked with shared_as in frontmatter.
Collaborators can now access: thoughts/shared/${NEXT_SHARED}-${slug}/
```

## Error Handling

**Personal doc doesn't exist**:
```
❌ Error: thoughts/erik/0001-auth-system not found
```

**Already shared**:
```
❌ Error: Document already shared as 0042-auth-system (check frontmatter)
Consider creating a new version if updates are needed.
```

**Git push conflict**:
```
⚠️  Push rejected - shared number conflict detected
Retrying with next available number...
```

Automatically retry from step 2 (pull, find next number, copy, commit, push).

## Example Usage

```bash
# User has: thoughts/erik/0001-auth-system/research.md
# User runs: /share-docs thoughts/erik/0001-auth-system

# Skill executes:
git pull
# Finds next shared: 0042
cp -r thoughts/erik/0001-auth-system thoughts/shared/0042-auth-system
# Updates frontmatter in both
git add thoughts/shared/0042-auth-system thoughts/erik/0001-auth-system
git commit -m "feat: share auth-system (was erik/0001)"
git push

# Result:
# ✅ Shared erik/0001-auth-system → shared/0042-auth-system
```

## Collaboration Model

**Personal namespace** (`thoughts/{username}/`):
- Each developer has their own numbering (0001, 0002, etc.)
- No conflicts between developers
- Work-in-progress, experimentation, drafts
- Not visible to others until shared

**Shared namespace** (`thoughts/shared/`):
- Canonical numbered documents for team
- Numbers assigned atomically at share time
- Published, reviewed, ready for implementation
- Visible to all collaborators

**Benefits**:
- No numbering conflicts during development
- Explicit sharing moment
- Clear distinction between WIP and published
- Git handles conflicts automatically

## After Sharing

Personal copy remains unchanged except for frontmatter. You can:
- Keep it as reference
- Continue working on improvements
- Share updates as a new document (new shared number)
- Delete it if no longer needed

The shared copy becomes the canonical version that others reference.
