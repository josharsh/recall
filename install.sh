#!/bin/bash
# install.sh - Installation script for Recall

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print with color
print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Header
echo -e "\n${CYAN}╔═══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  🧠  Recall Installer        ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}\n"

# Check requirements
print_info "Checking requirements..."

# Check ZSH
if ! command -v zsh &> /dev/null; then
  print_error "ZSH is not installed. Please install ZSH first."
  exit 1
fi
print_success "ZSH found: $(which zsh)"

# Check SQLite3
if ! command -v sqlite3 &> /dev/null; then
  print_error "sqlite3 is not installed."
  print_info "On macOS: brew install sqlite"
  print_info "On Ubuntu/Debian: sudo apt-get install sqlite3"
  exit 1
fi
print_success "SQLite3 found: $(which sqlite3)"

# Detect installation method
print_info "Detecting ZSH configuration..."

INSTALL_METHOD=""
INSTALL_PATH=""

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  INSTALL_METHOD="oh-my-zsh"
  INSTALL_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/recall"
  print_success "Oh My Zsh detected"
elif [[ -f "$HOME/.zshrc" ]]; then
  INSTALL_METHOD="manual"
  INSTALL_PATH="$HOME/.zsh/recall"
  print_success "ZSH config detected (manual installation)"
else
  print_error "Could not detect ZSH configuration"
  exit 1
fi

# Ask for confirmation
echo
read -p "$(echo -e ${YELLOW}?${NC} Install to $INSTALL_PATH? [Y/n] )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
  print_info "Installation cancelled"
  exit 0
fi

# Create directory
print_info "Installing to $INSTALL_PATH..."

if [[ -d "$INSTALL_PATH" ]]; then
  print_warning "Directory already exists. Backing up..."
  mv "$INSTALL_PATH" "${INSTALL_PATH}.backup.$(date +%s)"
  print_success "Backup created"
fi

mkdir -p "$(dirname "$INSTALL_PATH")"

# Copy files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "$SCRIPT_DIR" == "$INSTALL_PATH" ]]; then
  print_success "Already in the correct location"
else
  cp -r "$SCRIPT_DIR" "$INSTALL_PATH"
  print_success "Files copied"
fi

# Make scripts executable
chmod +x "$INSTALL_PATH"/*.plugin.zsh 2>/dev/null || true
chmod +x "$INSTALL_PATH"/lib/*.zsh 2>/dev/null || true

# Update .zshrc
print_info "Updating .zshrc..."

ZSHRC="$HOME/.zshrc"

if [[ "$INSTALL_METHOD" == "oh-my-zsh" ]]; then
  # Check if plugin is already in .zshrc
  if grep -q "plugins=.*recall" "$ZSHRC"; then
    print_success "Plugin already enabled in .zshrc"
  else
    # Try to add to plugins array
    if grep -q "^plugins=(" "$ZSHRC"; then
      # Backup .zshrc
      cp "$ZSHRC" "${ZSHRC}.backup.$(date +%s)"

      # Add plugin to array
      sed -i.tmp 's/plugins=(/plugins=(recall /' "$ZSHRC"
      rm -f "${ZSHRC}.tmp"
      print_success "Added 'recall' to plugins in .zshrc"
    else
      print_warning "Could not automatically add plugin to .zshrc"
      echo -e "\n${CYAN}Please add 'recall' to your plugins array:${NC}"
      echo -e "${YELLOW}plugins=(... recall)${NC}\n"
    fi
  fi
else
  # Manual installation - add source line
  if grep -q "recall.plugin.zsh" "$ZSHRC"; then
    print_success "Plugin already sourced in .zshrc"
  else
    # Backup .zshrc
    cp "$ZSHRC" "${ZSHRC}.backup.$(date +%s)"

    echo "" >> "$ZSHRC"
    echo "# Recall - Smart command tracking" >> "$ZSHRC"
    echo "source $INSTALL_PATH/recall.plugin.zsh" >> "$ZSHRC"
    print_success "Added source line to .zshrc"
  fi
fi

# Create data directory
DATA_DIR="${RECALL_DATA_DIR:-$HOME/.local/share/recall}"
mkdir -p "$DATA_DIR"
print_success "Data directory created: $DATA_DIR"

# Success message
echo -e "\n${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ✓  Installation Complete!           ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}\n"

print_info "Next steps:"
echo -e "  1. Restart your terminal or run: ${CYAN}source ~/.zshrc${NC}"
echo -e "  2. Start using your terminal normally"
echo -e "  3. After a while, run: ${CYAN}recall suggest${NC}"
echo -e "\n${CYAN}Commands:${NC}"
echo -e "  ${YELLOW}recall${NC}             - Quick project insights"
echo -e "  ${YELLOW}recall stats${NC}       - View project statistics"
echo -e "  ${YELLOW}recall top${NC}         - Show top commands"
echo -e "  ${YELLOW}recall suggest${NC}     - Get alias suggestions"
echo -e "  ${YELLOW}recall help${NC}        - Show all commands"
echo -e "\n${CYAN}Documentation:${NC} https://github.com/josharsh/recall"
echo -e "\nHappy coding! 🚀\n"