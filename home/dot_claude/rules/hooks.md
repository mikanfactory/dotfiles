# Hooks Configuration

## Hook Types

| Type | Timing | Use Case |
|------|--------|----------|
| PreToolUse | Before tool execution | Validation, parameter modification |
| PostToolUse | After tool execution | Auto-format, checks |
| Stop | When session ends | Final verification, notifications |
| Notification | On events | Alerts, logging |

## Current Hooks (settings.json)

### Stop Hook
macOS notification with Glass sound when Claude Code stops:
```json
{
  "Stop": [{
    "hooks": [{
      "type": "command",
      "command": "osascript -e 'display notification \"Invoke Stop event.\" with title \"Claude Code\" sound name \"Glass\"'"
    }]
  }]
}
```

### Notification Hook
Desktop notification for events (same as Stop).

## Permission Configuration

### Allowed (Auto-approve)
- `Bash` - Shell commands
- `Read` - File reading
- `Edit` - File editing
- `Skill` - Skill invocation
- `MultiEdit` - Multiple file edits
- `WebSearch` - Web searches
- `WebFetch` - URL fetching
- `Search(*)` - Code search

### Denied (Always block)
- `Read(.env)` - Prevent reading secrets
- `Bash(terraform:*)` - Prevent accidental terraform commands
- `Bash(git push origin main)` - Prevent direct push to main

### Ask (Confirm before)
- `Bash(rm:*)` - Confirm before deletions

## Best Practices

### Auto-Accept
Only enable for trusted, well-defined operations:
- Formatting tools
- Linting
- Test running

### Avoid
- `dangerously-skip-permissions` flag
- Blanket auto-accept for destructive operations

### Recommended Approach
Configure specific permissions in `settings.json` `allowedTools` rather than using flags.
