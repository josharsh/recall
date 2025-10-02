#!/usr/bin/env zsh
# tracking.zsh - Command tracking logic

# Track a command execution
_recall_track_command() {
  local project_path="$1"
  local command="$2"
  local exit_code="$3"
  local duration="$4"

  # Skip certain commands
  if _recall_should_skip_command "$command"; then
    return
  fi

  # Get or create project
  local project_id=$(_recall_get_project_id "$project_path")

  # Insert command record
  _recall_db_insert_command "$project_id" "$command" "$exit_code" "$duration"
}

# Determine if command should be skipped
_recall_should_skip_command() {
  local command="$1"

  # Skip empty commands
  [[ -z "$command" ]] && return 0

  # Skip builtin navigation and simple commands
  local skip_patterns=(
    "^cd( |$)"
    "^ls( |$)"
    "^pwd$"
    "^exit$"
    "^clear$"
    "^history"
    "^recall"
    "^echo "
    "^cat "
    "^less "
    "^more "
    "^head "
    "^tail "
  )

  for pattern in $skip_patterns; do
    if [[ "$command" =~ $pattern ]]; then
      return 0
    fi
  done

  return 1
}

# Get project root (tries to find git root, falls back to cwd)
_recall_get_project_root() {
  local current_dir="$1"

  # Try to find git root
  if git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null; then
    return
  fi

  # Check for common project markers
  local markers=(
    ".git"
    "package.json"
    "Cargo.toml"
    "go.mod"
    "setup.py"
    "requirements.txt"
    "Makefile"
    "docker-compose.yml"
  )

  local check_dir="$current_dir"
  while [[ "$check_dir" != "/" ]]; do
    for marker in $markers; do
      if [[ -e "$check_dir/$marker" ]]; then
        echo "$check_dir"
        return
      fi
    done
    check_dir="${check_dir:h}"
  done

  # Fall back to current directory
  echo "$current_dir"
}

# Normalize command for better grouping
_recall_normalize_command() {
  local command="$1"

  # Remove leading/trailing whitespace
  command="${command## }"
  command="${command%% }"

  # Normalize multiple spaces to single space
  command="${command//  / }"

  echo "$command"
}