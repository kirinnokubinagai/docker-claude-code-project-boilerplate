# Claude Code Docker Boilerplate - Development Guide

This CLAUDE.md file provides comprehensive documentation for the Claude Code Docker Boilerplate project, enabling AI assistants to understand and work with this codebase effectively.

## 🎯 Project Overview

**Project Type**: Docker-based Development Environment Generator  
**Purpose**: Instantly create production-ready development environments with Claude Code and Master Claude Teams System integration  
**Key Innovation**: Enables multiple Claude AI instances to collaborate in teams for parallel development

### Core Features
- 🐳 **Fully Dockerized Environments** - Isolated development without polluting host system
- 🤖 **Claude Code Integration** - Latest AI development assistance
- 👥 **Master Claude Teams System** - Revolutionary team-based AI development
- 🔧 **MCP (Model Context Protocol)** - External service integrations
- 📦 **Project Templates** - Ready-to-start development

## 🏗️ Architecture

```
Claude-Project/                    # Main boilerplate repository
├── DockerfileBase                # Base Docker image with all tools
├── docker-compose-base.yml       # Template for project Docker Compose
├── docker-entrypoint.sh          # Container initialization script
├── create-project.sh             # Project creation script
├── docker-base/                  # System configuration (read-only mounted)
│   ├── bash/                     # Shell configurations
│   │   ├── .bashrc              # Developer user bash config
│   │   └── .bash_profile        # Profile settings
│   ├── claude/                   # Claude-specific files
│   │   └── CLAUDE.md            # Claude development guidelines
│   ├── config/                   # Runtime configurations
│   │   └── mcp-servers.json     # MCP server definitions
│   ├── scripts/                  # Utility scripts
│   │   ├── master-claude-teams.sh    # Team orchestration
│   │   ├── setup-mcp.sh             # MCP configuration
│   │   ├── set-pane-titles.sh       # tmux pane naming
│   │   └── show-help.sh             # Help documentation
│   └── templates/                # Configuration templates
│       ├── teams.json.example    # Team structure template
│       ├── team-tasks.json.example
│       └── workflow_state.json.example
└── projects/                     # User projects directory
    └── [project-name]/          # Individual project workspaces
```

### Container Structure
```
/workspace/                       # Project files (clean workspace)
├── documents/                    # Project documentation
│   ├── requirements.md          # Human-readable requirements
│   └── tasks/                   # Detailed task lists by team
│       ├── frontend_tasks.md
│       ├── backend_tasks.md
│       ├── database_tasks.md
│       └── devops_tasks.md
├── worktrees/                    # Team-specific git worktrees
└── /opt/claude-system/          # System files (isolated)
```

## 🛠️ Technology Stack

### Base Image & Tools
- **OS**: Alpine Linux (lightweight)
- **Runtime**: Node.js Alpine
- **Languages**: Node.js, Python 3, Lua
- **Package Managers**: npm, pnpm, pip (uv)
- **Version Control**: Git, GitHub CLI
- **Container Tools**: Docker CLI, Docker Compose
- **Terminal**: tmux, bash, fzf, peco
- **Browser Testing**: Chromium (for Playwright)
- **AI Tools**: Claude Code CLI

### Pre-configured MCP Servers
1. **GitHub** - Repository operations, PR/Issue management
2. **Supabase** - Database operations, migrations, Edge Functions
3. **Obsidian** - Document management, knowledge base
4. **LINE Bot** - Messaging and notifications
5. **Stripe** - Payment integration
6. **Playwright** - Browser automation
7. **Context7** - Library documentation search
8. **Magic MCP** - AI-driven UI component generation

## 📋 Key Commands

### Primary Commands
| Command          | Description                          |
| ---------------- | ------------------------------------ |
| `create-project` | Create new project (host command)    |
| `cc`             | Launch Claude CLI                    |
| `ccd`            | Launch Claude CLI (skip permissions) |
| `master`         | Start Master Claude Teams            |
| `setup-mcp`      | Configure/update MCP servers         |
| `check_mcp`      | Check MCP server status              |
| `help`           | Show command list and tmux guide     |

### Development Shortcuts
| Alias | Command           | Purpose                         |
| ----- | ----------------- | ------------------------------- |
| `pcd` | `peco-cd`         | Interactive directory selection |
| `pgb` | `peco-git-branch` | Interactive branch selection    |
| `gs`  | `git status`      | Quick git status                |
| `ta`  | `tmux attach -t`  | Attach to tmux session          |

### GitHub CLI Shortcuts
| Alias     | Command           |
| --------- | ----------------- |
| `ghpr`    | `gh pr create`    |
| `ghprl`   | `gh pr list`      |
| `ghissue` | `gh issue create` |

## 🚀 Development Workflow

### 1. Project Creation
```bash
# On host machine
create-project my-awesome-app
# Automatically:
# - Creates project directory
# - Generates docker-compose.yml
# - Initializes git repository
# - Creates Docker volumes
# - Builds and starts container
# - Connects to container shell
```

### 2. New Project Development Flow

When creating a new project from scratch, the system follows this automated workflow:

```
1. Requirements Definition
   - Use `ccd` to discuss project requirements
   - System analyzes project type and features
   - Creates documents/requirements.md

2. Technology Selection
   - Web search for latest trends
   - Context7 for version verification
   - Selects production-ready stack

3. Task Generation
   - Creates documents/tasks/*.md files
   - Detailed tasks for each team
   - Test requirements included

4. Git & GitHub Setup
   - Initialize repository
   - Create GitHub repo (interactive)
   - Initial commit

5. Development Environment
   - Install dependencies
   - Configure linters/formatters
   - Setup test frameworks
   - Create initial project structure

6. Team Configuration
   - Generate teams.json
   - Assign team responsibilities
   - STOP HERE - Master takes over
```

### 3. Master Claude Teams System

The revolutionary multi-AI collaboration system:

#### Team Structure
- **Master**: Overall coordinator, monitors all team bosses
- **Team Boss**: First member of each team, manages team members
- **Team Members**: Execute assigned tasks

#### Communication Flow
```
Master (monitors every 5 seconds)
  ↓ Assigns tasks to →
Team Bosses (monitor every 3 seconds)
  ↓ Delegate to →
Team Members
  ↓ Report completion to →
Team Boss
  ↓ Reports to →
Master
```

#### Zero-Idle Philosophy
- Master monitors all Bosses every 5 seconds
- Bosses monitor all members every 3 seconds
- Instant task assignment upon completion
- No waiting states allowed
- Proactive task preparation

## 📁 Configuration Files

### teams.json Structure
```json
{
  "project_name": "Project Name",
  "project_type": "web-app",
  "teams": [
    {
      "id": "frontend",
      "name": "Frontend Team",
      "member_count": 4,
      "branch": "team/frontend"
    }
  ]
}
```

### mcp-servers.json
Pre-configured MCP servers with environment variable support:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Environment Variables (.env)
```bash
# Required
ANTHROPIC_API_KEY=your_api_key_here

# Optional MCP Services
GITHUB_TOKEN=
SUPABASE_ACCESS_TOKEN=
STRIPE_SEC_KEY=
CHANNEL_ACCESS_TOKEN=
DESTINATION_USER_ID=
OBSIDIAN_API_KEY=
MAGIC_API_KEY=
```

## 🧪 Testing Philosophy

### Test-Driven Development
- Every completed task must include tests
- Tests must pass before committing
- Test structure:
  ```
  tests/
  ├── e2e/          # Playwright E2E tests
  ├── backend/      # Backend unit tests
  └── unit/         # Frontend unit tests
  ```

### Playwright Configuration
- Headless mode enforced in container
- Chromium pre-installed
- Environment variables set for CI mode

## 🔧 Development Principles

### Code Quality Standards
1. **Documentation**: JSDoc for all functions
2. **Early Returns**: Preferred over nested conditions
3. **Maximum Nesting**: 3 levels
4. **Variable Names**: Clear and searchable
5. **UI Components**: Always use Magic MCP for generation

### Complete Implementation Philosophy
- No MVP approach - build complete features
- All features implemented in first pass
- No "future enhancements" or roadmaps
- Production-ready from start

## 📝 Git Commit with Activity Logs

When making commits using Claude Code, follow this process to maintain activity logs:

### Commit Process with Activity Logging

1. **Before committing**, create an activity log file:
   ```bash
   # Create documents/activity_logs directory if it doesn't exist
   mkdir -p documents/activity_logs
   
   # Create activity log with timestamp
   # Format: yyyy-mm-dd_HH-MM-SS_work-description.md
   # Example: 2024-01-15_14-30-00_add-user-authentication.md
   ```

2. **Activity log template**:
   ```markdown
   # Activity Log: [Brief Description]
   
   **Date**: [YYYY-MM-DD HH:MM:SS]
   **Author**: Claude Code
   **Commit Hash**: [Will be added after commit]
   
   ## Summary
   [Brief summary of changes]
   
   ## Changes Made
   - [List of specific changes]
   - [File modifications]
   - [Features added/removed]
   
   ## Files Modified
   - `path/to/file1.js` - [Description of changes]
   - `path/to/file2.py` - [Description of changes]
   
   ## Testing
   - [Tests performed]
   - [Test results]
   
   ## Notes
   [Any additional notes or considerations]
   ```

3. **Commit workflow**:
   ```bash
   # 1. Check status
   git status
   
   # 2. Create activity log
   echo "Creating activity log..."
   # [Create the log file as shown above]
   
   # 3. Stage changes including activity log
   git add .
   
   # 4. Commit with descriptive message
   git commit -m "feat: [description]
   
   📝 Activity log: documents/activity_logs/[filename]
   
   🤖 Generated with Claude Code
   Co-Authored-By: Claude <noreply@anthropic.com>"
   
   # 5. Update activity log with commit hash
   git log -1 --format="%H" # Get commit hash
   # Update the activity log file with the hash
   ```

### Activity Log Naming Convention
- **Format**: `yyyy-mm-dd_HH-MM-SS_brief-description.md`
- **Time**: Use 24-hour format
- **Description**: Use kebab-case, max 50 characters
- **Examples**:
  - `2024-01-15_09-30-00_fix-login-bug.md`
  - `2024-01-15_14-45-30_add-payment-integration.md`
  - `2024-01-15_18-00-00_refactor-database-schema.md`

### Important Notes
- Always create the activity log BEFORE committing
- Include the activity log in the same commit
- Reference the log file in the commit message
- Keep logs concise but informative
- Use consistent formatting

## 🐛 Troubleshooting

### Common Issues

1. **Memory Constraints**
   - Use `master --phased` for gradual startup
   - Reduce team sizes if needed
   - Monitor with `docker stats`

2. **Container Won't Start**
   ```bash
   docker compose logs
   docker compose down
   docker compose up -d --build
   ```

3. **MCP Server Issues**
   ```bash
   setup-mcp  # Reconfigure servers
   check_mcp  # Verify status
   ```

4. **Claude Authentication**
   ```bash
   cl         # or clogin
   claude login
   ```

## 🚦 Status Indicators

### Git Status
- **Modified Files**: DockerfileBase, docker-compose-base.yml, docker-entrypoint.sh
- **Current Branch**: main
- **Recent Commits**: Feature improvements and environment optimization

### Container Health Checks
- tmux session: `claude-teams`
- MCP servers: Configured via setup-mcp.sh
- Authentication: Checked on container start

## 📝 Development Best Practices

1. **Always Prefer Editing Over Creating**
   - Edit existing files when possible
   - Only create new files when absolutely necessary

2. **Task Management**
   - Use documents/tasks/*.md for tracking
   - Mark completed tasks with [x]
   - Add new tasks as discovered

3. **Testing Requirements**
   - E2E tests for UI features
   - Unit tests for business logic
   - Integration tests for APIs
   - All tests must pass before commit

4. **Communication Patterns**
   - Clear task descriptions
   - Regular status updates
   - Immediate problem escalation

## 🎯 Quick Reference

### Starting a New Project
```bash
create-project my-app
ccd  # Define requirements
master  # Start team development
```

### Connecting to Existing Session
```bash
tmux attach -t claude-teams
```

### Checking System Status
```bash
docker ps
tmux list-sessions
check_mcp
```

### Emergency Commands
```bash
docker compose down
docker system prune -a
tmux kill-server
```

---

**Note**: This CLAUDE.md serves as the primary reference for AI assistants working with this codebase. It should be kept synchronized with any architectural changes or workflow updates.