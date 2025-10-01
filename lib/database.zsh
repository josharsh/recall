#!/usr/bin/env zsh
# database.zsh - SQLite database operations for recall

# Initialize database schema
_recall_db_init() {
  # Check if sqlite3 is available
  if ! command -v sqlite3 &> /dev/null; then
    echo "Warning: sqlite3 not found. Recall requires sqlite3."
    return 1
  fi

  # Create schema if not exists
  sqlite3 "$RECALL_DB" <<EOF
CREATE TABLE IF NOT EXISTS projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  first_seen INTEGER NOT NULL,
  last_seen INTEGER NOT NULL,
  total_commands INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS commands (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL,
  command TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  exit_code INTEGER,
  duration REAL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS aliases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL,
  alias_name TEXT NOT NULL,
  command TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  UNIQUE(project_id, alias_name),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_commands_project_id ON commands(project_id);
CREATE INDEX IF NOT EXISTS idx_commands_timestamp ON commands(timestamp);
CREATE INDEX IF NOT EXISTS idx_commands_command ON commands(command);
CREATE INDEX IF NOT EXISTS idx_projects_path ON projects(path);
EOF
}

# Get or create project ID for a given path
_recall_get_project_id() {
  local project_path="$1"
  local project_name="${project_path:t}"  # Get basename
  local timestamp=$(date +%s)

  sqlite3 "$RECALL_DB" <<EOF
INSERT INTO projects (path, name, first_seen, last_seen, total_commands)
VALUES ('$project_path', '$project_name', $timestamp, $timestamp, 0)
ON CONFLICT(path) DO UPDATE SET
  last_seen = $timestamp,
  total_commands = total_commands + 1;

SELECT id FROM projects WHERE path = '$project_path';
EOF
}

# Insert command record
_recall_db_insert_command() {
  local project_id="$1"
  local command="$2"
  local exit_code="$3"
  local duration="$4"
  local timestamp=$(date +%s)

  # Escape single quotes for SQL
  command="${command//\'/\'\'}"

  sqlite3 "$RECALL_DB" <<EOF
INSERT INTO commands (project_id, command, timestamp, exit_code, duration)
VALUES ($project_id, '$command', $timestamp, $exit_code, $duration);
EOF
}

# Get top commands for a project
_recall_db_get_top_commands() {
  local project_path="$1"
  local limit="${2:-10}"
  local days="${3:-30}"
  local cutoff=$(( $(date +%s) - (days * 86400) ))

  sqlite3 -separator $'\t' "$RECALL_DB" <<EOF
SELECT
  c.command,
  COUNT(*) as count,
  AVG(c.duration) as avg_duration,
  SUM(CASE WHEN c.exit_code = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as success_rate
FROM commands c
JOIN projects p ON c.project_id = p.id
WHERE p.path = '$project_path'
  AND c.timestamp > $cutoff
GROUP BY c.command
ORDER BY count DESC
LIMIT $limit;
EOF
}

# Get project statistics
_recall_db_get_project_stats() {
  local project_path="$1"

  sqlite3 -separator $'\t' "$RECALL_DB" <<EOF
SELECT
  p.name,
  p.total_commands,
  datetime(p.first_seen, 'unixepoch', 'localtime') as first_seen,
  datetime(p.last_seen, 'unixepoch', 'localtime') as last_seen,
  COUNT(DISTINCT DATE(c.timestamp, 'unixepoch')) as active_days
FROM projects p
LEFT JOIN commands c ON p.id = c.project_id
WHERE p.path = '$project_path'
GROUP BY p.id;
EOF
}

# Clean old command data
_recall_db_clean_old_data() {
  local days="${1:-90}"
  local cutoff=$(( $(date +%s) - (days * 86400) ))

  sqlite3 "$RECALL_DB" <<EOF
DELETE FROM commands WHERE timestamp < $cutoff;
VACUUM;
EOF
}

# Create or update alias
_recall_db_upsert_alias() {
  local project_id="$1"
  local alias_name="$2"
  local command="$3"
  local timestamp=$(date +%s)

  # Escape single quotes
  command="${command//\'/\'\'}"

  sqlite3 "$RECALL_DB" <<EOF
INSERT INTO aliases (project_id, alias_name, command, usage_count, created_at)
VALUES ($project_id, '$alias_name', '$command', 0, $timestamp)
ON CONFLICT(project_id, alias_name) DO UPDATE SET
  command = '$command',
  usage_count = usage_count + 1;
EOF
}

# Get aliases for a project
_recall_db_get_aliases() {
  local project_path="$1"

  sqlite3 -separator $'\t' "$RECALL_DB" <<EOF
SELECT a.alias_name, a.command, a.usage_count
FROM aliases a
JOIN projects p ON a.project_id = p.id
WHERE p.path = '$project_path'
ORDER BY a.usage_count DESC;
EOF
}