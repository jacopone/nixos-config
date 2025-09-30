# CLAUDE.md

> AI Orchestration System - CCPM Integration Project

## Tech Stack
- **Language**: Shell Scripts (Bash)
- **AI Platforms**: Claude Code, Gemini CLI, Plandex, Cursor Pro
- **Project Management**: CCPM (Claude Code Project Management)
- **Platform Optimization**: Google One Ultra, Lovable + Supabase
- **Version Control**: Git with worktree-based epic management

## Project Structure
- `.claude/commands/` - Custom slash commands for CCPM workflows
- `.claude/agents/` - Specialized sub-agents (file-analyzer, code-analyzer, test-runner)
- `.claude/rules/` - Behavioral rules and operational constraints
- `scripts/` - Core orchestration and automation scripts
- `docs/` - Comprehensive system documentation
- `templates/` - PRD, Epic, and workflow templates

## Essential Commands
- `pm init` - Initialize new CCPM project
- `pm status` - Show current project status
- `pm epic-start <name>` - Begin new epic with worktree
- `pm issue-start <id>` - Start working on specific issue
- `pm standup` - Generate daily standup report
- `pm sync` - Synchronize with external platforms

## USE SUB-AGENTS FOR CONTEXT OPTIMIZATION

### Always Use These Agents
1. **file-analyzer** - For reading/summarizing any files (logs, configs, outputs)
2. **code-analyzer** - For code analysis, bug research, logic tracing
3. **test-runner** - For executing tests and analyzing results

### Benefits
- Dramatically reduced context usage
- Cleaner main conversation
- Specialized expertise for each task type
- No approval dialogs interrupting workflow

## Development Philosophy

### Error Handling
- **Fail fast** for critical configuration issues
- **Log and continue** for optional features
- **Graceful degradation** when external services unavailable
- **User-friendly messages** through resilience layer

### Testing Strategy
- Always use test-runner agent for test execution
- No mock services - use real integrations
- Verbose tests for debugging capability
- Complete current test before moving to next
- Validate test structure before refactoring code

## ABSOLUTE RULES

### Code Quality
- **NO PARTIAL IMPLEMENTATION** - Complete all features fully
- **NO SIMPLIFICATION** - No "simplified for now" comments
- **NO CODE DUPLICATION** - Read existing code, reuse functions
- **NO DEAD CODE** - Either use it or delete it completely
- **NO INCONSISTENT NAMING** - Follow existing patterns

### Testing Requirements
- **IMPLEMENT TESTS FOR EVERY FUNCTION**
- **NO CHEATER TESTS** - Tests must reveal real flaws
- **VERBOSE TEST OUTPUT** - Design for debugging capability
- **ACCURATE TESTS** - Reflect real usage scenarios

### Architecture Principles
- **NO OVER-ENGINEERING** - Simple functions over enterprise patterns
- **NO MIXED CONCERNS** - Proper separation of responsibilities
- **NO RESOURCE LEAKS** - Close connections, clear timeouts, cleanup

## Tone and Behavior
- **Be critical and skeptical** - Point out mistakes and better approaches
- **Be concise** - Short summaries unless working through details
- **Ask questions** - Don't guess intent, ask for clarification
- **No flattery** - Skip compliments unless specifically asked
- **Welcome standards** - Point out relevant conventions I might miss

## Workflow Guidelines
- Think carefully and implement most concise solution
- Change as little code as possible
- Read existing codebase before writing new functions
- Use common sense function names for easy discovery
- Check if tests are structured correctly before refactoring

## Integration Points
- **CCPM Commands**: Available via slash commands (/)
- **Git Worktrees**: Epic-based branch management
- **External Platforms**: Automated sync with project management tools
- **AI Coordination**: Multi-agent workflows with intelligent handoffs

---
*Optimized for CCPM development workflows*