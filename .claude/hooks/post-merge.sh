#!/bin/bash
# Post-merge hook: Reflect on learnings from this session
# Prompts user to add [LEARN] entries to appropriate memory files
# Does NOT auto-append (user maintains control)

echo "=== SESSION MERGED TO MAIN ==="
echo ""
echo "Take a moment to reflect on learnings from this session."
echo ""
echo "Where should learnings go?"
echo ""
echo "  MEMORY.md (committed, synced across machines)"
echo "     Generic patterns applicable to ALL academic workflows"
echo "     Examples: workflow improvements, design principles, documentation patterns"
echo "     Format: [LEARN:category] pattern -> benefit"
echo ""
echo "  .claude/state/personal-memory.md (gitignored, local only)"
echo "     Machine-specific learnings (file paths, tool versions, edge cases)"
echo "     Examples: MikTeX on Windows requires --include-directory flag"
echo "     Stays on this machine, does not clutter template for other users"
echo ""
echo "Consider adding [LEARN] entries if:"
echo "  [ ] You corrected a mistake that might recur"
echo "  [ ] You discovered a pattern applicable to similar projects"
echo "  [ ] You solved a problem through trial and error"
echo "  [ ] You received user feedback on approach or quality"
echo ""
echo "Not every session needs entries---only capture reusable insights."
echo ""

exit 0
