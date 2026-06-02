# DesignFlow CLI v1.0 — Complete Product Design Document

## One-liner
One CLI tool to go from "I want X" to "X works" without touching anything but the keyboard.

**Design → Code → Preview → Deploy** — all in one tool, all running locally, completely free.

---

## 1. Core Philosophy

### The Problem: 8 Tools for 1 Job

```
Before DesignFlow:                  After DesignFlow:
──────────────────────────          ──────────────────────
1. Open IDE                         designflow start
2. Open browser → 8 tools         → everything
3. Open terminal                    1 command → product
4. Open design tool
5. Open Slack
6. Open Docker CLI
...
8 tools                              1 tool
```

### Core Features

- **Intent-driven AI** — Describe what you want, we figure out the rest
- **Three-tier confirmation** — Intent → Plan → Execute, you're never surprised
- **Visual lock** — Never lose your design system to AI hallucinations
- **Live status dashboard** — Know exactly what's happening at any moment
- **One-command to product** — From idea to running app in minutes
- **Live preview** — See your app instantly in the terminal
- **Fully local** — Zero cloud dependencies, fully offline capable
- **Open-source** — No vendor lock-in, transparent code

---

## 2. Competitive Landscape

### 2.1 What Competitors Get Right

| Product | What They Nail | How We Out-position |
|--------|--|--|
| Cursor | Composer describes → codes everywhere | Same flow, free, fully local, full-stack |
| v0.dev | Prompt → visual → code pipeline | Full pipeline + deploy |
| Linear | Keyboard-first, zero-wait | Apply that speed philosophy to our tools |
| Raycast | Global search starts everything | Apply that paradigm to ours |
| Aider | Edit-mode with clear diffs | Keep the diff, add full planning |
| Windsurf | Context-aware AI | Same vision, faster, local-first |

### 2.2 Our Moat

| Feature | Cursor | v0.dev | Aider | DesignFlow |
|--------|--|---|---|--|
| Design pipeline | ❌ | Basic | ❌ | ✅✅✅ |
| Deploy | ❌ | ❌ | ❌ | ✅✅✅ |
| Fully local | ❌ | ❌ | ❌ | ✅✅✅ |
| Open-source | ❌ | ❌ | ✅ | ✅✅✅ |
| Visual lock | ❌ | ❌ | ❌ | ✅✅✅ |
| Multi-agent | ❌ | ❌ | ❌ | ✅✅✅ |
| Free | ❌ | ❌ | ✅ | ✅✅✅ |

---

## 3. Agent System

### 3.1 Five Specialized Agents

```
🧠 Scheduler Agent (Global orchestration)
  ├── 🎨 Designer Agent (Penpot integration, tokens, visual lock)
  ├── 💻 Code Agent (Code generation, review, fix)
  ├── 🔧 Test Agent (Compiler, test runner)
  └── 🚀 Deploy Agent (Docker, deploy, services)
```

### 3.2 Agent Communication

| Direction | Mechanism | Purpose |
|-----------|---|---|
| Scheduler → Agent | MCP task dispatch | Task dispatch |
| Agent → Scheduler | WebSocket push | Status updates every 2s |
| Agent → Agent | WebSocket push | Task status |
| Agent → Scheduler | WebSocket push | Error alerts |

### 3.3 Agent Status Machine

```
[ready] → [busy] → [ready] → [busy] ...
   |          |
   | error    | error
   v          v
[error] → [ready] (auto-retry)
```

---

## 4. Core UX Flow

### 4.1 Complete Walk Through

```
Step 1: User starts
──────────────
designflow start "Make a todo app"
→ DesignFlow CLI v1.0
→ Agent system ready
→ Loading project context

> Input your requirements...

Step 2: User inputs requirements
──────────────
> Help me build a todo app with blue theme
> Support add / delete / complete

Step 3: 🧠 Intent analysis
──────────────
📋 Intent:
┌─────────────────────────────────────────┐
│ Features:                              │
│   Add todo, delete todo, complete todo │
│ Design:                                │
│   Primary color: #3B82F6               │
│   Font: Inter                          │
│   Border-radius: 8px                   │
│ Tech Stack:                            │
│   Frontend: React + Tailwind           │
│   Backend: FastAPI + SQLite            │
│   Design tool: Penpot                  │
│ Is this right? [Y/N/Edit]              │
└─────────────────────────────────────────┘

Step 4: User confirms → Y

Step 5: 🧠 Plan generation
──────────────
📋 Execution Plan:
┌─────────────────────────────────────────┐
│ Phase 1: Design System (~2min)         │
│   Generate design tokens               │
│   Create base components               │
│   Generate style guide                 │
│ Phase 2: Frontend (~3min)              │
│   Create React project                 │
│   Generate TodoList components          │
│   Generate TodoForm components          │
│ Phase 3: Backend (~2min)               │
│   Create FastAPI project               │
│   Generate Todo API                    │
│   Generate database models             │
│ Phase 4: Test & Preview (~1min)        │
│   Compile validation                   │
│   Start services                       │
│   Auto-open preview                    │
│ Phase 5: Deploy (~1min)                │
│   Generate Docker config               │
│   Build and start containers           │
│ Total: ~9 分钟                         │
│ Confirm? [Y/N/Edit]                    │
└─────────────────────────────────────────┘

Step 6: User confirms → Y

Step 7: Agents execute in parallel
──────────────▶ Phase 1: 🎨 Design Agent
  Generating color tokens (72%)
  Creating base components (45%)
  Generating style guide (30%)

▶ Phase 2: 💻 Code Agent
  Creating React project (20%)
  Generating Todo components (64%)
  Creating form components (45%)

▶ Phase 3: 💻 Code Agent
  Creating FastAPI project (10%)
  Generating Todo API (70%)
  Creating database models (50%)

▶ Phase 4: 🔧 Test Agent
  Compiling validation (85%)
  Starting services (100%)
  Opening preview (100%)

▶ Phase 5: 🚀 Deploy Agent
  Generating Docker configuration (60%)

Step 8: Status updates
──────────────
✅ Phase 1: 🎨 Design System (82%)
✅ Phase 2: 💻 Frontend (64%)
✅ Phase 3: 🔧 Backend (70%)
✅ Phase 4: 🔧 Test & Preview (100%)
✅ Phase 5: 🚀 Deploy (100%)

Preview auto-opened:
┌─────────────────────────────────────────┐
│ Todo App                              │
│                                       │
│   Read a book ✓                      │
│   Buy groceries ✓                    │
│   Write code ☐                       │
│                                       │
│ [input: Add a todo      ] [Add ]      │
└─────────────────────────────────────────┘

Step 9: User iterates
──────────────
> Change buttons to green

Step 10: AI checks visual lock
──────────────
🔒 Visual Lock detected!

Primary color #3B82F6 is locked
You want to change it to green → #22C55E

How should we proceed?
  [Y] Update token for all components
  [N] Override lock (only once)
  [S] Skip this change

Step 11: User chooses [Y]
──────────────
🔧 Updating design tokens...
Primary: #3B82F6 → #22C55E
Secondary: #10B981 → #22C55E

✅ Design tokens updated!
✅ Regenerating components...
✅ New code generated!
✅ Preview refreshed!

Step 12: Deploy
──────────────
> Deploy to docker

Generating Dockerfile...
Running build...
Starting containers...

✅ Deployed!
🌐 http://your-server.com
```

---

## 5. Visual Lock System

### 5.1 Design Tokens

```json
{
  "version": "1.0",
  "colors": {
    "primary": {
      "hex": "#3B82F6",
      "use": "Primary UI elements",
      "locked": true
    },
    "secondary": {
      "hex": "#10B981",
      "use": "Secondary elements & backgrounds",
      "locked": false
    },
    "surface": {
      "hex": "#F9FAFB",
      "use": "Page backgrounds & content areas",
      "locked": false
    }
  },
  "fonts": {
    "heading": {
      "family": "Inter",
      "weight": "700",
      "use": "Headings & titles",
      "locked": true
    },
    "body": {
      "family": "Inter",
      "weight": "400",
      "use": "Body text & descriptions",
      "locked": false
    }
  }
}
```

### 5.2 Visual Lock Enforcement

When AI generates code:

```css
.btn {
  background: #3B82F6 !important;  /* ← Locked by token */
  font-family: Inter !important;    /* ← Locked by token */
  border-radius: 8px !important;    /* ← Locked by token */
  transition: all 0.2s ease;        ← AI CAN add new props
}
```

---

## 6. Three-Tier Confirmation

### 6.1 Tier 1: Intent

```
📋 I understand you want:
───────────────────────────────
Features:
  • Add todo
  • Delete todo
  • Complete todo
  • Mark as done
  • Filter by status
  • Search by title

Design:
  • Primary color: #3B82F6
  • Font: Inter
  • Border-radius: 8px
  • Spacing: 16px between items
  • Layout: Single column

Tech Stack:
  • Frontend: React + Tailwind
  • Backend: FastAPI + SQLite
  • Database: SQLite
  • Deployment: Docker Compose
  • Design: Penpot

🤖 Is this right? [Y/N/Edit]
```

### 6.2 Tier 2: Plan

```
📋 Here's your plan:
───────────────────────────────
Phase 1: Design (~2min)
  • Design tokens (colors, fonts, spacing)
  • Create base components
  • Generate style guide
Phase 2: Frontend (~3min)
  • Create React project scaffold
  • Generate Todo components
  • Generate Form components
  • Generate List components
Phase 3: Backend (~2min)
  • Create FastAPI project
  • Generate Todo API
  • Generate database models
Phase 4: Test & Preview (~1min)
  • Compile validation
  • Start services
  • Auto-open preview

Total: ~8 minutes
🟢 Execute? [Y/N/Edit]
```

### 6.3 Tier 3: Execution

```
⚠️ The following will be executed:
───────────────────────────────   · Create/modify 15 files
  · Start 2 services
  · Open preview to localhost:3000
  · All operations run locally
  · No cloud data transmission
  · Open source & privacy-safe
  · AI models run offline
  · No web calls made

🟢 Execute? [Y/N/Continue]
  · Y: Start immediately
  · N: Cancel
  · Continue: Continue without confirmation
```

---

## 7. CLI Interface

### 7.1 Three Interaction Modes

```
Mode 1: Natural Language (Primary)
──────────────────────────────────────
Type: / "Make a todo app"
Type: / "change buttons to green"
Type: / "delete the footer"
Type: / "generate tests"

Mode 2: Command Line (Secondary)
──────────────────────────────────────
designflow agents status
designflow deploy
designflow diff show
designflow plan approve

Mode 3: Keyboard Shortcuts (Power Users)
───────────────────────────────────────────
⌘K - Global search (files, agents, commands)
⌘N - New project
⌘O - Open existing project
⌘R - Restart all agents
⌘Z - Undo last change
⌘D - Show files changed
⌘P - Open preview
⌘S - Save changes
⌘1-5 - Switch agent panel
F1   - Help
```

### 7.2 Core Commands

```bash
# Agent management
agents                      # View all agent status
agent start [name]          # Start agent
agent stop [name]           # Stop agent
agent restart [name]        # Restart agent
agent status [name]         # View status
agent logs [name]           # View logs

# Design management
design save                 # Save design system
design export               # Export design system
design import               # Import design system
design show                 # Show current design system
design tokens               # Show design tokens
design lock                 # Lock design

# Code management
code generate [name]        # Generate code
code review [name]          # Review code
code diff [name]            # View diff
code accept [name]          # Accept diff
code reject [name]          # Reject diff
code commit                 # Commit code

# Deployment management
deploy docker              # Deploy to Docker
deploy vercel              # Deploy to Vercel
deploy netlify             # Deploy to Netlify
deploy preview             # Preview deployment

# Workflow management
workflow start             # Start workflow
workflow stop              # Stop workflow
workflow status            # View status
workflow history           # View history
```

### 7.3 Terminal Layout

```
┌───────────────────────────────────────────────────────────┐
│ DesignFlow CLI v2.0                                         │
│ ────────────────────────────────────────────────────────── │
│                                                           │
│  Phase 1: Design System (Complete)                        │
│    ✅ Color tokens: Primary #3B82F6                       │
│    ✅ Font: Inter                                         │
│    ✅ Base components                                     │
│                                                           │
│  Phase 2: Frontend (Complete)                             │
│    ✅ React project                                       │
│    ✅ TodoList, TodoItem, TodoForm                        │
│    ✅ Tailwind injection                                  │
│    ✅ Visual lock enforcement                             │
│                                                           │
│  Phase 3: Backend (Complete)                              │
│    ✅ FastAPI project                                     │
│    ✅ Todo API endpoints                                  │
│    ✅ SQLite integration                                  │
│                                                           │
│  Phase 4: Test & Preview (Complete)                       │
│    ✅ Compile validation                                  │
│    ✅ Unit tests passed                                   │
│    ✅ Preview server                                      │
│       http://localhost:3000                               │
│                                                           │
│  Phase 5: Deploy (Complete)                               │
│    ✅ Docker config                                       │
│    ✅ Docker build                                        │
│    ✅ Services running                                    │
│       http://your-server.com                              │
│                                                           │
│  🟢 Ready for iteration!                                │
│  > Input your requirements:                              │
│    "Make the buttons green"                              │
└───────────────────────────────────────────────────────────┘
```

---

## 8. Architecture

### 8.1 Architecture Diagram

```
                    ┌─────────┐
                    │  User   │
                    │Terminal │
                    └─┬───┬──┘
                      │   │
                    ┌──┴───┴──┐
                    │  CLI    │
                    │  Layer  │
                    └───┬───┬─┘
                        │   │
                    ┌───┴───┴───┐
                    │  Agent    │
                    │Orchestration│
                    │───┬───┬───┬─┐
                    │   │   │   │   │
                    │  Scheduler  │   │
                    │    │        │   │
                    │  ┌───┴────┴──┐ │
                    │  │          │   │
                    │  │  Agent   │  │
                    │  │ System  │  │
                    │  └───┬───┬─┘  │
                    │     │     │    │
                    │    ┌┴┐  ┌┴┐ ┌┴┐│
                    │    │D│  │C│ │T││
                    │    └┬┘  └┬┘ └┬┘│
                    │  ┌──┴── ┴── ┴──┐
                    │  │    Agent    │
                    │  │   Layer     │
                    │  │  ┌─┬─┬─┐   │
                    │  │  │ │ │ │   │
                    │  │  └─┴─┴─┘   │
                    │  └──────┬─────┘
                    │         │
                    │  ┌─────┴──┐
                    │  │  Deploy │
                    │  │ Service │
                    │  └────────┘
                    └─────┬───┬──────┘
                        │   │
                    ┌───┴───┴───┐
                    │   Docker   │
                    │   Runtime  │
                    └─────────────┘
```

### 8.2 Architecture Components

```
┌─────────────────────────────────────────┐
│  Infrastructure Components              │
├───────────┬───────────┬────────────────┤
│  Layer    │  Tech     │  Description   │
├───────────┼───────────┼────────────────┤
│  Core     │  Ink      │  Terminal UI   │
│  Layer    │  TypeScript│                │
├───────────┼───────────┼────────────────┤
│  Agent    │  LangGraph │  Agent logic   │
│  Layer    │  MCP      │  Tool calling  │
├───────────┼───────────┼────────────────┤
│  AI       │  OpenWebUI │  Local web UI  │
│Layer       │  Ollama  │  Inference     │
├───────────┼───────────┼────────────────┤
│  Design    │  Penpot  │  Visual design │
│  Layer     │          │                │
├───────────┼───────────┼────────────────┤
│  Deploy    │  Docker   │  Container     │
│  Layer     │  Vercel  │  Deploy        │
└───────────┴───────────┴────────────────┘
```

### 8.3 Agent Communication Matrix

| Source | Target | Method | Frequency |
|--------|--------|--------|-----------|
| Scheduler | All agents | MCP dispatch | On-demand |
| Scheduler | Agent | WebSocket push | Every 2s |
| Agent | Scheduler | WebSocket push | Every 2s |
| Agent | Agent | WebSocket push | On event |
| Agent | Scheduler | WebSocket push | Error alert |

---

## 9. Technical Architecture

### 9.1 Core Tech Stack

| Layer | Technology | Purpose |
|--|--|--|
| Core Framework | Blessed-contrib | Terminal UI |
| Agent Layer | LangGraph, MCP | Agent orchestration & tool calling |
| AI Layer | Ollama + Qwen2.5/Llama-3.1 | Local inference |
| Design Tool | Penpot | Visual design |
| Deployment | Docker, Vercel, Netlify | Containerize & deploy |
| Backend | FastAPI, SQLite, Express | Server-side |

### 9.2 Agent System Architecture

```
┌───────────┬──────────┬──────────┬──────────┬──────────┐
│  Scheduler│  Designer │  Code    │  Test    │  Deploy  │
│   Agent   │   Agent  │  Agent   │  Agent   │  Agent   │
├───────────┼──────────┼──────────┼──────────┼──────────┤
│  Intent   │  Create  │  Generate│  Validate│  Docker  │
│  Analysis │  Tokens  │  Code    │  Code    │  Config  │
│  Planning │  Design  │  Code    │  Compile │  Docker  │
│  Task     │  Locks   │  Styles  │  Tests   │  Build   │
│  Dispatch │  Visual  │  Diff    │  Preview │  Deploy  │
│  Sync     │  Lock    │  Merge   │  Serve   │  Monitor │
└───────────┴──────────┴──────────┴──────────┴──────────┘
```

### 9.3 Visual Lock System

#### Token Definition

```json
{
  "version": "1.0",
  "colors": {
    "primary": {
      "hex": "#3B82F6",
      "use": "Primary UI elements",
      "locked": true
    },
    "secondary": {
      "hex": "#10B981",
      "use": "Secondary elements & backgrounds",
      "locked": true
    },
    "surface": {
      "hex": "#F9FAFB",
      "use": "Page backgrounds & content areas",
      "locked": false
    }
  },
  "fonts": {
    "heading": {
      "family": "Inter",
      "weight": "700",
      "use": "Headings & titles everywhere",
      "locked": true
    },
    "body": {
      "family": "Inter",
      "weight": "400",
      "use": "Body text & descriptions",
      "locked": false
    }
  }
}
```

#### Visual Lock Enforcement

When AI generates code:

```css
.btn {
  background: #3B82F6 !important;  /* ← Locked by token */
  font-family: Inter !important;    /* ← Locked by token */
  border-radius: 8px !important;    /* ← Locked by token */
  transition: all 0.2s ease;        /* ← AI can add new props */
  box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.1);
}
```

---

## 10. Agent Status Dashboard

### 10.1 Real-Time Status

```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  Agent   │  Status  │ Progress │  Tasks   │ Alerts   │
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ Scheduler│  Ready   │ 100%     │ 4/4 done │    0     │
│  Designer│  Busy    │ 64%      │ 47/72    │    0     │
│   Code   │  Busy    │ 70%      │ 25/36    │    0     │
│   Test   │  Idle    │ 0%       │ 0/0      │    0     │
│  Deploy  │ Idle     │ 0%       │ 0/0      │    0     │
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

### 10.2 Status Flow

```
Ready ──▶ Busy ──▶ Ready ──▶ Busy ──▶ ...
  │         │        │        │
  │error    │error    │error   │error
  │         │        │        │v
  │error    │        │        │
  ▼         ▼        ▼        ▼
 Error ──▶ Ready ──▶ Busy ──▶ ...
  │               │        │
  │                │        │
  ├─────▶ Busy ─▶ Ready ─▶ ...
```

---

## 11. User Iteration Flow

### 11.1 Natural Language Interaction

```
> / Make the buttons green
  ────────────────────────────
┌────────────────────────────┐
│ I'll update primary color  │
│ from #3B82F6 to #22C55E.  │
│                           │
│ What should I update:      │
│  [1] All primary buttons   │
│  [2] Specific page         │
│  [3] All components        │
│  [4] Preview only          │
│                           │
│ Select (1-4):              │
└────────────────────────────┘
```

### 11.2 Visual Lock Override

```
🔒 Visual Lock Detected!

Primary color #3B82F6 is locked
You want to change it to green → #22C55E

How should we proceed?
  [Y] Update token for all components
  [N] Override lock (only once)
  [S] Skip this change

> n
✅ Okay, I'll unlock it this one time.
🟡 Warning: Token will be unlocked after this change.
🟡 All other locked tokens remain locked.
```

### 11.3 Deploy Flow

```
> / deploy to Docker

Generating Dockerfile...
  ✅ Created
  ✅ Base image: node:18-alpine
  ✅ Node packages
  ✅ Port 3088

Building image...
  ✅ Backend build
  ✅ Frontend build

Running tests...
  ✅ Lint passed
  ✅ Type check passed
  ✅ Unit tests: 23/23

Deploying...
  ✅ Container created
  ✅ Network configured
  ✅ Service running
  ✅ Port 3088 exposed

🌐 http://your-server:3088
```

### 11.4 Agent Error Handling

```
🔴 Error in Code Agent!

Error: Missing export in TodoForm component
Line 34: export TodoForm not found

Options:
  [1] Auto-retry (recommended)
  [2] View error details
  [3] Skip this file
  [4] Cancel and show all files

Auto-generated fix:
```typescript
// Before (error):
const TodoForm = (props) => {
  // ...
}

// After (fixed):
export const TodoForm = (props) => {
  // ...
}
```

### 12.1 Error Categories

| Name | Code | Category | Handling |
|------|------|--|-----|
| ValidationError | ERR_VAL | Validation | Show diff, ask user |
| PermissionError | ERR_PERM | Permission denied | Log and alert user |
| AgentError | ERR_AGENT | Agent failure | Retry 3 times, user decision |
| TimeoutError | ERR_TIMEOUT | Timeout | Retry, adjust timeout |
| ConflictError | ERR_CONFLICT | File conflict | Backup then retry |

### 12.2 Error Recovery

| Strategy | Description | Use Case |
|------------|-------------|------|
| Retry | 3 attempts auto | Temporary failure |
| Fallback | Alternative plan | Core failure |
| Cancel | Cancel process | User request |
| Alert | Notify user | Unexpected state |

## 13. Summary

### Core Value

```
DesignFlow CLI v2.0
────────────────
Design → Code → Preview → Deploy
One command: designflow start
Free, local, open-source
```

### Product Roadmap

| Phase | Time | Goal |
|-------|------|------|
| 1: Foundation | 2 weeks | Agent framework setup |
| 2: Features | 4 weeks | Visual lock + diff + plan |
| 3: Deployments | 2 weeks | Docker + Vercel support |
| 4: Release | 2 weeks | Docs + testing + publishing |

---

*— End of Product Design Document v1.0 —*
