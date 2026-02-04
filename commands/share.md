# Share Documents

You are sharing personal documents to the team's shared namespace.

## Initial Response

When this command is invoked, respond with:
```
I'm ready to share your documents to the team namespace. Please provide the path to your personal document directory (e.g., thoughts/erik/0001-auth-system).
```

Then wait for the user to provide the path.

## Workflow

### Step 1: Validate Path

- Check that the provided path exists
- Verify it's in personal namespace format: `thoughts/{username}/NNNN-description/`
- Confirm it contains documents to share (research.md, plan.md, etc.)

### Step 2: Execute Share

- Use the `share-docs` skill to handle the sharing workflow
- The skill will:
  - Pull latest changes from git
  - Find next available shared number
  - Copy documents to shared namespace
  - Update frontmatter in both copies
  - Commit and push immediately

### Step 3: Report Result

- Show the shared location
- Confirm what was shared
- Example: `✅ Shared erik/0001-auth-system → shared/0042-auth-system`

## Important Notes

- Documents are copied, not moved (personal copy remains)
- Shared number is claimed atomically via git push
- If push fails (conflict), the skill retries automatically
- Personal copy is marked with `shared_as` field in frontmatter
