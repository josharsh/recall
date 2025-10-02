# 🧠 Recall

> Smart command tracking and alias generation for ZSH - Learn your habits, optimize your workflow

Recall is a ZSH plugin that automatically tracks the commands you run in each project and suggests intelligent aliases based on your usage patterns. Think of it as "autocomplete for your workflow" - it learns what you do and helps you do it faster.

## ✨ Features

- 📊 **Automatic Command Tracking** - Records every command you run, per-project
- 🎯 **Smart Alias Suggestions** - Analyzes patterns and suggests time-saving aliases
- 🚀 **Project-Aware Context** - Shows relevant shortcuts when you `cd` into directories
- ⚡ **Performance Metrics** - Tracks execution time, success rate, and usage frequency
- 💾 **SQLite Storage** - Fast, reliable, zero-dependency storage
- 🔒 **Privacy-First** - All data stays local on your machine

## 🎬 Demo

```bash
# After using "npm run dev" 50 times...
$ recall suggest

📊 Alias Suggestions for my-app:

  nrd             → npm run dev
    Used 50 times | Avg: 0.21s | Success: 100%

  nt              → npm test
    Used 23 times | Avg: 2.45s | Success: 95%

💡 Create alias: recall alias <name> '<command>'

$ recall alias nrd 'npm run dev'
✅ Alias created: nrd → npm run dev
```

## 📦 Installation

### Oh My Zsh (Recommended)

```bash
git clone https://github.com/josharsh/recall ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/recall
```

Add to your `.zshrc`:

```bash
plugins=(... recall)
```

Reload your shell:

```bash
source ~/.zshrc
```

### Manual Installation

```bash
git clone https://github.com/josharsh/recall ~/.zsh/recall
```

Add to your `.zshrc`:

```bash
source ~/.zsh/recall/recall.plugin.zsh
```

## 🚀 Usage

Recall works automatically once installed - just use your terminal normally!

### Commands

```bash
# Show project statistics
recall stats

# View top commands
recall top [limit]

# Get alias suggestions
recall suggest

# Create an alias
recall alias <name> '<command>'

# Clean old data
recall clean [days]

# Export data
recall export [format]  # json or csv

# Disable/enable tracking
recall disable
recall enable
```

### Examples

```bash
# See what commands you run most in this project
recall top 20

# Get suggestions based on your patterns
recall suggest

# Create a shortcut
recall alias gcm 'git commit -m'

# View project stats
recall stats

# Clean data older than 30 days
recall clean 30
```

## ⚙️ Configuration

Add these to your `.zshrc` **before** the plugin loads:

```bash
# Where to store data (default: ~/.local/share/recall)
export RECALL_DATA_DIR="$HOME/.recall"

# Minimum command runs before suggesting alias (default: 5)
export RECALL_MIN_COMMANDS=10

# Days to look back for analysis (default: 30)
export RECALL_LOOKBACK_DAYS=60

# Max suggestions to show (default: 3)
export RECALL_MAX_SUGGESTIONS=5

# Enable/disable tracking (default: true)
export RECALL_ENABLED=true
```

## 🎯 How It Works

1. **Tracking**: Uses ZSH hooks (`preexec`, `precmd`, `chpwd`) to capture commands
2. **Storage**: Saves to SQLite with project context, timestamps, exit codes, duration
3. **Analysis**: Analyzes patterns - frequency, command length, success rate
4. **Suggestions**: Generates smart alias names based on common patterns (npm run dev → nrd)
5. **Context**: Shows relevant aliases when you enter a project directory

### What Gets Tracked?

- Full command text
- Project/directory context
- Execution timestamp
- Exit code (success/failure)
- Duration (how long it took)

### What Gets Skipped?

Simple navigation commands are ignored to avoid noise:
- `cd`, `ls`, `pwd`
- `clear`, `exit`, `history`
- File viewers (`cat`, `less`, `more`)

## 🧪 Smart Alias Generation

Recall recognizes common patterns:

| Pattern | Example | Generated Alias |
|---------|---------|-----------------|
| npm run | `npm run dev` | `nrd` |
| npm | `npm install` | `ni` |
| git | `git status` | `gst` |
| docker compose | `docker compose up` | `dcu` |
| docker | `docker ps` | `dps` |
| make | `make build` | `mbu` |
| cargo | `cargo test` | `ct` |

## 🔧 Requirements

- ZSH shell
- SQLite3 (pre-installed on macOS)
- Oh My Zsh (optional but recommended)

## 📊 Privacy & Data

- **100% Local** - All data stays on your machine
- **No Network Calls** - Zero telemetry, zero tracking
- **SQLite Database** - Located at `~/.local/share/recall/history.db`
- **Easy Export** - Export your data anytime with `recall export`
- **Easy Cleanup** - Delete old data with `recall clean`

## 🤝 Contributing

Contributions welcome! Check out the [issues](https://github.com/josharsh/recall/issues) or submit a PR.

## 📝 License

MIT License - see [LICENSE](LICENSE) for details

## 🙏 Inspiration

Inspired by:
- [Atuin](https://github.com/atuinsh/atuin) - Shell history in SQLite
- [zsh-histdb](https://github.com/larkery/zsh-histdb) - Better zsh history
- [Warp](https://www.warp.dev/) - Modern terminal workflows

## 🐛 Troubleshooting

### Plugin not loading?

```bash
# Check if sqlite3 is available
which sqlite3

# Verify plugin is in the right directory
ls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/recall

# Check .zshrc has plugin enabled
cat ~/.zshrc | grep "plugins="
```

### Commands not being tracked?

```bash
# Check if enabled
echo $RECALL_ENABLED

# Test database
sqlite3 ~/.local/share/recall/history.db "SELECT COUNT(*) FROM commands;"
```

### Performance issues?

```bash
# Clean old data
recall clean 30

# Disable if needed
recall disable
```

---

**Made with 🧠 by [Harsh](https://github.com/josharsh)**

*Like this? Give it a ⭐ on GitHub!*