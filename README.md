# 🧠 Recall

**Learn your workflow, optimize your commands**

Recall automatically tracks the commands you run in each project and suggests intelligent aliases based on your usage patterns. Stop typing the same long commands - let Recall learn your habits and speed up your workflow.

## ✨ Why Recall?

- 🎯 **Zero configuration** - Works automatically after installation
- 📊 **Smart suggestions** - Analyzes patterns and recommends time-saving aliases
- 🚀 **Project-aware** - Tracks commands per project/directory
- ⚡ **Fast & lightweight** - Async tracking, no terminal slowdown
- 🔒 **Privacy-first** - All data stays local on your machine
- 💾 **SQLite powered** - Fast, reliable, zero-dependency storage

## 🎬 See It In Action

```bash
# After you've used "npm run dev" a few times...
$ recall suggest

📊 Alias Suggestions for my-app:

  nrd             → npm run dev
    Used 50 times | Avg: 0.21s | Success: 100%

  nt              → npm test
    Used 23 times | Avg: 2.45s | Success: 95%

# Create the alias
$ recall alias nrd 'npm run dev'
✅ Alias created: nrd → npm run dev

# Now just type:
$ nrd
```

## 📦 Installation

### Homebrew (Easiest)

```bash
brew install josharsh/tap/recall
```

Add to your `~/.zshrc`:
```bash
source $(brew --prefix)/share/zsh/site-functions/_recall_loader
```

### Oh My Zsh

```bash
git clone https://github.com/josharsh/recall ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/recall
```

Add to your `~/.zshrc`:
```bash
plugins=(... recall)
```

### Manual

```bash
git clone https://github.com/josharsh/recall ~/.zsh/recall
```

Add to your `~/.zshrc`:
```bash
source ~/.zsh/recall/recall.plugin.zsh
```

**Then reload your shell:**
```bash
source ~/.zshrc
```

## 🚀 Quick Start

Recall works automatically - just use your terminal as normal!

```bash
recall              # Show quick insights for current project
recall suggest      # Get alias recommendations
recall stats        # View detailed statistics
recall top 20       # Show your top 20 commands
recall help         # See all commands
```

### Create Aliases

```bash
# Recall suggests, you decide
recall suggest

# Create an alias
recall alias nrd 'npm run dev'
recall alias gcm 'git commit -m'
recall alias dcu 'docker compose up'

# Use them immediately
nrd
```

## 🧠 How It Works

Recall uses ZSH hooks to track every command you run:

1. **Tracks** - Captures command, timestamp, duration, exit code
2. **Stores** - Saves to local SQLite database per project
3. **Analyzes** - Finds patterns in your most-used commands
4. **Suggests** - Recommends smart, short aliases
5. **Learns** - Gets smarter as you work

**What gets tracked?** Everything except simple navigation (`cd`, `ls`, `pwd`)

**Where's the data?** `~/.local/share/recall/history.db` (100% local, private)

## 🎯 Smart Alias Suggestions

Recall recognizes common patterns and suggests intuitive aliases:

| Command | Suggested Alias | Pattern |
|---------|----------------|---------|
| `npm run dev` | `nrd` | npm run → nr + first letter |
| `git commit -m` | `gcm` | git → g + command initials |
| `docker compose up` | `dcu` | docker compose → dc + command |
| `npm install` | `ni` | npm → n + command initial |
| `cargo test` | `ct` | cargo → c + command initial |

## ⚙️ Configuration (Optional)

Customize behavior in your `~/.zshrc`:

```bash
export RECALL_MIN_COMMANDS=3       # Suggest after 3 uses (default: 5)
export RECALL_LOOKBACK_DAYS=60     # Analyze last 60 days (default: 30)
export RECALL_MAX_SUGGESTIONS=5    # Show 5 suggestions (default: 3)
```

## 🔧 Requirements

- ZSH shell
- SQLite3 (pre-installed on macOS, Linux)

## 📊 Privacy & Security

- ✅ **100% local** - All data stays on your machine
- ✅ **No telemetry** - Zero network calls, zero tracking
- ✅ **Transparent** - SQLite database at `~/.local/share/recall/history.db`
- ✅ **Your control** - Export, clean, or delete anytime

## 🐛 Troubleshooting

**Not tracking commands?**
```bash
echo $RECALL_ENABLED  # Should show "true"
```

**Want to check the database?**
```bash
sqlite3 ~/.local/share/recall/history.db "SELECT COUNT(*) FROM commands;"
```

**Need to clean up old data?**
```bash
recall clean 30  # Remove data older than 30 days
```

## 🤝 Contributing

Contributions welcome! Please check [CONTRIBUTING.md](CONTRIBUTING.md) or open an [issue](https://github.com/josharsh/recall/issues).

## 📝 License

MIT - see [LICENSE](LICENSE)

## 🙏 Credits

Inspired by [Atuin](https://github.com/atuinsh/atuin), [zsh-histdb](https://github.com/larkery/zsh-histdb), and [Warp](https://www.warp.dev/)

---

**Made with 🧠 by [Harsh](https://github.com/josharsh)** • [⭐ Star on GitHub](https://github.com/josharsh/recall)