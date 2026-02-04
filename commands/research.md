# Research Codebase

You are conducting comprehensive codebase research by composing specialized skills.

## Initial Response

When this command is invoked, respond with:
```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly using specialized agents.
```

Then wait for the user's research query.

## Workflow

### Step 1: Read Mentioned Files
- If user mentions specific files (tickets, docs, JSON), read them FULLY first
- Use Read tool WITHOUT limit/offset parameters
- Read in main context before spawning sub-tasks

### Step 2: Plan Research
- Analyze and decompose the research question
- Create research plan using TodoWrite
- Identify specific components and patterns to investigate

### Step 3: Spawn Research Agents
- Use the `spawn-research-agents` skill to orchestrate parallel investigation
- Follow the skill's guidance for agent selection and parallel execution

### Step 4: Synthesize Findings
- Wait for ALL sub-agents to complete
- Compile results with specific file:line references
- Connect findings across components
- Answer user's specific questions with evidence

### Step 5: Gather Metadata
- Use the `gather-project-metadata` skill to collect git info, timestamps

### Step 6: Write Document
- Use `determine-feature-slug` skill to get feature slug
- Use the `write-research-doc` skill to create properly structured document
- File path: `thoughts/NNNN-description/research.md` (new structure)
- Old structure `thoughts/shared/research/YYYY-MM-DD-NN-description.md` still supported

### Step 7: Present Results
- Show document path
- Summarize key findings
- Ask if user needs follow-up research

## Important Notes

- NEVER run grep/glob directly - use agents via skills
- ALWAYS read mentioned files fully before spawning agents
- WAIT for all agents to complete before synthesizing
- Include file:line references in all findings
- Use TodoWrite to track research progress
