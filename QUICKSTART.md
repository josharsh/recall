# 🚀 Quick Start - Publishing Recall

**TL;DR:** Follow these commands to publish Recall to GitHub and Homebrew in ~5 minutes.

## Prerequisites Check

```bash
# Check git
git --version

# Check gh CLI (install if needed)
gh --version || brew install gh

# Check you're in the right directory
pwd  # Should be: /Users/josharsh/Development/zsh-productivity/recall
```

## 🎯 One-Command Publish (Automated)

```bash
# Login to GitHub if needed
gh auth login

# Create repo, push code, create release
gh repo create josharsh/recall --public --source=. --remote=origin --push

# Tag and release
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0

gh release create v0.1.0 \
  --title "v0.1.0 - Initial Release" \
  --notes "🧠 Recall - Learn your workflow, optimize your commands

Features:
- Automatic command tracking per project
- Smart alias suggestions based on patterns
- Project-aware context
- Performance metrics (duration, success rate)
- SQLite storage - fast and reliable
- 100% local - privacy first

Installation: https://github.com/josharsh/recall#installation"

# Run Homebrew publish script
./scripts/publish-homebrew.sh

# Create tap repo
gh repo create josharsh/homebrew-tap --public --clone --description "Homebrew tap for Recall"

# Setup tap
cd ../homebrew-tap
mkdir -p Formula
cp ../recall/Formula/recall.rb Formula/

cat > README.md <<'EOF'
# Homebrew Tap

```bash
brew install josharsh/tap/recall
```
EOF

git add .
git commit -m "Add Recall formula v0.1.0"
git push origin main

# Test it!
brew install josharsh/tap/recall
recall help
```

## ✅ That's It!

Your plugin is now published:

- **GitHub**: https://github.com/josharsh/recall
- **Homebrew**: `brew install josharsh/tap/recall`

## 📣 Next: Spread the Word

```bash
# Submit to awesome-zsh-plugins
# Go to: https://github.com/unixorn/awesome-zsh-plugins
# Fork, add entry, submit PR

# Post to Reddit
# r/commandline, r/zsh, r/devtools

# Post to Hacker News
# "Show HN: Recall – ZSH plugin that learns your workflow"

# Tweet it
# Demo GIF + link to repo
```

## 🔄 Future Updates

```bash
# For v0.2.0 later:
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0
gh release create v0.2.0 --generate-notes

# Update formula
./scripts/publish-homebrew.sh

# Push to tap
cd ../homebrew-tap
cp ../recall/Formula/recall.rb Formula/
git add Formula/recall.rb
git commit -m "Update Recall to v0.2.0"
git push origin main
```

## 💡 Pro Tips

**Demo GIF:**
Record with: `asciinema rec demo.cast`
Convert with: `agg demo.cast demo.gif`

**Monitor Stats:**
- GitHub stars
- Homebrew installs (no tracking but users will report issues)
- Reddit/HN engagement

**Iterate:**
- Collect user feedback from GitHub issues
- Fix bugs quickly
- Add most-requested features
- Release often (v0.1.1, v0.1.2, etc.)

## 🆘 Troubleshooting

**gh command not found:**
```bash
brew install gh
gh auth login
```

**Permission denied (publickey):**
```bash
# Check SSH keys
ssh -T git@github.com

# Or use HTTPS
git remote set-url origin https://github.com/josharsh/recall.git
```

**Formula installation fails:**
```bash
brew install --verbose --debug josharsh/tap/recall
# Check error message and fix formula
```

---

📖 **Full Guide**: See [PUBLISH.md](./PUBLISH.md) for detailed step-by-step instructions.

🍺 **Homebrew Details**: See [HOMEBREW_SETUP.md](./HOMEBREW_SETUP.md) for Homebrew-specific info.
