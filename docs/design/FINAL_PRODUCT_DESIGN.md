# DesignFlow CLI v2.0 — Final Product Design Document

## One-liner
One CLI tool to go from "I want X" to "X works" — no browser, no IDE, no $100/mo.

**Design → Code → Preview → Deploy** — all in one tool, all running locally, completely free.

---

## 1. Core Value Proposition

| Dimension | Competitors (Cursor, v0.dev, etc.) | DesignFlow CLI |
|------|-----|------|
| **Full pipeline** | Fragmented across tools | ✅ Design → Code → Deploy |
| **Cost** | Free trial / $10–$100/mo | Forever free, local |
| **Privacy** | Cloud inference | Fully local, offline-ready |
| **Visual lock** | Tokens overwritten by AI | ✅ Never lost |
| **Multi-agent** | Single model context | ✅ 5 specialized agents |
| **Deploy** | Limited or manual | ✅ Docker / Vercel / Netlify |
| **Open-source** | ❌ | ✅✅✅ |

---

## 2. Agent System

### 2.1 Five Specialized Agents

```
🧠 Scheduler Agent (Global orchestration)
├── 🎨 Designer Agent (Penpot integration, tokens, visual lock)
├── 💻 Code Agent (Code generation, review, fix)
├── 🔧 Test Agent (Compiler, test runner)
└── 🚀 Deploy Agent (Docker, deploy, services)
```

### 2.2 Agent Communication

| Direction | Mechanism | Purpose |
|------|------|------|
| Scheduler → Agent | MCP task dispatch | Task dispatch |
| Agent → Scheduler | WebSocket push | Status updates every 2s |
| Agent → Agent | WebSocket push | Task status |
| Agent → Scheduler | WebSocket push | Error alerts |

### 2.3 Agent Status Machine

```
[ready] → [busy] → [ready] → [busy] ...
  │          │
  │ error    │ error
  v          v
[error] → [ready] (auto-retry)
```

---

## 3. Product Roadmap

| Phase | Time | Milestone / Acceptance Criteria |
|-------|------|-------|
| **0. Foundation** | Wk 1–2 | `designflow start` launches Scheduler + Designer; tokens generated |
| **1. Visual Lock + Plan** | Wk 3–6 | Token change blocked by design system; user confirms multi-tier plan |
| **2. Backend + Full-stack** | Wk 7–8 | FastAPI + SQLite working; Test agent catches errors; rollback via snapshots |
| **3. Deploy** | Wk 9–10 | `deploy docker` builds & runs; `deploy vercel` pushes |
| **4. Docs + Release** | Wk 11–12 | `npm publish`; complete tutorial; 10+ real-world examples |

---

## 4. Security

| Aspect | Strategy |
|--------|------|
| **Token storage** | Local `~/.designflow/tokens.json` |
| **Code generation** | No cloud transmission; local model only |
| **Deploy** | User-specified endpoints; no telemetry |
| **Network** | All model inference via local Ollama; zero external calls during generation |

---

## 5. Tech Stack Selection

| Layer | Selection | Why |
|-------|------|------|
| **CLI UI** | Blessed-contrib | Industry-standard TUI; real-time updates |
| **Agent framework** | LangGraph | Persistent state + subgraphs + LangSmith debugging |
| **AI backend** | Qwen2.5 / Llama-3.1 + Ollama | Best Chinese/English open-source; local inference |
| **Backend** | FastAPI + SQLite | Fastest Python framework; zero-infra database |
| **Frontend** | Vite + React | Fastest HMR; best ecosystem |
| **Design** | Penpot | Fully open-source (Figma is proprietary) |
| **Deploy** | Docker Compose / Vercel | Standard container & serverless |
| **Persistence** | Git-backed snapshots | Every phase = snapshot; zero-config rollback |

---

## 6. Summary

| Attribute | Value |
|-----------|-------|
| **Product** | DesignFlow CLI v2.0 |
| **Pipeline** | Design → Code → Preview → Deploy |
| **Command** | `designflow start` |
| **Cost** | Free, local, open-source |
| **Agents** | 5 specialized agents |

---

*— End of Product Design Document v2.0 —*