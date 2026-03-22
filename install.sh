#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Inner Compass..."

# Commands
mkdir -p ~/.claude/commands
cp "$SCRIPT_DIR"/commands/reflect*.md ~/.claude/commands/

# Agents
mkdir -p ~/.claude/agents
cp "$SCRIPT_DIR"/agents/inner-compass-*.md ~/.claude/agents/

# Skills
for skill_dir in "$SCRIPT_DIR"/skills/inner-compass-*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$skill_name"
  cp "$skill_dir"SKILL.md ~/.claude/skills/"$skill_name"/
done

# Config (don't overwrite existing)
mkdir -p ~/.inner-compass/sessions
if [ ! -f ~/.inner-compass/config.md ]; then
  cat > ~/.inner-compass/config.md << 'EOF'
---
sessions_dir: ~/.inner-compass/sessions
obsidian_vault: ~
---
EOF
  echo "Created default config at ~/.inner-compass/config.md"
else
  echo "Config already exists, skipping."
fi

echo ""
echo "✓ Inner Compass installed!"
echo ""
echo "Run /reflect-setup in Claude Code to configure Obsidian vault."
echo "Or just use /reflect to start a session."
