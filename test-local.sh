#!/bin/bash
# test-local.sh - Local testing script for Recall

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${BLUE}🧪 Recall - Local Testing${NC}\n"

# Get the plugin directory
PLUGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${YELLOW}Testing from:${NC} $PLUGIN_DIR\n"

# Set test data directory to avoid polluting real data
export RECALL_DATA_DIR="/tmp/recall-test"
export RECALL_MIN_COMMANDS=2
export RECALL_LOOKBACK_DAYS=1

echo -e "${GREEN}✓${NC} Using test data directory: $RECALL_DATA_DIR"

# Clean up previous test data
rm -rf "$RECALL_DATA_DIR"
mkdir -p "$RECALL_DATA_DIR"

echo -e "${GREEN}✓${NC} Test environment prepared\n"

# Instructions
cat <<EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${YELLOW}To test Recall locally:${NC}

1. ${GREEN}Load the plugin in a new shell:${NC}

   ${BLUE}zsh -c "source $PLUGIN_DIR/recall.plugin.zsh; zsh"${NC}

2. ${GREEN}Or test in current shell (temporary):${NC}

   ${BLUE}source $PLUGIN_DIR/recall.plugin.zsh${NC}

3. ${GREEN}Run some test commands:${NC}

   ${BLUE}npm run dev${NC}
   ${BLUE}npm run dev${NC}  (run multiple times)
   ${BLUE}npm test${NC}
   ${BLUE}git status${NC}
   ${BLUE}docker compose up${NC}

4. ${GREEN}Check if tracking works:${NC}

   ${BLUE}recall stats${NC}
   ${BLUE}recall top${NC}
   ${BLUE}recall suggest${NC}

5. ${GREEN}Test alias creation:${NC}

   ${BLUE}recall alias nrd 'npm run dev'${NC}
   ${BLUE}nrd${NC}  (test the alias)

6. ${GREEN}Test database:${NC}

   ${BLUE}sqlite3 $RECALL_DATA_DIR/history.db "SELECT * FROM commands LIMIT 5;"${NC}

7. ${GREEN}Clean up test data:${NC}

   ${BLUE}rm -rf $RECALL_DATA_DIR${NC}

${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Quick Test (automatic):${NC}
Run: ${BLUE}./test-local.sh auto${NC}

EOF

# Auto test mode
if [[ "$1" == "auto" ]]; then
  echo -e "\n${YELLOW}Running automated tests...${NC}\n"

  # Start a test shell session
  zsh <<'ZSHTEST'
    # Source the plugin
    source recall.plugin.zsh

    echo "✓ Plugin loaded"

    # Simulate some commands by manually calling the tracking function
    _recall_track_command "$PWD" "npm run dev" "0" "1.234"
    _recall_track_command "$PWD" "npm run dev" "0" "1.456"
    _recall_track_command "$PWD" "npm run dev" "0" "1.123"
    _recall_track_command "$PWD" "npm test" "0" "2.345"
    _recall_track_command "$PWD" "npm test" "0" "2.567"
    _recall_track_command "$PWD" "git status" "0" "0.123"
    _recall_track_command "$PWD" "docker compose up -d" "0" "3.456"

    # Wait for async writes
    sleep 1

    echo "✓ Commands tracked"
    echo ""

    # Test stats
    echo "━━━ Testing: recall stats ━━━"
    recall stats

    echo ""
    echo "━━━ Testing: recall top ━━━"
    recall top

    echo ""
    echo "━━━ Testing: recall suggest ━━━"
    recall suggest

    echo ""
    echo "━━━ Testing: Database query ━━━"
    sqlite3 "$RECALL_DATA_DIR/history.db" "SELECT command, COUNT(*) as count FROM commands GROUP BY command;"

    echo ""
    echo "✅ All tests completed!"
ZSHTEST

  echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ Automated tests complete!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
fi