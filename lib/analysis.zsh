#!/usr/bin/env zsh
# analysis.zsh - Command pattern analysis and suggestions

# Analyze command patterns and suggest aliases
_recall_suggest_aliases() {
  local project_path="$1"
  local min_count="${RECALL_MIN_COMMANDS:-5}"

  local suggestions=$(_recall_db_get_top_commands "$project_path" 20 "$RECALL_LOOKBACK_DAYS")

  if [[ -z "$suggestions" ]]; then
    echo "Not enough command history to generate suggestions."
    return
  fi

  echo "\n📊 Alias Suggestions for $(basename "$project_path"):\n"

  local count=0
  while IFS=$'\t' read -r command freq avg_duration success_rate; do
    # Only suggest if used frequently enough
    if (( freq < min_count )); then
      continue
    fi

    # Skip if already short
    if (( ${#command} < 10 )); then
      continue
    fi

    # Generate alias suggestion
    local suggested_alias=$(_recall_generate_alias_name "$command")

    if [[ -n "$suggested_alias" ]]; then
      printf "  \033[1;36m%-15s\033[0m → %s\n" "$suggested_alias" "$command"
      printf "    Used %d times | Avg: %.2fs | Success: %.0f%%\n\n" "$freq" "$avg_duration" "$success_rate"

      count=$((count + 1))
      if (( count >= RECALL_MAX_SUGGESTIONS )); then
        break
      fi
    fi
  done <<< "$suggestions"

  if (( count == 0 )); then
    echo "  No suitable commands found for aliasing."
  else
    echo "💡 Create alias: recall alias <name> '<command>'"
  fi
}

# Generate a sensible alias name from a command
_recall_generate_alias_name() {
  local command="$1"

  # Extract base command
  local base_cmd="${command%% *}"

  # Special patterns
  case "$command" in
    npm\ run\ *)
      local script="${command#npm run }"
      echo "nr${script:0:1}"
      ;;
    npm\ *)
      local action="${command#npm }"
      action="${action%% *}"
      echo "n${action:0:1}"
      ;;
    git\ *)
      local action="${command#git }"
      action="${action%% *}"
      echo "g${action:0:2}"
      ;;
    docker\ compose\ *)
      local action="${command#docker compose }"
      action="${action%% *}"
      echo "dc${action:0:1}"
      ;;
    docker\ *)
      local action="${command#docker }"
      action="${action%% *}"
      echo "d${action:0:2}"
      ;;
    yarn\ *)
      local action="${command#yarn }"
      action="${action%% *}"
      echo "y${action:0:1}"
      ;;
    cargo\ *)
      local action="${command#cargo }"
      action="${action%% *}"
      echo "c${action:0:1}"
      ;;
    make\ *)
      local target="${command#make }"
      target="${target%% *}"
      echo "m${target:0:2}"
      ;;
    *)
      # Generic: first letter of each word
      local words=(${(s: :)command})
      if (( ${#words} > 1 )); then
        local alias=""
        for word in ${words[1,3]}; do
          alias="${alias}${word:0:1}"
        done
        echo "$alias"
      fi
      ;;
  esac
}

# Create a project-specific alias
_recall_create_alias() {
  local project_path="$1"
  local alias_name="$2"
  local command="$3"

  # Get project ID
  local project_id=$(_recall_get_project_id "$project_path")

  # Store in database
  _recall_db_upsert_alias "$project_id" "$alias_name" "$command"

  # Create actual alias in current shell
  alias "$alias_name"="$command"

  echo "✅ Alias created: $alias_name → $command"
  echo "💡 Add to your .zshrc to make it permanent"
}

# Show insights when entering a project
_recall_show_insights() {
  local project_path="$1"

  # Only show insights if we have enough data
  local stats=$(_recall_db_get_project_stats "$project_path")

  if [[ -z "$stats" ]]; then
    return
  fi

  IFS=$'\t' read -r name total_commands first_seen last_seen active_days <<< "$stats"

  # Only show if project has significant history
  if (( total_commands < 10 )); then
    return
  fi

  # Check if we have aliases for this project
  local aliases=$(_recall_db_get_aliases "$project_path")

  if [[ -n "$aliases" ]]; then
    echo "\n💡 Project aliases available:"
    while IFS=$'\t' read -r alias_name command usage_count; do
      printf "   \033[1;32m%-12s\033[0m → %s\n" "$alias_name" "$command"
    done <<< "$aliases"
    echo
  fi
}

# Show top commands for current project
_recall_show_top_commands() {
  local project_path="$1"
  local limit="${2:-10}"

  local commands=$(_recall_db_get_top_commands "$project_path" "$limit" "$RECALL_LOOKBACK_DAYS")

  if [[ -z "$commands" ]]; then
    echo "No command history for this project yet."
    return
  fi

  echo "\n🔥 Top $limit Commands in $(basename "$project_path"):\n"

  local rank=1
  while IFS=$'\t' read -r command count avg_duration success_rate; do
    printf "%2d. %-50s ×%d\n" "$rank" "$command" "$count"
    printf "    Avg: %.2fs | Success: %.0f%%\n" "$avg_duration" "$success_rate"
    rank=$((rank + 1))
  done <<< "$commands"

  echo
}