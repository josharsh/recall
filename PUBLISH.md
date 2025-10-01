# 🚀 Publishing Recall - Complete Guide

This document provides step-by-step instructions to publish Recall to GitHub and Homebrew.

## Prerequisites

- GitHub account
- Git configured with SSH keys
- GitHub CLI (`brew install gh`) OR manual GitHub access
- Homebrew installed

## 📦 Part 1: Publish to GitHub

### Step 1: Create GitHub Repository

**Option A: Using GitHub CLI (Recommended)**
```bash
cd /Users/josharsh/Development/zsh-productivity/recall

# Install gh if needed
brew install gh

# Login
gh auth login

# Create repo
gh repo create josharsh/recall --public --source=. --remote=origin --description "Smart command tracking and alias generation for ZSH"

# Push code
git push -u origin main
```

**Option B: Manual via GitHub.com**
1. Go to https://github.com/new
2. Repository name: `recall`
3. Description: "Smart command tracking and alias generation for ZSH"
4. Public
5. Click "Create repository"
6. Then run:
```bash
git remote add origin git@github.com:josharsh/recall.git
git push -u origin main
```

### Step 2: Create Release

```bash
# Tag the release
git tag -a v0.1.0 -m "Release v0.1.0 - Initial stable release"
git push origin v0.1.0

# Create GitHub release (via CLI)
gh release create v0.1.0 \
  --title "v0.1.0 - Initial Release" \
  --notes "🧠 **Recall** - Learn your workflow, optimize your commands

## Features
- ✅ Automatic command tracking per project
- ✅ Smart alias suggestions based on patterns
- ✅ Project-aware context
- ✅ Performance metrics (duration, success rate)
- ✅ SQLite storage - fast and reliable
- ✅ 100% local - privacy first

## Installation

\`\`\`bash
# Oh My Zsh
git clone https://github.com/josharsh/recall \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/recall

# Manual
git clone https://github.com/josharsh/recall ~/.zsh/recall
source ~/.zsh/recall/recall.plugin.zsh
\`\`\`

## Quick Start

\`\`\`bash
recall              # Quick insights
recall suggest      # Get alias recommendations
recall stats        # View statistics
recall help         # Full documentation
\`\`\`

## What's New
- Initial release with full command tracking
- Smart pattern analysis
- Alias generation for npm, git, docker, and more
"
```

**Or create manually:**
1. Go to: https://github.com/josharsh/recall/releases/new
2. Tag: `v0.1.0`
3. Title: `v0.1.0 - Initial Release`
4. Copy description from above
5. Click "Publish release"

### Step 3: Verify Release

```bash
# Check tag exists
git ls-remote --tags origin

# Verify release on GitHub
open https://github.com/josharsh/recall/releases
```

## 🍺 Part 2: Publish to Homebrew

### Step 4: Run Publish Script

```bash
cd /Users/josharsh/Development/zsh-productivity/recall

# Run the automated script
./scripts/publish-homebrew.sh
```

This script will:
- ✅ Check GitHub setup
- ✅ Verify version tag
- ✅ Download release tarball
- ✅ Calculate SHA256
- ✅ Update Formula with correct hash
- ✅ Show next steps

### Step 5: Create Homebrew Tap Repository

```bash
# Create tap repo on GitHub
gh repo create josharsh/homebrew-tap --public --description "Homebrew tap for Recall and other tools"

# Clone it
cd ~/Development
git clone git@github.com:josharsh/homebrew-tap.git
cd homebrew-tap

# Create Formula directory
mkdir -p Formula

# Copy the formula
cp ../zsh-productivity/recall/Formula/recall.rb Formula/

# Initialize README
cat > README.md <<'EOF'
# Homebrew Tap for josharsh

Custom Homebrew tap for my tools.

## Installation

```bash
brew install josharsh/tap/recall
```

## Available Formulas

- **recall** - Smart command tracking and alias generation for ZSH

## Usage

After installation, add to your `~/.zshrc`:

```zsh
source $(brew --prefix)/share/zsh/site-functions/_recall_loader
```

Then restart your terminal.
EOF

# Commit and push
git add .
git commit -m "Add Recall formula v0.1.0"
git push origin main
```

### Step 6: Test Installation

```bash
# Install from your tap
brew install josharsh/tap/recall

# Check installed files
ls -la $(brew --prefix)/share/zsh/site-functions/_recall_loader

# Test the command (won't fully work until sourced in zshrc)
source $(brew --prefix)/share/zsh/site-functions/_recall_loader
recall help

# Uninstall for now (or keep it!)
brew uninstall recall
```

### Step 7: Update README.md

Add Homebrew installation method to README:

```bash
cd /Users/josharsh/Development/zsh-productivity/recall
```

Add this section after line 36 (in Installation section):

```markdown
### Homebrew

```bash
brew install josharsh/tap/recall
```

Add to your `.zshrc`:

```bash
source $(brew --prefix)/share/zsh/site-functions/_recall_loader
```

Reload your shell:

```bash
source ~/.zshrc
```
```

Then commit:

```bash
git add README.md
git commit -m "Add Homebrew installation instructions"
git push origin main
```

## ✅ Verification Checklist

- [ ] GitHub repo created and public
- [ ] Code pushed to main branch
- [ ] Release v0.1.0 created with notes
- [ ] Tarball downloadable from GitHub
- [ ] SHA256 calculated correctly
- [ ] Formula updated with real SHA256
- [ ] Homebrew tap repo created
- [ ] Formula pushed to tap repo
- [ ] Installation tested: `brew install josharsh/tap/recall`
- [ ] Command works: `recall help`
- [ ] README updated with brew instructions

## 🎯 Tell the World!

Once published:

### GitHub
✅ Repository: https://github.com/josharsh/recall
✅ Releases: https://github.com/josharsh/recall/releases

### Homebrew
✅ Tap: https://github.com/josharsh/homebrew-tap
✅ Install: `brew install josharsh/tap/recall`

### Next Steps
- [ ] Submit to awesome-zsh-plugins
- [ ] Post on Reddit r/commandline
- [ ] Post "Show HN" on Hacker News
- [ ] Tweet with demo GIF
- [ ] Write blog post on Dev.to

## 🔄 Updating (Future Releases)

When releasing v0.2.0:

```bash
# 1. Update version in files
# 2. Commit changes
git add .
git commit -m "Bump version to v0.2.0"
git push origin main

# 3. Tag and release
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0
gh release create v0.2.0 --generate-notes

# 4. Run publish script
./scripts/publish-homebrew.sh

# 5. Update tap repo
cd ~/Development/homebrew-tap
cp ../zsh-productivity/recall/Formula/recall.rb Formula/
git add Formula/recall.rb
git commit -m "Update Recall to v0.2.0"
git push origin main
```

## 🆘 Troubleshooting

**"Failed to calculate SHA256"**
- Make sure GitHub release exists
- Check tarball is accessible: https://github.com/josharsh/recall/archive/refs/tags/v0.1.0.tar.gz

**"brew install fails"**
- Run: `brew install --verbose --debug josharsh/tap/recall`
- Check formula syntax: `brew audit --strict recall`

**"Command not found after install"**
- Make sure you sourced the loader in ~/.zshrc
- Check: `ls $(brew --prefix)/share/zsh/site-functions/_recall_loader`

## 📚 Resources

- [Homebrew Tap Documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
