class Recall < Formula
  desc "Smart command tracking and alias generation for ZSH - Learn your workflow, optimize your commands"
  homepage "https://github.com/josharsh/recall"
  url "https://github.com/josharsh/recall/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER_UPDATE_AFTER_GITHUB_RELEASE"
  license "MIT"
  version "0.1.0"

  depends_on "zsh"

  def install
    # Install all plugin files to prefix
    prefix.install Dir["*"]

    # Create loader script in zsh site-functions
    (share/"zsh/site-functions").mkpath
    (share/"zsh/site-functions/_recall_loader").write <<~EOS
      # Recall plugin loader for Homebrew installation
      # Source this file or add to fpath for autoload

      RECALL_HOMEBREW_PREFIX="#{prefix}"
      export RECALL_DATA_DIR="${RECALL_DATA_DIR:-${HOME}/.local/share/recall}"

      # Source main plugin
      source "#{prefix}/recall.plugin.zsh"
    EOS

    # Install man page (future)
    # man1.install "docs/recall.1"

    # Create oh-my-zsh compatible symlink
    (share/"oh-my-zsh/custom/plugins/recall").mkpath
    (share/"oh-my-zsh/custom/plugins/recall/recall.plugin.zsh").make_symlink "#{prefix}/recall.plugin.zsh"
  end

  def caveats
    <<~EOS
      🧠 Recall installed successfully!

      Add to your ~/.zshrc:

        # For Homebrew installation:
        source $(brew --prefix)/share/zsh/site-functions/_recall_loader

        # Or if you use Oh My Zsh, add to plugins array:
        plugins=(... recall)

      Then restart your terminal or run:
        source ~/.zshrc

      Quick start:
        recall              # Show project insights
        recall stats        # Detailed statistics
        recall suggest      # Get alias suggestions
        recall help         # Full documentation

      Data stored in: ~/.local/share/recall

      Documentation: https://github.com/josharsh/recall
    EOS
  end

  test do
    # Test that plugin file exists and is valid zsh
    assert_predicate prefix/"recall.plugin.zsh", :exist?

    # Test basic loading (won't fully work without sourcing in zsh context)
    system "grep", "-q", "recall()", prefix/"recall.plugin.zsh"
  end
end
