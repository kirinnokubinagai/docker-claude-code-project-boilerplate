# Master Claude Teams System

A streamlined Docker environment for running Claude Code with team-based development workflow.

## 🚀 Quick Start

### 1. Initialize Project
```bash
./init-project.sh my-project
cd my-project
```

### 2. Start Docker Environment
```bash
docker-compose up -d
docker exec -it claude-dev fish
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

- `cc` - Claude CLI with full permissions
- `master` - Launch team system
- `check_mcp` - Check MCP server status

## 📝 Team Structure

Each team consists of:
- **Boss** - Team leader, coordinates work
- **Pro1-3** - Team members with specific roles

Teams communicate hierarchically:
- Master ↔ Boss
- Boss ↔ Team Members

## 🛠️ Requirements

- Docker & Docker Compose
- Fish shell (included in container)
- Claude API key in `.env`

## 📄 License

MIT