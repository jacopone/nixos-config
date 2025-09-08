# Agents

Specialized agents that do heavy work and return concise summaries to preserve context.

## Core Philosophy

> “Don't anthropomorphize subagents. Use them to organize your prompts and elide context. Subagents are best when they can do lots of work but then provide small amounts of information back to the main conversation thread.”
>
> – Adam Wolff, Anthropic

## Available Agents

### 🔍 `code-analyzer`
- **Purpose**: Hunt bugs across multiple files without polluting main context
- **Pattern**: Search many files → Analyze code → Return bug report
- **Usage**: When you need to trace logic flows, find bugs, or validate changes
- **Returns**: Concise bug report with critical findings only

### 📄 `file-analyzer`
- **Purpose**: Read and summarize verbose files (logs, outputs, configs)
- **Pattern**: Read files → Extract insights → Return summary
- **Usage**: When you need to understand log files or analyze verbose output
- **Returns**: Key findings and actionable insights (80-90% size reduction)

### 🧪 `test-runner`
- **Purpose**: Execute tests without dumping output to main thread
- **Pattern**: Run tests → Capture to log → Analyze results → Return summary
- **Usage**: When you need to run tests and understand failures
- **Returns**: Test results summary with failure analysis

### 🔀 `parallel-worker`
- **Purpose**: Coordinate multiple parallel work streams for an issue
- **Pattern**: Read analysis → Spawn sub-agents → Consolidate results → Return summary
- **Usage**: When executing parallel work streams in a worktree
- **Returns**: Consolidated status of all parallel work

## 🌟 Premium Platform-Optimized Agents (Google One Ultra)

### 🧠 `strategic-coordinator`
- **Platform**: Gemini Deep Think + Canvas
- **Purpose**: Complex reasoning, architectural decisions, problem-solving
- **Pattern**: Analyze requirements → Deep architectural analysis → Visual planning → Strategic decisions
- **Usage**: When you need complex system design, trade-off analysis, or epic decomposition
- **Returns**: Concise architectural recommendations with visual diagrams
- **Optimal For**: Epic planning, technical trade-offs, system integration challenges

### 🔬 `research-specialist`
- **Platform**: Gemini Deep Research
- **Purpose**: Information gathering, technology evaluation, competitive analysis
- **Pattern**: Research query → Comprehensive analysis → Best practices identification → Summary
- **Usage**: When you need technology stack evaluation, security research, or performance optimization strategies
- **Returns**: Research findings with actionable recommendations
- **Optimal For**: Technology selection, vulnerability analysis, industry best practices

### ⚙️ `backend-specialist`
- **Platform**: Cursor with Claude 3.5 Sonnet + Agents
- **Purpose**: Backend API development, database design, server-side logic
- **Pattern**: Requirements → Multi-agent implementation → Testing → Integration
- **Usage**: When building APIs, database schemas, or complex backend functionality
- **Returns**: Implementation status with performance metrics
- **Configuration**: 
  ```json
  {
    "model": "claude-3-5-sonnet-20241022",
    "use_agents": true,
    "agent_mode": "backend_specialist",
    "auto_mode": false
  }
  ```

### 🎨 `frontend-specialist`
- **Platform**: Lovable + Supabase (Primary) / Cursor with GPT-4o (Advanced)
- **Purpose**: UI/UX development, component creation, user experience optimization
- **Pattern**: Design requirements → Rapid prototyping → Advanced customization → Integration
- **Usage**: When building user interfaces, implementing design systems, or creating interactive features
- **Returns**: Component delivery with UX metrics
- **Workflow**: Start with Lovable+Supabase → Export to Cursor for complex logic

### 🛡️ `quality-assurance`
- **Platform**: Gemini Deep Think + Deep Research + Jules
- **Purpose**: Testing strategy, code review, security analysis, edge case identification
- **Pattern**: Code analysis → Security scan → Performance testing → Quality report
- **Usage**: When you need comprehensive testing, security validation, or code quality assessment
- **Returns**: Quality assessment with priority issues and recommendations
- **Tools**: Jules for continuous code review, Deep Think for edge case analysis

### 📚 `knowledge-manager`
- **Platform**: NotebookLM (Ultra/Pro/Free)
- **Purpose**: Project documentation synthesis, research compilation, knowledge base creation
- **Pattern**: Document ingestion → Content synthesis → Audio briefings → Knowledge extraction
- **Usage**: When you need to synthesize multiple project documents, create comprehensive overviews, or generate team briefings
- **Returns**: Synthesized project knowledge, audio summaries, comprehensive documentation
- **Capacity by Tier**:
  - **Ultra**: ~100 notebooks, 50+ sources per notebook
  - **Pro**: ~20 notebooks, 20+ sources per notebook  
  - **Free**: ~10 notebooks, 10 sources per notebook

## Why Agents?

Agents are **context firewalls** that protect the main conversation from information overload:

```
Without Agent:
Main thread reads 10 files → Context explodes → Loses coherence

With Agent:
Agent reads 10 files → Main thread gets 1 summary → Context preserved
```

## How Agents Preserve Context

1. **Heavy Lifting** - Agents do the messy work (reading files, running tests, implementing features)
2. **Context Isolation** - Implementation details stay in the agent, not the main thread
3. **Concise Returns** - Only essential information returns to main conversation
4. **Parallel Execution** - Multiple agents can work simultaneously without context collision

## Example Usage

```bash
# Analyzing code for bugs
Task: "Search for memory leaks in the codebase"
Agent: code-analyzer
Returns: "Found 3 potential leaks: [concise list]"
Main thread never sees: The hundreds of files examined

# Running tests
Task: "Run authentication tests"
Agent: test-runner
Returns: "2/10 tests failed: [failure summary]"
Main thread never sees: Verbose test output and logs

# Parallel implementation
Task: "Implement issue #1234 with parallel streams"
Agent: parallel-worker
Returns: "Completed 4/4 streams, 15 files modified"
Main thread never sees: Individual implementation details

# Premium Platform Examples
# Strategic planning
Task: "Design microservice architecture for e-commerce system"
Agent: strategic-coordinator (Gemini Deep Think + Canvas)
Returns: "Architecture design with 4 services, visual diagrams, performance projections"
Main thread never sees: Detailed architectural analysis and exploration

# Research and evaluation
Task: "Evaluate authentication providers for SaaS app"
Agent: research-specialist (Gemini Deep Research)
Returns: "Auth0 recommended: security, pricing, integration comparison"
Main thread never sees: Comprehensive vendor analysis and documentation review

# Backend development
Task: "Implement user authentication API with JWT"
Agent: backend-specialist (Cursor + Claude 3.5 Sonnet)
Returns: "API implemented: 6 endpoints, tests passing, security validated"
Main thread never sees: Code implementation details and debugging

# Knowledge management and synthesis
Task: "Create comprehensive project documentation and team briefing"
Agent: knowledge-manager (NotebookLM Ultra)
Returns: "Project knowledge base created: 15 sources synthesized, audio briefing generated, documentation complete"
Main thread never sees: Individual document analysis and synthesis process
```

## Creating New Agents

New agents should follow these principles:

1. **Single Purpose** - Each agent has one clear job
2. **Context Reduction** - Return 10-20% of what you process
3. **No Roleplay** - Agents aren't "experts", they're task executors
4. **Clear Pattern** - Define input → processing → output pattern
5. **Error Handling** - Gracefully handle failures and report clearly

## Anti-Patterns to Avoid

❌ **Creating "specialist" agents** (database-expert, api-expert)
   Agents don't have different knowledge - they're all the same model

❌ **Returning verbose output**
   Defeats the purpose of context preservation

❌ **Making agents communicate with each other**
   Use a coordinator agent instead (like parallel-worker)

❌ **Using agents for simple tasks**
   Only use agents when context reduction is valuable

## Integration with PM System

Agents integrate seamlessly with the PM command system:

- `/pm:issue-analyze` → Identifies work streams
- `/pm:issue-start` → Spawns parallel-worker agent
- parallel-worker → Spawns multiple sub-agents
- Sub-agents → Work in parallel in the worktree
- Results → Consolidated back to main thread

This creates a hierarchy that maximizes parallelism while preserving context at every level.
