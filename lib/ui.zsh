#!/usr/bin/env zsh
# ui.zsh - User interface and display functions

# Show project statistics
_projmem_show_stats() {
  local project_path="$1"

  local stats=$(_projmem_db_get_project_stats "$project_path")

  if [[ -z "$stats" ]]; then
    echo "No data for this project yet."
    return
  fi

  IFS=$'\t' read -r name total_commands first_seen last_seen active_days <<< "$stats"

  echo "\n📈 Project Memory Stats: $name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "Total Commands:    %d\n" "$total_commands"
  printf "Active Days:       %d\n" "$active_days"
  printf "First Seen:        %s\n" "$first_seen"
  printf "Last Activity:     %s\n" "$last_seen"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Show top 5 commands
  echo "\n🔥 Top Commands (last $PROJMEM_LOOKBACK_DAYS days):\n"
  local commands=$(_projmem_db_get_top_commands "$project_path" 5 "$PROJMEM_LOOKBACK_DAYS")

  if [[ -n "$commands" ]]; then
    local rank=1
    while IFS=$'\t' read -r command count avg_duration success_rate; do
      printf "%d. %-40s ×%d\n" "$rank" "$command" "$count"
      rank=$((rank + 1))
    done <<< "$commands"
  fi

  # Show aliases
  local aliases=$(_projmem_db_get_aliases "$project_path")

  if [[ -n "$aliases" ]]; then
    echo "\n💡 Active Aliases:\n"
    while IFS=$'\t' read -r alias_name command usage_count; do
      printf "   \033[1;32m%-12s\033[0m → %s\n" "$alias_name" "$command"
    done <<< "$aliases"
  fi

  echo
}

# Show help message
_projmem_show_help() {
  cat <<'EOF'

Project Memory - Smart command tracking and alias generation

USAGE:
  projmem <command> [options]

COMMANDS:
  stats [path]              Show statistics for current or specified project
  top [path] [limit]        Show top commands (default: 10)
  suggest [path]            Suggest aliases based on command patterns
  alias <name> <command>    Create a project-specific alias
  clean [days]              Remove command data older than N days (default: 90)
  export [path] [format]    Export project data (json/csv)
  enable                    Enable tracking for this session
  disable                   Disable tracking for this session
  help                      Show this help message

EXAMPLES:
  projmem stats             # Show stats for current project
  projmem top 20            # Show top 20 commands
  projmem suggest           # Get alias suggestions
  projmem alias dev "npm run dev"
  projmem clean 30          # Clean data older than 30 days

CONFIGURATION:
  Set these in your .zshrc before loading the plugin:

  PROJMEM_DATA_DIR          Data directory (default: ~/.local/share/project-memory)
  PROJMEM_MIN_COMMANDS      Min runs before suggesting alias (default: 5)
  PROJMEM_LOOKBACK_DAYS     Days to analyze (default: 30)
  PROJMEM_MAX_SUGGESTIONS   Max suggestions to show (default: 3)
  PROJMEM_ENABLED           Enable/disable tracking (default: true)

FEATURES:
  • Automatic command tracking per project
  • Smart alias suggestions based on usage patterns
  • Project-aware context on directory change
  • Performance metrics (duration, success rate)
  • SQLite storage for fast queries

EOF
}

# Export project data
_projmem_export_data() {
  local project_path="$1"
  local format="${2:-json}"

  local output_file="${project_path:t}_commands.${format}"

  case "$format" in
    json)
      sqlite3 "$PROJMEM_DB" <<EOF > "$output_file"
.mode json
SELECT c.command, c.timestamp, c.exit_code, c.duration
FROM commands c
JOIN projects p ON c.project_id = p.id
WHERE p.path = '$project_path'
ORDER BY c.timestamp DESC;
EOF
      ;;
    csv)
      sqlite3 "$PROJMEM_DB" <<EOF > "$output_file"
.mode csv
.headers on
SELECT c.command, c.timestamp, c.exit_code, c.duration
FROM commands c
JOIN projects p ON c.project_id = p.id
WHERE p.path = '$project_path'
ORDER BY c.timestamp DESC;
EOF
      ;;
    *)
      echo "Unsupported format: $format (use json or csv)"
      return 1
      ;;
  esac

  echo "✅ Exported to: $output_file"
}

# Clean old data
_projmem_clean_old_data() {
  local days="${1:-90}"

  echo "Cleaning command data older than $days days..."
  _projmem_db_clean_old_data "$days"
  echo "✅ Done"
}