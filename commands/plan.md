# Implementation Plan

You are creating a detailed implementation plan through an interactive process.

## Initial Response

Check if parameters were provided:
- If file path or ticket provided: Read files FULLY and begin research
- If no parameters: Show usage message and wait

Usage message:
```
I'll help you create a detailed implementation plan. Please provide:
1. The task/ticket description (or path to ticket file)
2. Any relevant context or requirements
3. Links to related research

Tip: You can invoke with a file: `/plan thoughts/tickets/eng_1234.md`
```

## Workflow

### Step 1: Read Context
- Read ticket and any mentioned files FULLY (no limit/offset)
- Read in main context before spawning agents

### Step 2: Discover Project Context (if needed)
- Check if `thoughts/notes/commands.md` exists
  - If not: Use `discover-project-commands` skill to create it
- Check if `thoughts/notes/testing.md` exists
  - If not: Use `discover-test-patterns` skill to create it
- These reference docs improve plan quality and success criteria

### Step 3: Initial Research
- Use `spawn-planning-agents` skill to gather context
- Spawn parallel agents to find existing code, patterns, documentation
- Wait for all agents to complete

### Step 4: Read Agent Findings
- Read all files identified by research agents FULLY
- Verify understanding against actual code

### Step 5: Ask Clarifying Questions
- Present informed understanding
- Ask only questions that code can't answer
- Use AskUserQuestion tool for technical choices

### Step 6: Deeper Research (if needed)
- If user corrects misunderstanding, spawn new research
- Verify facts before proceeding

### Step 7: Collaborate on Approach
- Present design options with pros/cons
- Get user buy-in on structure
- Agree on phases before writing

### Step 8: Gather Metadata
- Use `gather-project-metadata` skill

### Step 9: Write Plan
- Use `write-plan-doc` skill to create structured plan
- File path: `thoughts/shared/plans/YYYY-MM-DD-NN-description.md`
- Reference templates for structure

### Step 10: Review and Iterate
- Present plan location
- Ask for feedback on phases, success criteria, technical details
- Iterate until user is satisfied

## Important Notes

- Be skeptical - question vague requirements
- Be interactive - don't write full plan in one shot
- Be thorough - read all context fully, spawn parallel research
- Be practical - focus on incremental, testable changes
- NO open questions in final plan - resolve everything first
- Use TodoWrite to track planning progress
- Always separate automated vs manual success criteria
