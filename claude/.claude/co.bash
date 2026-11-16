# Orchestrator mode: Opus lead, tiered subagents (~/.claude/agents), hard spawn caps.
co() {
  CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1 \
  CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1 \
  CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS=8 \
  claude --model opus --effort high \
    --append-system-prompt-file ~/.claude/orchestrator.md "$@"
}
