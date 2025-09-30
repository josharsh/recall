#!/usr/bin/env zsh
# project-memory.plugin.zsh
# Smart project-aware command tracking and alias generation for zsh
# Version: 0.1.0

# Plugin directory
PROJMEM_DIR="${0:A:h}"
PROJMEM_DATA_DIR="${PROJMEM_DATA_DIR:-${HOME}/.local/share/project-memory}"
PROJMEM_DB="${PROJMEM_DATA_DIR}/history.db"
PROJMEM_ENABLED="${PROJMEM_ENABLED:-true}"

# Performance settings
PROJMEM_MIN_COMMANDS="${PROJMEM_MIN_COMMANDS:-5}"      # Min command runs before suggesting alias
PROJMEM_LOOKBACK_DAYS="${PROJMEM_LOOKBACK_DAYS:-30}"  # Days to analyze for patterns
PROJMEM_MAX_SUGGESTIONS="${PROJMEM_MAX_SUGGESTIONS:-3}" # Max suggestions per project

# Source library functions
source "${PROJMEM_DIR}/lib/database.zsh"
source "${PROJMEM_DIR}/lib/tracking.zsh"
source "${PROJMEM_DIR}/lib/analysis.zsh"
source "${PROJMEM_DIR}/lib/ui.zsh"

# Initialize database on first load
_projmem_init() {
  [[ "$PROJMEM_ENABLED" != "true" ]] && return

  # Create data directory if needed
  [[ ! -d "$PROJMEM_DATA_DIR" ]] && mkdir -p "$PROJMEM_DATA_DIR"

  # Initialize database
  _projmem_db_init
}

# Hook: Track command execution
_projmem_preexec() {
  [[ "$PROJMEM_ENABLED" != "true" ]] && return

  PROJMEM_CMD_START=$EPOCHREALTIME
  PROJMEM_LAST_CMD="$1"
}

# Hook: Record command after execution
_projmem_precmd() {
  [[ "$PROJMEM_ENABLED" != "true" ]] && return
  [[ -z "$PROJMEM_LAST_CMD" ]] && return

  local exit_code=$?
  local duration=0

  if [[ -n "$PROJMEM_CMD_START" ]]; then
    duration=$(( EPOCHREALTIME - PROJMEM_CMD_START ))
  fi

  # Record command asynchronously to avoid slowdown
  _projmem_track_command "$PWD" "$PROJMEM_LAST_CMD" "$exit_code" "$duration" &!

  unset PROJMEM_LAST_CMD PROJMEM_CMD_START
}

# Hook: Project context change
_projmem_chpwd() {
  [[ "$PROJMEM_ENABLED" != "true" ]] && return

  # Show project insights when entering directory
  _projmem_show_insights "$PWD"
}

# User commands
projmem() {
  case "$1" in
    stats|status)
      _projmem_show_stats "${2:-$PWD}"
      ;;
    suggest)
      _projmem_suggest_aliases "${2:-$PWD}"
      ;;
    top)
      _projmem_show_top_commands "${2:-$PWD}" "${3:-10}"
      ;;
    alias)
      if [[ -n "$2" && -n "$3" ]]; then
        _projmem_create_alias "$PWD" "$2" "$3"
      else
        echo "Usage: projmem alias <name> <command>"
      fi
      ;;
    clean)
      _projmem_clean_old_data "${2:-90}"
      ;;
    export)
      _projmem_export_data "${2:-$PWD}" "${3:-json}"
      ;;
    disable)
      PROJMEM_ENABLED=false
      echo "Project Memory disabled for this session"
      ;;
    enable)
      PROJMEM_ENABLED=true
      echo "Project Memory enabled"
      ;;
    help|--help|-h)
      _projmem_show_help
      ;;
    *)
      _projmem_show_help
      ;;
  esac
}

# Initialize plugin
_projmem_init

# Register hooks using add-zsh-hook for best compatibility
autoload -Uz add-zsh-hook
add-zsh-hook preexec _projmem_preexec
add-zsh-hook precmd _projmem_precmd
add-zsh-hook chpwd _projmem_chpwd