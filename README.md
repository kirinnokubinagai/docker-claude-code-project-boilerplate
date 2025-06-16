# Master Claude Teams System

A streamlined Docker environment for running Claude Code with team-based development workflow.

## 🚀 Quick Start

### 1. Create New Project (Recommended)

#### Setup (one-time)

**For Fish shell users:**
```fish
# Add to ~/.config/fish/config.fish
alias create-project='sh ~/Project/docker-claude-code-boiler-plate/create-project.sh'
```

**For Bash shell users:**
```bash
# Add to ~/.bashrc
source ~/Project/docker-claude-code-boiler-plate/create-project.sh
```

#### Create and Start Project
```bash
create-project my-app
# This will:
# 1. Copy boilerplate to ~/Project/my-app
# 2. cd to the project directory
# 3. Run docker compose up -d
# 4. Connect as developer user automatically
```

### 2. Manual Setup (Alternative)
```bash
./init-project.sh my-project
cd my-project
docker compose up -d
docker exec -it -u developer my-project-app-1 bash
```

### 3. Create Your App (with Claude)
```bash
ccd  # Describe your app to Claude
```

### 4. Launch Team
```bash
master  # Teams will be created based on team-tasks.json
```

## 📋 Workflow

1. **Init** → Creates project structure
2. **Docker** → Starts development environment  
3. **Claude (cc)** → Describe app requirements
4. **Master** → Launches team based on tasks
5. **Development** → Teams work hierarchically

## 📁 Structure

```
project/
├── config/
│   ├── teams.json        # Team configuration
│   └── team-tasks.json   # Tasks per team/member
├── docker/               # Docker configuration
├── lib/                  # Core libraries
├── scripts/              # Main scripts
└── team-templates/       # Team templates
```

## 🔧 Commands

- `cc` / `claude` - Claude CLI with full permissions
- `master` - Launch team system
- `check_mcp` - Check MCP server status
- `setup-mcp` - Setup MCP servers
- `create-project` - Create new project from boilerplate

### Project Creation Notes

- Project name should not contain spaces or special characters
- Container name will be `projectname-app-1`
- Existing projects with the same name will cause an error

## 📝 Team Structure

Each team consists of:
- **Boss** - Team leader, coordinates work
- **Pro1-3** - Team members with specific roles

Teams communicate hierarchically:
- Master ↔ Boss
- Boss ↔ Team Members

## 🛠️ Requirements

- Docker & Docker Compose
- Bash shell (default in container)
- Claude API key in `.env`
- Fish shell (optional, for host machine)

## 📄 License

MIT