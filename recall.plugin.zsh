#!/usr/bin/env zsh
# recall.plugin.zsh
# Smart command tracking and alias generation for zsh
# Learn your workflow, optimize your commands
# Version: 0.1.0

# Plugin directory
RECALL_DIR="${0:A:h}"
RECALL_DATA_DIR="${RECALL_DATA_DIR:-${HOME}/.local/share/recall}"
RECALL_DB="${RECALL_DATA_DIR}/history.db"
RECALL_ENABLED="${RECALL_ENABLED:-true}"

# Performance settings
RECALL_MIN_COMMANDS="${RECALL_MIN_COMMANDS:-5}"      # Min command runs before suggesting alias
RECALL_LOOKBACK_DAYS="${RECALL_LOOKBACK_DAYS:-30}"  # Days to analyze for patterns
RECALL_MAX_SUGGESTIONS="${RECALL_MAX_SUGGESTIONS:-3}" # Max suggestions per project

# Source library functions
source "${RECALL_DIR}/lib/database.zsh"
source "${RECALL_DIR}/lib/tracking.zsh"
source "${RECALL_DIR}/lib/analysis.zsh"
source "${RECALL_DIR}/lib/ui.zsh"

# Initialize database on first load
_recall_init() {
  [[ "$RECALL_ENABLED" != "true" ]] && return

  # Create data directory if needed
  [[ ! -d "$RECALL_DATA_DIR" ]] && mkdir -p "$RECALL_DATA_DIR"

  # Initialize database
  _recall_db_init
}

# Hook: Track command execution
_recall_preexec() {
  [[ "$RECALL_ENABLED" != "true" ]] && return

  RECALL_CMD_START=$EPOCHREALTIME
  RECALL_LAST_CMD="$1"
}

# Hook: Record command after execution
_recall_precmd() {
  [[ "$RECALL_ENABLED" != "true" ]] && return
  [[ -z "$RECALL_LAST_CMD" ]] && return

  local exit_code=$?
  local duration=0

  if [[ -n "$RECALL_CMD_START" ]]; then
    duration=$(( EPOCHREALTIME - RECALL_CMD_START ))
  fi

  # Record command asynchronously to avoid slowdown
  _recall_track_command "$PWD" "$RECALL_LAST_CMD" "$exit_code" "$duration" &!

  unset RECALL_LAST_CMD RECALL_CMD_START
}

# Hook: Project context change
_recall_chpwd() {
  [[ "$RECALL_ENABLED" != "true" ]] && return

  # Show project insights when entering directory
  _recall_show_insights "$PWD"
}

# User commands
recall() {
  case "$1" in
    stats|status)
      _recall_show_stats "${2:-$PWD}"
      ;;
    suggest|learn)
      _recall_suggest_aliases "${2:-$PWD}"
      ;;
    top)
      _recall_show_top_commands "${2:-$PWD}" "${3:-10}"
      ;;
    alias)
      if [[ -n "$2" && -n "$3" ]]; then
        _recall_create_alias "$PWD" "$2" "$3"
      else
        echo "Usage: recall alias <name> <command>"
      fi
      ;;
    clean)
      _recall_clean_old_data "${2:-90}"
      ;;
    export)
      _recall_export_data "${2:-$PWD}" "${3:-json}"
      ;;
    disable)
      RECALL_ENABLED=false
      echo "Recall disabled for this session"
      ;;
    enable)
      RECALL_ENABLED=true
      echo "Recall enabled"
      ;;
    help|--help|-h)
      _recall_show_help
      ;;
    "")
      _recall_show_quick_insights
      ;;
    *)
      _recall_show_help
      ;;
  esac
}

# Initialize plugin
_recall_init

# Register hooks using add-zsh-hook for best compatibility
autoload -Uz add-zsh-hook
add-zsh-hook preexec _recall_preexec
add-zsh-hook precmd _recall_precmd
add-zsh-hook chpwd _recall_chpwd