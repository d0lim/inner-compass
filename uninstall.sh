#!/bin/bash
set -e

echo "Uninstalling Inner Compass..."

# Commands
rm -f ~/.claude/commands/reflect.md
rm -f ~/.claude/commands/reflect-quick.md
rm -f ~/.claude/commands/reflect-deep.md
rm -f ~/.claude/commands/reflect-review.md
rm -f ~/.claude/commands/reflect-setup.md

# Agents
rm -f ~/.claude/agents/inner-compass-collector.md
rm -f ~/.claude/agents/inner-compass-socratic.md
rm -f ~/.claude/agents/inner-compass-crystallizer.md
rm -f ~/.claude/agents/inner-compass-retrospective.md

# Skills
rm -rf ~/.claude/skills/inner-compass-pattern-detect
rm -rf ~/.claude/skills/inner-compass-ontological-analysis
rm -rf ~/.claude/skills/inner-compass-obsidian-export

echo ""
echo "✓ Inner Compass uninstalled."
echo ""
echo "Session data at ~/.inner-compass/ was preserved."
echo "To remove it too: rm -rf ~/.inner-compass/"
