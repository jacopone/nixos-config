---
status: active
created: 2025-10-08
updated: 2025-10-08
type: reference
lifecycle: persistent
description: Start spec-driven development for a major feature
---

# Spec-Driven Feature Development

Guide the user through GitHub's Spec Kit workflow for major features.

## Your Task

1. **Determine if spec-driven approach is appropriate**:

   Ask the user what they want to build, then evaluate:

   ✅ **USE Spec Kit if**:
   - New subsystem (3+ files OR 500+ lines of code)
   - Integration with external services
   - Breaking architectural changes
   - Complex multi-step feature

   ❌ **DON'T use Spec Kit if**:
   - Package additions (edit `packages.nix` directly)
   - Configuration tweaks (edit `.nix` file)
   - Documentation updates (edit existing docs)
   - Simple bug fixes

   If inappropriate, politely explain why and offer to help with direct implementation.

2. **If appropriate, run Spec Kit workflow**:

   ```bash
   # Step 1: Capture requirements
   /speckit.specify

   # Step 2: Clarify ambiguities (interactive Q&A)
   /speckit.clarify

   # Step 3: Generate technical plan
   /speckit.plan

   # Step 4: Show plan to user, wait for approval
   # (You show the plan and ask: "Does this look good?")

   # Step 5: If approved, implement
   /speckit.implement
   ```

3. **Ensure proper documentation**:
   - All generated `.md` files MUST have YAML frontmatter
   - Spec files should be `type: planning, lifecycle: ephemeral` initially
   - After implementation, promote to `type: architecture, lifecycle: persistent` if it's design doc

4. **Track progress with TodoWrite**:
   - Create todos for each major step
   - Mark completed as you go
   - User can see progress

## Example Interaction

```
User: I want to add automatic n8n workflow deployment

Claude: This qualifies for spec-driven development! It involves:
- Integration with external service (n8n)
- Multiple configuration files
- Likely 500+ lines of code

I'll use Spec Kit. Let's start by capturing requirements.

[Runs /speckit.specify]
[Runs /speckit.clarify - asks clarifying questions]
[Runs /speckit.plan - generates technical plan]

Here's the plan:
<shows detailed spec>

Does this look good? Should I proceed with implementation?

User: Yes, looks great

Claude: [Runs /speckit.implement and builds the feature]
```

## Important Reminders

- Always add YAML frontmatter to generated docs
- Use TodoWrite to track progress
- Wait for user approval before implementing
- Don't over-use Spec Kit for simple tasks
