#!/usr/bin/env bash

# Advanced Workflow Templates System
# Reusable patterns for common development scenarios
# Phase 3: Advanced Integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script version and metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Advanced Workflow Templates"

echo -e "${PURPLE}🎭 ${SCRIPT_NAME} v${SCRIPT_VERSION}${NC}"
echo -e "${PURPLE}====================================${NC}"
echo ""

# Configuration
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
TEMPLATE_TYPE="${1:-list}"
FEATURE_NAME="${2:-example-feature}"

# Templates directory
TEMPLATES_DIR="/home/guyfawkes/nixos-config/ai-orchestration/templates"

# Function to create templates directory structure
setup_templates_directory() {
    echo -e "${BLUE}🏗️  Setting up templates directory...${NC}"
    
    mkdir -p "$TEMPLATES_DIR"/{prds,epics,workflows,contexts}
    
    echo -e "${GREEN}✅ Templates directory structure created${NC}"
}

# Function to create PRD templates
create_prd_templates() {
    echo -e "${BLUE}📋 Creating PRD templates...${NC}"
    
    # Basic Feature PRD Template
    cat > "$TEMPLATES_DIR/prds/basic-feature-prd.md" << 'EOF'
# Product Requirements Document: {FEATURE_NAME}

**Date**: {DATE}  
**Product Manager**: {PM_NAME}  
**Project**: {PROJECT_NAME}  
**Status**: Draft  

## Overview

### Problem Statement
[Describe the problem this feature solves]

### Solution Summary
[Brief description of the proposed solution]

### Success Metrics
- **Primary Metric**: [e.g., User engagement increase by 20%]
- **Secondary Metrics**: [e.g., Reduced support tickets, improved conversion]

## User Stories

### Primary User Stories
1. **As a** [user type], **I want** [functionality], **so that** [benefit]
2. **As a** [user type], **I want** [functionality], **so that** [benefit]
3. **As a** [user type], **I want** [functionality], **so that** [benefit]

### Edge Cases
- [Edge case 1]
- [Edge case 2]

## Requirements

### Functional Requirements
1. **Requirement 1**: [Detailed description]
2. **Requirement 2**: [Detailed description]
3. **Requirement 3**: [Detailed description]

### Non-Functional Requirements
- **Performance**: [e.g., Page load time < 2s]
- **Security**: [e.g., Data encryption, authentication]
- **Scalability**: [e.g., Support 10k concurrent users]
- **Accessibility**: [e.g., WCAG 2.1 AA compliance]

## User Experience

### User Flow
```
[User Flow Description or Diagram]
1. User action 1
2. System response 1
3. User action 2
4. System response 2
```

### Wireframes
[Link to wireframes or describe key screens]

## Technical Considerations

### Dependencies
- [Existing system/feature dependencies]
- [External service dependencies]

### Constraints
- [Technical constraints]
- [Business constraints]
- [Timeline constraints]

## Acceptance Criteria

### Definition of Done
- [ ] Feature functions as specified
- [ ] All user stories addressed
- [ ] Performance requirements met
- [ ] Security requirements satisfied
- [ ] Accessibility standards met
- [ ] Documentation complete
- [ ] Tests pass with >80% coverage

### Test Scenarios
1. **Happy Path**: [Main user workflow]
2. **Error Handling**: [Error scenarios and responses]
3. **Edge Cases**: [Boundary conditions]

## Launch Plan

### Rollout Strategy
- **Phase 1**: [Initial rollout scope]
- **Phase 2**: [Full rollout]

### Success Measurement
- [How success will be measured]
- [Timeline for measurement]

## Risk Assessment

### Technical Risks
- [Risk 1]: [Impact and mitigation]
- [Risk 2]: [Impact and mitigation]

### Business Risks
- [Risk 1]: [Impact and mitigation]
- [Risk 2]: [Impact and mitigation]

---
*PRD Template v{TEMPLATE_VERSION}*
EOF
    
    # API Feature PRD Template
    cat > "$TEMPLATES_DIR/prds/api-feature-prd.md" << 'EOF'
# API Feature PRD: {FEATURE_NAME}

**Date**: {DATE}  
**Project**: {PROJECT_NAME}  
**API Version**: v1  
**Status**: Draft  

## API Overview

### Purpose
[What this API enables and why it's needed]

### Target Consumers
- [Internal services/applications]
- [External partners/developers]
- [Third-party integrations]

## API Specification

### Endpoints

#### GET /api/{FEATURE_NAME}
**Purpose**: [Endpoint description]
**Authentication**: [Required/Optional]
**Parameters**:
- `param1` (string, required): [Description]
- `param2` (integer, optional): [Description]

**Response**:
```json
{
  "status": "success",
  "data": {
    // Response structure
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

#### POST /api/{FEATURE_NAME}
**Purpose**: [Endpoint description]
**Authentication**: Required
**Request Body**:
```json
{
  "field1": "string",
  "field2": 123,
  "field3": {
    // Nested object
  }
}
```

**Response**:
```json
{
  "status": "success",
  "data": {
    "id": "generated-id",
    // Created resource
  }
}
```

### Error Handling
```json
{
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "field1": ["Field is required"]
    }
  }
}
```

## Technical Requirements

### Performance
- Response time: < 200ms for 95th percentile
- Throughput: 1000 requests/second
- Availability: 99.9% uptime

### Security
- Authentication: OAuth 2.0 / API Keys
- Authorization: Role-based access control
- Data validation: Input sanitization
- Rate limiting: 100 requests/minute per user

### Data Storage
- Database: [PostgreSQL/MongoDB/etc.]
- Caching: [Redis/Memcached]
- File storage: [S3/local filesystem]

## Documentation Requirements

- [ ] OpenAPI/Swagger specification
- [ ] SDK/client libraries
- [ ] Integration guides
- [ ] Code examples
- [ ] Postman collection

---
*API PRD Template v{TEMPLATE_VERSION}*
EOF
    
    echo -e "${GREEN}✅ PRD templates created${NC}"
}

# Function to create epic templates
create_epic_templates() {
    echo -e "${BLUE}📋 Creating epic templates...${NC}"
    
    # Full-Stack Feature Epic
    cat > "$TEMPLATES_DIR/epics/fullstack-feature-epic.md" << 'EOF'
# Technical Epic: {FEATURE_NAME}

**Generated from PRD**: {FEATURE_NAME}.md  
**Date**: {DATE}  
**Project**: {PROJECT_NAME}  
**Epic Type**: Full-Stack Feature  
**Status**: Planning  

## Epic Overview

### Feature Summary
[Brief technical description of what will be built]

### Architecture Overview
```
Frontend (React/Vue) ↔ API Gateway ↔ Backend Services ↔ Database
                      ↓
              Authentication/Authorization
                      ↓
                External Services/APIs
```

## Implementation Phases

### Phase 1: Backend Foundation
**Duration**: [Estimate]  
**Agent**: Cursor  

#### Database Design
- [ ] **Schema Design**: Create tables/collections for {FEATURE_NAME} data
- [ ] **Migrations**: Database migration scripts
- [ ] **Indexes**: Performance optimization indexes
- [ ] **Constraints**: Data integrity constraints

#### API Development
- [ ] **Core Endpoints**: CRUD operations for {FEATURE_NAME}
- [ ] **Authentication**: Integrate with auth system
- [ ] **Validation**: Input validation and sanitization
- [ ] **Error Handling**: Comprehensive error responses

#### Testing
- [ ] **Unit Tests**: Individual function testing
- [ ] **Integration Tests**: API endpoint testing
- [ ] **Performance Tests**: Load and stress testing

### Phase 2: Frontend Implementation
**Duration**: [Estimate]  
**Agent**: v0.dev  

#### UI Components
- [ ] **Core Components**: {FEATURE_NAME} display and interaction components
- [ ] **Form Components**: Create/edit forms with validation
- [ ] **List Components**: Data display and filtering
- [ ] **Modal Components**: Dialog and overlay interactions

#### State Management
- [ ] **State Structure**: Define {FEATURE_NAME} state schema
- [ ] **Actions/Mutations**: State update operations
- [ ] **API Integration**: Connect to backend services
- [ ] **Caching Strategy**: Optimize data fetching

#### User Experience
- [ ] **Responsive Design**: Mobile and desktop optimization
- [ ] **Loading States**: Progress indicators and skeletons
- [ ] **Error States**: User-friendly error handling
- [ ] **Accessibility**: WCAG compliance

### Phase 3: Integration & Enhancement
**Duration**: [Estimate]  
**Agent**: Claude Code  

#### API Integration
- [ ] **End-to-End Flow**: Complete user workflows
- [ ] **Error Handling**: Graceful error recovery
- [ ] **Performance Optimization**: Caching and optimization
- [ ] **Security Testing**: Validate security measures

#### Advanced Features
- [ ] **Search/Filtering**: Advanced data querying
- [ ] **Pagination**: Efficient data loading
- [ ] **Bulk Operations**: Multi-item operations
- [ ] **Real-time Updates**: WebSocket/SSE integration

### Phase 4: Testing & Quality Assurance
**Duration**: [Estimate]  
**Agent**: Gemini Pro  

#### Comprehensive Testing
- [ ] **Unit Test Coverage**: >80% code coverage
- [ ] **Integration Testing**: API and UI integration
- [ ] **E2E Testing**: Complete user workflows
- [ ] **Performance Testing**: Load testing and optimization

#### Quality Validation
- [ ] **Code Review**: Standards compliance
- [ ] **Security Audit**: Vulnerability assessment
- [ ] **Accessibility Testing**: WCAG compliance validation
- [ ] **Browser Testing**: Cross-browser compatibility

## Technical Specifications

### Backend Architecture
```
{FEATURE_NAME} API
├── Controllers/     # HTTP request handling
├── Services/       # Business logic
├── Models/         # Data models
├── Middleware/     # Authentication, validation
└── Tests/          # Unit and integration tests
```

### Frontend Architecture
```
{FEATURE_NAME} Module
├── components/     # UI components
├── containers/     # Connected components
├── services/       # API integration
├── store/         # State management
└── __tests__/     # Component tests
```

### Database Schema
```sql
-- Example schema structure
CREATE TABLE {FEATURE_NAME} (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- Add indexes for performance
CREATE INDEX idx_{FEATURE_NAME}_status ON {FEATURE_NAME}(status);
CREATE INDEX idx_{FEATURE_NAME}_created_at ON {FEATURE_NAME}(created_at);
```

## API Endpoints

### Core CRUD Operations
```
GET    /api/{FEATURE_NAME}           # List with pagination/filtering
POST   /api/{FEATURE_NAME}           # Create new item
GET    /api/{FEATURE_NAME}/:id       # Get specific item
PUT    /api/{FEATURE_NAME}/:id       # Update item
DELETE /api/{FEATURE_NAME}/:id       # Delete item
PATCH  /api/{FEATURE_NAME}/:id       # Partial update
```

### Advanced Operations
```
GET    /api/{FEATURE_NAME}/search    # Advanced search
POST   /api/{FEATURE_NAME}/bulk      # Bulk operations
GET    /api/{FEATURE_NAME}/export    # Data export
POST   /api/{FEATURE_NAME}/import    # Data import
```

## GitHub Issues Mapping

### Backend Issues
1. **Database Schema & Models** (`backend`, `epic:{FEATURE_NAME}`)
2. **Core API Endpoints** (`backend`, `epic:{FEATURE_NAME}`)
3. **Authentication Integration** (`backend`, `epic:{FEATURE_NAME}`)
4. **API Testing & Documentation** (`backend`, `testing`, `epic:{FEATURE_NAME}`)

### Frontend Issues
5. **Core UI Components** (`frontend`, `epic:{FEATURE_NAME}`)
6. **State Management Setup** (`frontend`, `epic:{FEATURE_NAME}`)
7. **API Integration** (`frontend`, `integration`, `epic:{FEATURE_NAME}`)
8. **Responsive Design & UX** (`frontend`, `epic:{FEATURE_NAME}`)

### Integration Issues
9. **End-to-End Integration** (`integration`, `epic:{FEATURE_NAME}`)
10. **Performance Optimization** (`integration`, `epic:{FEATURE_NAME}`)
11. **Security & Error Handling** (`integration`, `epic:{FEATURE_NAME}`)

### QA Issues
12. **Comprehensive Testing Suite** (`testing`, `epic:{FEATURE_NAME}`)
13. **Performance & Security Testing** (`testing`, `epic:{FEATURE_NAME}`)
14. **Documentation & Deployment** (`documentation`, `devops`, `epic:{FEATURE_NAME}`)

## Success Criteria

### Technical Acceptance
- [ ] All API endpoints function correctly
- [ ] Frontend components render and interact properly
- [ ] Database operations perform efficiently
- [ ] Security measures implemented and tested
- [ ] Performance benchmarks met
- [ ] Test coverage >80%

### User Acceptance
- [ ] User workflows complete successfully
- [ ] Error scenarios handled gracefully
- [ ] Performance meets user expectations
- [ ] Accessibility requirements satisfied
- [ ] Cross-browser compatibility confirmed

## Deployment Strategy

### Environment Progression
1. **Development**: Feature branch development
2. **Staging**: Integration testing environment
3. **Production**: Gradual rollout with monitoring

### Rollback Plan
- Database migration rollback procedures
- Frontend asset versioning
- API versioning strategy
- Monitoring and alerting setup

---
*Epic Template v{TEMPLATE_VERSION} - Full-Stack Feature*
EOF

    echo -e "${GREEN}✅ Epic templates created${NC}"
}

# Function to create workflow templates
create_workflow_templates() {
    echo -e "${BLUE}🔄 Creating workflow templates...${NC}"
    
    # Quick Feature Workflow
    cat > "$TEMPLATES_DIR/workflows/quick-feature-workflow.md" << 'EOF'
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
EOF
    
    # Complex System Workflow
    cat > "$TEMPLATES_DIR/workflows/complex-system-workflow.md" << 'EOF'
# Complex System Workflow: {FEATURE_NAME}

**Estimated Duration**: 1-4 weeks  
**Complexity**: High  
**Team Size**: 3-4 agents + human oversight  

## Workflow Overview

This template handles complex system features requiring extensive planning, coordination, and multiple integration points.

### Prerequisites
- [ ] Comprehensive requirements analysis
- [ ] Architecture design review
- [ ] Resource allocation confirmed
- [ ] CCPM structure with full context management

### Phase 1: Strategic Planning (2-3 days)
**Lead**: Claude Code with stakeholder input

#### Requirements Analysis
- [ ] Detailed PRD creation
- [ ] Stakeholder interviews
- [ ] Technical feasibility study
- [ ] Risk assessment

#### Architecture Design
- [ ] System architecture diagrams
- [ ] Database design
- [ ] API contract specifications
- [ ] Security requirements

#### Project Setup
- [ ] Epic decomposition (5-15 GitHub Issues)
- [ ] Agent role assignments
- [ ] Context structure setup
- [ ] Communication protocols

### Phase 2: Foundation Development (1-2 weeks)
**Parallel execution with coordination checkpoints**

#### Backend Infrastructure (Cursor)
- [ ] Database schema and migrations
- [ ] Core API framework
- [ ] Authentication/authorization
- [ ] Logging and monitoring setup
- [ ] Unit testing framework

#### Frontend Architecture (v0.dev)
- [ ] Component library foundation
- [ ] State management setup
- [ ] Routing and navigation
- [ ] Design system implementation
- [ ] Testing framework setup

#### Integration Planning (Claude Code)
- [ ] API integration specifications
- [ ] Data flow documentation
- [ ] Error handling strategies
- [ ] Performance requirements

### Phase 3: Feature Implementation (1-2 weeks)
**Coordinated parallel development**

#### Backend Services (Cursor)
- [ ] Business logic implementation
- [ ] Advanced API endpoints
- [ ] Data processing services
- [ ] Background job processing
- [ ] Performance optimization

#### Frontend Features (v0.dev)
- [ ] Complex UI components
- [ ] Advanced user interactions
- [ ] Real-time features
- [ ] Performance optimization
- [ ] Accessibility implementation

#### Continuous Integration (Claude Code)
- [ ] API integration testing
- [ ] Cross-component coordination
- [ ] Progress synchronization
- [ ] Issue resolution

### Phase 4: System Integration (3-5 days)
**Full system coordination**

#### Integration Testing (Gemini Pro)
- [ ] End-to-end workflow testing
- [ ] Performance testing under load
- [ ] Security penetration testing
- [ ] Cross-browser compatibility

#### System Optimization (Claude Code)
- [ ] Performance profiling
- [ ] Security hardening
- [ ] Documentation completion
- [ ] Deployment preparation

### Phase 5: Deployment & Monitoring (1-2 days)
**Production readiness**

#### Deployment (Claude Code)
- [ ] Staging environment testing
- [ ] Production deployment
- [ ] Monitoring setup
- [ ] Rollback procedures

#### Validation (Gemini Pro)
- [ ] Production testing
- [ ] Performance monitoring
- [ ] Error tracking
- [ ] User feedback integration

## Coordination Protocols

### Daily Sync (15 minutes)
- Progress updates from each agent
- Blocking issues identification
- Next 24-hour planning

### Weekly Review (1 hour)
- Architecture decisions review
- Integration testing results
- Timeline and scope adjustments

### Milestone Gates
1. **Architecture Approval**: Before Phase 2
2. **Foundation Review**: Before Phase 3
3. **Integration Checkpoint**: Before Phase 4
4. **Production Readiness**: Before Phase 5

## Risk Management

### Technical Risks
- **Integration Complexity**: Daily coordination calls
- **Performance Issues**: Early performance testing
- **Security Vulnerabilities**: Security review at each phase

### Process Risks
- **Scope Creep**: Weekly scope reviews
- **Communication Gaps**: Structured context updates
- **Timeline Pressure**: Milestone-based planning

---
*Complex System Workflow Template v{TEMPLATE_VERSION}*
EOF

    echo -e "${GREEN}✅ Workflow templates created${NC}"
}

# Function to list available templates
list_templates() {
    echo -e "${BLUE}📋 Available Workflow Templates${NC}"
    echo ""
    
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        echo -e "${YELLOW}⚠️  Templates directory not found. Run 'init' to create templates.${NC}"
        return 1
    fi
    
    echo -e "${PURPLE}🎭 Template Categories:${NC}"
    echo ""
    
    # PRD Templates
    if [[ -d "$TEMPLATES_DIR/prds" ]]; then
        echo -e "${CYAN}📋 PRD Templates:${NC}"
        find "$TEMPLATES_DIR/prds" -name "*.md" | while read -r template; do
            local name=$(basename "$template" .md)
            echo -e "${GREEN}   • $name${NC}"
        done
        echo ""
    fi
    
    # Epic Templates
    if [[ -d "$TEMPLATES_DIR/epics" ]]; then
        echo -e "${CYAN}📊 Epic Templates:${NC}"
        find "$TEMPLATES_DIR/epics" -name "*.md" | while read -r template; do
            local name=$(basename "$template" .md)
            echo -e "${GREEN}   • $name${NC}"
        done
        echo ""
    fi
    
    # Workflow Templates
    if [[ -d "$TEMPLATES_DIR/workflows" ]]; then
        echo -e "${CYAN}🔄 Workflow Templates:${NC}"
        find "$TEMPLATES_DIR/workflows" -name "*.md" | while read -r template; do
            local name=$(basename "$template" .md)
            echo -e "${GREEN}   • $name${NC}"
        done
        echo ""
    fi
    
    echo -e "${BLUE}💡 Usage Examples:${NC}"
    echo -e "${CYAN}   Create from template: $0 create basic-feature-prd my-feature${NC}"
    echo -e "${CYAN}   Apply workflow: $0 apply quick-feature-workflow my-feature${NC}"
    echo ""
}

# Function to create instance from template
create_from_template() {
    local template_name="$1"
    local instance_name="$2"
    
    if [[ -z "$template_name" ]] || [[ -z "$instance_name" ]]; then
        echo -e "${RED}❌ Usage: $0 create <template-name> <instance-name>${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🎭 Creating from template: $template_name → $instance_name${NC}"
    
    # Find template file
    local template_file=""
    for dir in prds epics workflows contexts; do
        local potential_file="$TEMPLATES_DIR/$dir/$template_name.md"
        if [[ -f "$potential_file" ]]; then
            template_file="$potential_file"
            break
        fi
    done
    
    if [[ -z "$template_file" ]]; then
        echo -e "${RED}❌ Template not found: $template_name${NC}"
        return 1
    fi
    
    # Determine output directory
    local output_dir
    if [[ "$template_file" == *"/prds/"* ]]; then
        output_dir="$PROJECT_DIR/.claude/prds"
    elif [[ "$template_file" == *"/epics/"* ]]; then
        output_dir="$PROJECT_DIR/.claude/epics"
    elif [[ "$template_file" == *"/workflows/"* ]]; then
        output_dir="$PROJECT_DIR/.claude/workflows"
    else
        output_dir="$PROJECT_DIR/.claude/contexts"
    fi
    
    mkdir -p "$output_dir"
    
    # Create instance file
    local output_file="$output_dir/${instance_name}.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Process template with variable substitution
    sed -e "s/{FEATURE_NAME}/$instance_name/g" \
        -e "s/{DATE}/$timestamp/g" \
        -e "s/{PROJECT_NAME}/$PROJECT_NAME/g" \
        -e "s/{TEMPLATE_VERSION}/$SCRIPT_VERSION/g" \
        "$template_file" > "$output_file"
    
    echo -e "${GREEN}✅ Created: $output_file${NC}"
    echo -e "${CYAN}📝 Next steps: Edit the file and customize for your specific needs${NC}"
}

# Main execution
main() {
    case "$TEMPLATE_TYPE" in
        "init")
            echo -e "${BLUE}🚀 Initializing workflow templates system...${NC}"
            setup_templates_directory
            create_prd_templates
            create_epic_templates
            create_workflow_templates
            echo -e "${PURPLE}✅ Workflow templates system initialized${NC}"
            ;;
        "list")
            list_templates
            ;;
        "create")
            create_from_template "$2" "$3"
            ;;
        "show")
            if [[ -z "$2" ]]; then
                echo -e "${RED}❌ Usage: $0 show <template-name>${NC}"
                exit 1
            fi
            
            # Find and display template
            local template_file=""
            for dir in prds epics workflows contexts; do
                local potential_file="$TEMPLATES_DIR/$dir/$2.md"
                if [[ -f "$potential_file" ]]; then
                    template_file="$potential_file"
                    break
                fi
            done
            
            if [[ -n "$template_file" ]]; then
                echo -e "${BLUE}📄 Template: $2${NC}"
                echo ""
                cat "$template_file"
            else
                echo -e "${RED}❌ Template not found: $2${NC}"
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid action: $TEMPLATE_TYPE${NC}"
            echo -e "${YELLOW}Usage: $0 [init|list|create|show] [template-name] [instance-name]${NC}"
            echo ""
            echo -e "${CYAN}Actions:${NC}"
            echo -e "${CYAN}  init                    - Initialize templates system${NC}"
            echo -e "${CYAN}  list                    - List available templates${NC}"
            echo -e "${CYAN}  create <template> <name> - Create instance from template${NC}"
            echo -e "${CYAN}  show <template>         - Display template content${NC}"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"