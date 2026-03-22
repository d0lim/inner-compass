# Inner Compass Global Install Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install Inner Compass as a global Claude Code plugin — commands, agents, skills in `~/.claude/`, config in `~/.inner-compass/`.

**Architecture:** All files are markdown prompts (no code to compile/test). The spec (`docs/init.md`) contains exact content for each file. Implementation is file creation in correct paths with correct content.

**Tech Stack:** Claude Code (slash commands, agents, skills), Markdown, Obsidian-compatible output

**Spec:** `docs/init.md` — sections 3-6 contain exact file content

---

### Task 1: Create global directories

**Files:**
- Create: `~/.claude/commands/` (directory)
- Create: `~/.claude/agents/` (directory)
- Create: `~/.inner-compass/` (directory)
- Create: `~/.inner-compass/sessions/` (directory)

Note: `~/.claude/skills/` already exists (has other plugins).

- [ ] **Step 1: Create directories**

```bash
mkdir -p ~/.claude/commands ~/.claude/agents ~/.inner-compass/sessions
```

- [ ] **Step 2: Verify**

```bash
ls -d ~/.claude/commands ~/.claude/agents ~/.claude/skills ~/.inner-compass/sessions
```

- [ ] **Step 3: Commit** (project repo — track the spec only, global files are outside repo)

---

### Task 2: Create `/reflect-setup` command

**Files:**
- Create: `~/.claude/commands/reflect-setup.md`

**Source:** `docs/init.md` Section 3

- [ ] **Step 1: Write file** — content from spec Section 3
- [ ] **Step 2: Verify file exists and is readable**

---

### Task 3: Create agent files (4 files)

**Files:**
- Create: `~/.claude/agents/inner-compass-collector.md`
- Create: `~/.claude/agents/inner-compass-socratic.md`
- Create: `~/.claude/agents/inner-compass-crystallizer.md`
- Create: `~/.claude/agents/inner-compass-retrospective.md`

**Source:** `docs/init.md` Section 5

- [ ] **Step 1: Write all 4 agent files** — content from spec Section 5.1-5.4
- [ ] **Step 2: Verify all files exist**

---

### Task 4: Create command files (4 files)

**Files:**
- Create: `~/.claude/commands/reflect.md`
- Create: `~/.claude/commands/reflect-quick.md`
- Create: `~/.claude/commands/reflect-deep.md`
- Create: `~/.claude/commands/reflect-review.md`

**Source:** `docs/init.md` Section 4

- [ ] **Step 1: Write all 4 command files** — content from spec Section 4.1-4.4
- [ ] **Step 2: Verify all files exist**

---

### Task 5: Create skill files (3 files)

**Files:**
- Create: `~/.claude/skills/inner-compass-pattern-detect/SKILL.md`
- Create: `~/.claude/skills/inner-compass-ontological-analysis/SKILL.md`
- Create: `~/.claude/skills/inner-compass-obsidian-export/SKILL.md`

**Source:** `docs/init.md` Section 6

- [ ] **Step 1: Create skill directories and files** — content from spec Section 6.1-6.3
- [ ] **Step 2: Verify all files exist**

---

### Task 6: Create default config file

**Files:**
- Create: `~/.inner-compass/config.md`

**Source:** `docs/init.md` Section 2.3

- [ ] **Step 1: Write default config**
- [ ] **Step 2: Verify**

---

### Task 7: Smoke test

- [ ] **Step 1: Verify all expected files are in place**

```bash
find ~/.claude/commands/reflect* ~/.claude/agents/inner-compass-* ~/.claude/skills/inner-compass-* ~/.inner-compass/ -type f | sort
```

Expected: 12 files (5 commands + 4 agents + 3 skills + 1 config = 13 files, minus directories)
