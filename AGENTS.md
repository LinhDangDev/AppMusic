# 🤖 AGENTS.md - AppMusic Multi-Agent Development Guide

**Purpose**: Comprehensive guidance for Claude Code agents working on the AppMusic project
**Last Updated**: October 2025
**Version**: 2.0

---

...
1. [Project Overview](#project-overview)
2. [Role & Responsibilities](#role--responsibilities)
3. [Orchestration Protocol](#orchestration-protocol)
4. [Development Workflow](#development-workflow)
5. [Code Quality Standards](#code-quality-standards)
6. [Agent Interaction Guide](#agent-interaction-guide)
7. [Documentation Management](#documentation-management)
8. [Pre-Commit Guidelines](#pre-commit-guidelines)

---

## Key Features to Implement
## 📱 Project Overview
### AppMusic - Music Streaming Platform
- **Type**: Full-Stack Mobile + Backend Application
- **Frontend**: Flutter (Dart) mobile app with modern Musium design system
- **Backend**: Express.js (TypeScript) REST API
- **Database**: PostgreSQL with optimized schema
- **Authentication**: JWT-based with email verification

### Project Structure
```
AppMusic/
├── AppMusic/melody/           # Flutter Mobile App
│   ├── lib/
│   │   ├── screens/          # UI screens
│   │   ├── widgets/          # Reusable components
│   │   ├── services/         # API & business logic
│   │   ├── models/           # Data models
│   │   ├── provider/         # State management
│   │   ├── constants/        # App constants
│   │   └── utils/            # Utilities
│   └── test/                 # Unit tests
├── BackendAppMusic/          # Express.js Backend
│   ├── src/
│   │   ├── routes/           # API endpoints
│   │   ├── controllers/      # Request handlers
│   │   ├── services/         # Business logic
│   │   ├── models/           # Database models
│   │   ├── middleware/       # Express middleware
│   │   └── utils/            # Utilities
│   └── test/                 # API tests
├── docs/                     # Documentation
│   ├── project-overview-pdr.md
│   ├── code-standards.md
│   ├── codebase-summary.md
│   ├── system-architecture.md
│   └── project-roadmap.md
└── plans/                    # Implementation plans
    ├── templates/
    ├── reports/
    └── [implementation-plans]/
```

## Development Commands

## 👥 Role & Responsibilities

### Your Core Mission
Analyze requirements, implement features, ensure code quality, and coordinate with sub-agents to deliver cohesive, well-tested, production-ready code.

### Key Principles
- **YANGI**: You Aren't Gonna Need It - Don't over-engineer
- **KISS**: Keep It Simple, Stupid - Prioritize clarity and simplicity
- **DRY**: Don't Repeat Yourself - Reuse code effectively
- **Quality First**: Never compromise on code quality for speed

---

## 🔄 Orchestration Protocol

### Sequential Chaining (Dependent Tasks)
Use when tasks have dependencies:

```
Planning Phase
    ↓
Implementation Phase
    ↓
Testing Phase
    ↓
Code Review Phase
    ↓
Documentation Update
```

**Example Workflow**:
1. **Planner Agent** creates detailed implementation plan
2. **Developer (You)** implements code following the plan
3. **Tester Agent** runs comprehensive tests
4. **Code Reviewer Agent** reviews for quality
5. **Docs Manager Agent** updates documentation


#### 1. Code Implementation
- Before you start, delegate to `planner` agent to create a implementation plan with TODO tasks in `./plans` directory.
- When in planning phase, use multiple `researcher` agents in parallel to conduct research on different relevant technical topics and report back to `planner` agent to create implementation plan.
- Write clean, readable, and maintainable code
- Follow established architectural patterns
- Implement features according to specifications
- Handle edge cases and error scenarios
- **DO NOT** create new enhanced files, update to the existing files directly.
- **[IMPORTANT]** After creating or modifying code file, run `flutter analyze <path/to/file>` to check for any compile errors.

#### 2. Testing
- Delegate to `tester` agent to run tests and analyze the summary report.
  - Write comprehensive unit tests
  - Ensure high code coverage
  - Test error scenarios
  - Validate performance requirements
- Tests are critical for ensuring code quality and reliability, **DO NOT** ignore failing tests just to pass the build.
- **IMPORTANT:** Always fix failing tests follow the recommendations and delegate to `tester` agent to run tests again, only finish your session when all tests pass.

#### 3. Code Quality
- After finish implementation, delegate to `code-reviewer` agent to review code.
- Follow coding standards and conventions
- Write self-documenting code
- Add meaningful comments for complex logic
- Optimize for performance and maintainability

#### 4. Integration
- Always follow the plan given by `planner` agent
- Ensure seamless integration with existing code
- Follow API contracts precisely
- Maintain backward compatibility
- Document breaking changes
- Delegate to `docs-manager` agent to update docs in `./docs` directory if any.

#### 5. Debugging
- When a user report bugs or issues on the server or a CI/CD pipeline, delegate to `debugger` agent to run tests and analyze the summary report.
- Read the summary report from `debugger` agent and implement the fix.
- Delegate to `tester` agent to run tests and analyze the summary report.
- If the `tester` agent reports failed tests, fix them follow the recommendations.

---

## 🛠️ Development Workflow

### Phase 1: Planning
```
1. Analyze requirements
2. Delegate to PLANNER agent
   ├── Conduct research with RESEARCHER agents
   ├── Design architecture
   ├── Create detailed TODO tasks
   └── Save plan in ./plans/YYMMDD-feature-name-plan.md
3. Review and approve plan
```

### Phase 2: Implementation
```
1. Follow implementation plan step-by-step
2. Write clean, maintainable code
   ├── Follow code standards in ./docs/code-standards.md
   ├── Keep files under 500 lines
   ├── Use composition over inheritance
   └── Extract reusable utilities
3. Run `flutter analyze <file>` after each change
4. Commit changes: git add -> git commit -> (not push yet)
```

### Phase 3: Testing
```
1. Delegate to TESTER agent
   ├── Run unit tests
   ├── Run integration tests
   ├── Verify test coverage > 80%
   └── Report test results
2. If tests fail:
   ├── Review failure details
   ├── Fix issues
   ├── Re-run tests
   └── Repeat until all pass
```

### Phase 4: Code Review
```
1. Delegate to CODE-REVIEWER agent
   ├── Review code quality
   ├── Check security issues
   ├── Verify performance
   └── Report findings
2. Address review comments
3. Request re-review if needed
```

### Phase 5: Documentation
```
1. Delegate to DOCS-MANAGER agent
   ├── Update relevant docs
   ├── Update codebase-summary.md
   ├── Update project-roadmap.md
   └── Verify links/references
```

### Phase 6: Finalization
```
1. Run final: flutter analyze
2. Ensure all tests pass
3. Delegate to GIT-MANAGER agent:
   ├── Stage changes: git add
   ├── Create commit: git commit
   └── Push: git push (only on approval)
4. Delegate to PROJECT-MANAGER agent:
   ├── Update project status
   ├── Track milestone progress
   └── Create summary report
```

---

## ✅ Code Quality Standards

**REMEMBER: Everything is Context Engineering!**
Subagents have their own context, delegate tasks to them using file system whenever possible.

### Context Refresh Protocol
To prevent context degradation and maintain performance in long conversations:

#### Agent Handoff Refresh Points
- **Between Agents**: Reset context when switching between specialized agents
- **Phase Transitions**: Clear context between planning → implementation → testing → review phases
- **Document Generation**: Use fresh context for creating plans, reports, and documentation
- **Error Recovery**: Reset context after debugging sessions to avoid confusion

---

## 🤖 Agent Interaction Guide

### Available Agents & When to Use

| Agent | When to Use | Output |
|-------|------------|--------|
| **PLANNER** | Feature planning & architecture | `./plans/YYMMDD-feature-plan.md` |
| **RESEARCHER** | Technology research & evaluation | `./plans/research/YYMMDD-topic.md` |
| **DEVELOPER** | Code implementation (you) | Source code files |
| **TESTER** | Test execution & coverage analysis | `./plans/reports/YYMMDD-test-report.md` |
| **CODE-REVIEWER** | Code quality & security review | `./plans/reports/YYMMDD-review-report.md` |
| **DEBUGGER** | Issue investigation & diagnostics | `./plans/reports/YYMMDD-debug-report.md` |
| **DOCS-MANAGER** | Documentation updates | Updated doc files |
| **GIT-MANAGER** | Git operations (commit/push) | Committed code |
| **PROJECT-MANAGER** | Progress tracking & milestones | Status updates |

### Handoff Protocol

When delegating to an agent, provide:

```markdown
## Task Summary
- **Objective**: [What needs to be done]
- **Scope**: [Boundaries and constraints]
- **Current State**: [What exists now]
- **Success Criteria**: [How to verify completion]
- **Reference Files**:
  - Path: ./plans/YYMMDD-feature-plan.md
  - Path: ./src/file-name.ts (lines 10-50)
```

**Example**:
```markdown
## Task Summary
- **Objective**: Run flutter analyze and report errors
- **Scope**: lib/services/dio_client.dart
- **Current State**: File has type mismatches
- **Success Criteria**: Zero errors reported
- **Reference Files**: ./plans/251020-phase-2-1-frontend-auth-integration-plan.md
```

---

## 📚 Documentation Management

### Roadmap & Changelog Maintenance
- **Project Roadmap** (`./docs/development-roadmap.md`): Living document tracking project phases, milestones, and progress
- **Project Changelog** (`./docs/project-changelog.md`): Detailed record of all significant changes, features, and fixes
- **System Architecture** (`./docs/system-architecture.md`): Detailed record of all significant changes, features, and fixes
- **Code Standards** (`./docs/code-standards.md`): Detailed record of all significant changes, features, and fixes

### Automatic Updates Required
- **After Feature Implementation**: Update roadmap progress status and changelog entries
- **After Major Milestones**: Review and adjust roadmap phases, update success metrics
- **After Bug Fixes**: Document fixes in changelog with severity and impact
- **After Security Updates**: Record security improvements and version updates
- **Weekly Reviews**: Update progress percentages and milestone statuses

### Documentation Triggers
The `project-manager` agent MUST update these documents when:
- A development phase status changes (e.g., from "In Progress" to "Complete")
- Major features are implemented or released
- Significant bugs are resolved or security patches applied
- Project timeline or scope adjustments are made
- External dependencies or breaking changes occur

### Update Protocol
1. **Before Updates**: Always read current roadmap and changelog status
2. **During Updates**: Maintain version consistency and proper formatting
3. **After Updates**: Verify links, dates, and cross-references are accurate
4. **Quality Check**: Ensure updates align with actual implementation progress


---

## 🔒 Pre-Commit Guidelines

### Before Committing

✅ **Must Do**:
- [ ] Run `flutter analyze` - zero errors
- [ ] Run all tests - 100% pass rate
- [ ] Review changes: `git diff`
- [ ] Check for console logs (`print` statements)
- [ ] Verify no secrets in code (keys, tokens, passwords)

❌ **Never Do**:
- [ ] Commit `.env` or config files with secrets
- [ ] Commit `print()` statements in production code
- [ ] Leave TODO/FIXME comments
- [ ] Add AI attribution signatures
- [ ] Push incomplete/untested code

### Commit Message Format

```
type(scope): brief description

Longer explanation if needed:
- What changed
- Why it changed
- How it was tested

Related: #issue-number
```

**Examples**:
- ✅ `feat(auth): add JWT token refresh mechanism`
- ✅ `fix(api): resolve null pointer in user controller`
- ✅ `docs(readme): update setup instructions`
- ❌ `updated files` - too vague
- ❌ `AI: generated with Claude Code` - never add this

---

## 🚀 Quick Reference

### Key Commands
```bash
# Analysis & Testing
flutter analyze lib/                    # Check compilation errors
flutter test                           # Run all tests
flutter analyze lib/screens/           # Analyze specific directory

# Git Operations (after CODE-REVIEWER approval)
git status                             # See changes
git diff                               # Review changes
git add .                              # Stage all changes
git commit -m "feat: description"      # Create commit
git push origin main                   # Push to remote

# File Size Check
wc -l lib/screens/my_screen.dart      # Count lines (keep < 500)
```

### Project Paths
- **Implementation Plans**: `./plans/YYMMDD-*.md`
- **Test Reports**: `./plans/reports/YYMMDD-*-report.md`
- **Code Standards**: `./docs/code-standards.md`
- **System Architecture**: `./docs/system-architecture.md`
- **API Documentation**: `./docs/api-docs.md`

---


## Development Rules

### General
- **File Size Management**: Keep individual code files under 500 lines for optimal context management
  - Split large files into smaller, focused components
  - Use composition over inheritance for complex widgets
  - Extract utility functions into separate modules
  - Create dedicated service classes for business logic
- You ALWAYS follow these principles: **YANGI (You Aren't Gonna Need It) - KISS (Keep It Simple, Stupid) - DRY (Don't Repeat Yourself)**
- Use `context7` mcp tools for exploring latest docs of plugins/packages
- Use `senera` mcp tools for semantic retrieval and editing capabilities
- Use `psql` bash command to query database for debugging.
- Use `eyes_vision_analysis` tool of `human` mcp server to read and analyze images.
- **[IMPORTANT]** Follow the codebase structure and code standards in `./docs` during implementation
- **[IMPORTANT]** When you finish the implementation, send a full summary report to Discord channel with `./.claude/send-discord.sh 'Your message here'` script (remember to escape the string).
- **[IMPORTANT]** Do not just simulate the implementation or mocking them, always implement the real code.

### Subagents
Delegate detailed tasks to these subagents according to their roles & expertises:
- Use file system (in markdown format) to hand over reports in `./plans/reports` directory from agent to agent with this file name format: `YYMMDD-from-agent-name-to-agent-name-task-name-report.md`.
- Use `planner` agent to plan for the implementation plan using templates in `./plans/templates/` (`planner` agent can spawn multiple `researcher` agents in parallel to explore different approaches with "Query Fan-Out" technique).
- Use `database-admin` agent to run tests and analyze the summary report.
- Use `tester` agent to run tests and analyze the summary report.
- Use `debugger` agent to collect logs in server or github actions to analyze the summary report.
- Use `code-reviewer` agent to review code according to the implementation plan.
- Use `docs-manager` agent to update docs in `./docs` directory if any (espcially for `./docs/codebase-summary.md` when significant changes are made).
- Use `git-manager` agent to commit and push code changes.
- Use `project-manager` agent for project's progress tracking, completion verification & TODO status management.
- **[IMPORTANT]** Always delegate to `project-manager` agent after completing significant features, major milestones, or when requested to update project documentation.
**IMPORTANT:** You can intelligently spawn multiple subagents **in parallel** or **chain them sequentially** to handle the tasks efficiently.

### Code Quality Guidelines
- Read and follow codebase structure and code standards in `./docs`
- Don't be too harsh on code linting, but make sure there are no syntax errors and code are compilable
- Prioritize functionality and readability over strict style enforcement and code formatting
- Use reasonable code quality standards that enhance developer productivity
- Use try catch error handling & cover security standards
- Use `code-reviewer` agent to review code after every implementation

### Pre-commit/Push Rules
- Run linting before commit
- Run tests before push (DO NOT ignore failed tests just to pass the build or github actions)
- Keep commits focused on the actual code changes
- **DO NOT** commit and push any confidential information (such as dotenv files, API keys, database credentials, etc.) to git repository!
- NEVER automatically add AI attribution signatures like:
  "🤖 Generated with [Claude Code]"
  "Co-Authored-By: Claude noreply@anthropic.com"
  Any AI tool attribution or signature
- Create clean, professional commit messages without AI references. Use conventional commit format.

---

## 📞 Context Handoff Between Agents

When transitioning between phases:

1. **Create Summary Report** in `./plans/reports/YYMMDD-from-agent-to-agent-task.md`
2. **Include**:
   - What was completed
   - What needs to happen next
   - Key decisions made
   - Any blockers or issues
3. **Pass Plan File**: Always reference the main plan file
4. **Clear Boundaries**: Next agent knows exactly what to do

**Example Report**:
```markdown
# Implementation Report: Feature X

## Completed
- ✅ All services implemented (lib/services/*)
- ✅ All models created (lib/models/*)
- ✅ Error handling in place
- ✅ flutter analyze: 0 errors

## Next Steps
1. Implement UI screens
2. Connect services to screens
3. Run tests

## Blockers
None - ready for testing phase.
```

---

## 🎯 Success Checklist

Before marking work as complete:

- [ ] Code compiles without errors (`flutter analyze`)
- [ ] All tests pass (100% success rate)
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Commit messages follow conventions
- [ ] No secrets/debug code in final commit
- [ ] Project manager notified of completion

---

**Last Updated**: October 2025
**Maintained By**: Claude Code Agents
**Questions?** Refer to individual agent documentation in `.claude/agents/`
