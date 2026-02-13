#!/bin/bash
# Windows desktop notification when Claude needs attention
# Triggers on: permission prompts, idle prompts, auth events
# Uses PowerShell toast notification (callable from Git Bash)
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs attention"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
powershell.exe -NoProfile -Command "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$MESSAGE','$TITLE','OK','Information')" 2>/dev/null &
exit 0
