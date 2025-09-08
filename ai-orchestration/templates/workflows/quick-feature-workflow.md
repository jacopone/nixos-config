# Quick Feature Workflow: {FEATURE_NAME}

**Estimated Duration**: 1-3 days  
**Complexity**: Low to Medium  
**Team Size**: 1-2 agents  

## Workflow Overview

This template is optimized for small to medium features that can be completed quickly with minimal coordination overhead.

### Prerequisites
- [ ] Clear feature requirements defined
- [ ] Technical approach agreed upon
- [ ] CCPM structure initialized in project

### Execution Steps

#### Step 1: Rapid Planning (30 minutes)
**Agent**: Claude Code
- Create simple PRD using basic template
- Define technical approach
- Set up GitHub Issues (3-5 issues max)
- Initialize agent contexts

#### Step 2: Parallel Implementation (1-2 days)
**Agents**: Cursor + v0.dev (parallel execution)

##### Backend Track (Cursor)
- [ ] Database schema (if needed)
- [ ] API endpoints
- [ ] Basic testing
- [ ] Documentation

##### Frontend Track (v0.dev)
- [ ] UI components
- [ ] State management
- [ ] API integration
- [ ] Basic testing

#### Step 3: Integration & Polish (0.5 days)
**Agent**: Claude Code
- [ ] End-to-end testing
- [ ] Bug fixes and refinement
- [ ] Documentation updates
- [ ] Deployment preparation

#### Step 4: Quality Validation (0.5 days)
**Agent**: Gemini Pro
- [ ] Feature testing
- [ ] Performance validation
- [ ] Security check
- [ ] Final approval

## Template Commands

### Setup
```bash
# Initialize quick feature
cd your-project
~/nixos-config/ai-orchestration/scripts/workflow-templates.sh quick-setup {FEATURE_NAME}
```

### Execution
```bash
# Run hybrid orchestration with quick workflow
~/nixos-config/ai-orchestration/scripts/ccpm-enhanced-universal.sh

# Select: "Quick Feature Workflow" (if available)
# Or use standard CCPM + GitHub Issues workflow
```

## Success Metrics

- [ ] Feature completed within estimated timeframe
- [ ] All acceptance criteria met
- [ ] Minimal context switching overhead
- [ ] Clean integration with existing codebase

---
*Quick Feature Workflow Template v{TEMPLATE_VERSION}*
