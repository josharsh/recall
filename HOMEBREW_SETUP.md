# Homebrew Publishing Guide for Recall

This guide walks you through publishing Recall to Homebrew via a custom tap.

## Step 1: Create Main GitHub Repository

```bash
# Create the main recall repo (if not exists)
# You'll need to do this manually on GitHub or via gh CLI
# Repository: https://github.com/josharsh/recall

# Push code
git remote add origin git@github.com:josharsh/recall.git
git push -u origin main

# Create release tag
git tag -a v0.1.0 -m "Initial release - Recall ZSH plugin"
git push origin v0.1.0

# Create GitHub release
# Go to: https://github.com/josharsh/recall/releases/new
# Tag: v0.1.0
# Title: v0.1.0 - Initial Release
# Description: First stable release of Recall
```

## Step 2: Get Release Tarball SHA256

```bash
# After creating the release, get the tarball SHA
curl -sL https://github.com/josharsh/recall/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
```

Save this SHA256 hash - you'll need it for the formula!

## Step 3: Create Homebrew Tap Repository

```bash
# Create a new repo on GitHub: homebrew-tap
# Repository: https://github.com/josharsh/homebrew-tap

# Clone it locally
cd ~/Development
git clone git@github.com:josharsh/homebrew-tap.git
cd homebrew-tap

# Create Formula directory
mkdir -p Formula
```

## Step 4: Create the Formula

Create `Formula/recall.rb`:

```ruby
class Recall < Formula
  desc "Smart command tracking and alias generation for ZSH"
  homepage "https://github.com/josharsh/recall"
  url "https://github.com/josharsh/recall/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "YOUR_SHA256_HERE"  # From Step 2
  license "MIT"
  version "0.1.0"

  depends_on "zsh"

  def install
    # Install plugin files
    (share/"zsh/site-functions").mkpath
    prefix.install Dir["*"]

    # Create symlink for easy sourcing
    (share/"zsh/site-functions/recall").write <<~EOS
      # Recall plugin loader
      source #{prefix}/recall.plugin.zsh
    EOS
  end

  def caveats
    <<~EOS
      To use Recall, add the following to your ~/.zshrc:

        # For Oh My Zsh users, add to plugins array:
        plugins=(... recall)

        # For manual installation:
        source #{opt_prefix}/recall.plugin.zsh

      Then restart your terminal or run:
        source ~/.zshrc

      Quick start:
        recall              # Show project insights
        recall suggest      # Get alias suggestions
        recall help         # Full help
    EOS
  end

  test do
    assert_match "Recall - Learn your workflow", shell_output("#{opt_prefix}/recall.plugin.zsh --help")
  end
end
```

## Step 5: Test Formula Locally

```bash
# Install from local formula
brew install --formula ./Formula/recall.rb

# Test it works
recall help

# Uninstall
brew uninstall recall
```

## Step 6: Push to Tap Repository

```bash
cd ~/Development/homebrew-tap

git add Formula/recall.rb
git commit -m "Add Recall formula v0.1.0"
git push origin main
```

## Step 7: Users Can Install!

Now anyone can install via:

```bash
# Method 1: Direct install (auto-taps)
brew install josharsh/tap/recall

# Method 2: Tap first, then install
brew tap josharsh/tap
brew install recall

# Uninstall
brew uninstall recall
brew untap josharsh/tap
```

## Step 8: Update README.md

Add to installation section:

```markdown
### Homebrew

\`\`\`bash
brew install josharsh/tap/recall
\`\`\`

Add to your \`~/.zshrc\`:

\`\`\`bash
source $(brew --prefix)/share/zsh/site-functions/recall
\`\`\`
```

## Updating the Formula (Future Releases)

When you release v0.2.0:

```bash
# 1. Tag new release on main repo
git tag -a v0.2.0 -m "Version 0.2.0"
git push origin v0.2.0

# 2. Get new SHA256
curl -sL https://github.com/josharsh/recall/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256

# 3. Update Formula/recall.rb
# - Change url to v0.2.0
# - Update sha256
# - Update version

# 4. Commit and push
git add Formula/recall.rb
git commit -m "Update Recall to v0.2.0"
git push origin main
```

## Alternative: Submit to homebrew-core (Later)

Once you have 75+ GitHub stars and proven stability:

```bash
# Create formula in homebrew-core
brew create https://github.com/josharsh/recall/archive/refs/tags/v1.0.0.tar.gz

# Submit PR to homebrew/homebrew-core
# They have strict requirements - see: https://docs.brew.sh/Formula-Cookbook
```

## Troubleshooting

**Formula fails to install:**
```bash
brew install --verbose --debug josharsh/tap/recall
```

**Check formula style:**
```bash
brew audit --strict recall
```

**Test formula:**
```bash
brew test recall
```

## Notes

- Homebrew caches tarballs, so SHA256 must be correct
- Users need ZSH installed (we declare it as dependency)
- Formula updates require new commits to tap repo
- Custom taps are great for quick distribution without homebrew-core approval