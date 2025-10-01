# Contributing to Recall

First off, thanks for taking the time to contribute! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**:
  - OS (macOS version, Linux distro)
  - ZSH version (`zsh --version`)
  - SQLite version (`sqlite3 --version`)
  - Oh My Zsh version (if applicable)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case**: Why would this be useful?
- **Examples**: Mockups, code examples, or detailed explanations
- **Alternatives**: Other solutions you've considered

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Test your changes thoroughly
3. Update documentation if needed
4. Write clear commit messages
5. Submit a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/recall.git
cd recall

# Test locally
source recall.plugin.zsh

# Make changes and test
```

## Code Style

- Use 2 spaces for indentation
- Follow existing code patterns
- Comment complex logic
- Keep functions focused and small
- Use descriptive variable names

### ZSH Best Practices

- Use `[[ ]]` for conditionals (not `[ ]`)
- Quote variables: `"$variable"`
- Use `local` for function variables
- Use `autoload -Uz add-zsh-hook` for hooks
- Avoid global variable pollution

## Testing

Before submitting a PR:

```bash
# Manual testing checklist:
# 1. Plugin loads without errors
# 2. Commands are tracked correctly
# 3. Suggestions work as expected
# 4. Aliases can be created
# 5. Database queries are efficient
# 6. No performance degradation
```

## Documentation

- Update README.md for new features
- Add inline comments for complex logic
- Update help text in ui.zsh
- Include examples in documentation

## Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs when relevant

Examples:
```
Add support for custom alias patterns
Fix database locking issue on concurrent writes
Improve performance of command analysis
Update documentation for configuration options
```

## Project Structure

```
recall/
├── recall.plugin.zsh  # Main entry point
├── lib/
│   ├── database.zsh          # SQLite operations
│   ├── tracking.zsh          # Command tracking logic
│   ├── analysis.zsh          # Pattern analysis
│   └── ui.zsh                # User interface
├── install.sh                # Installation script
└── README.md                 # Documentation
```

## Feature Ideas

Looking for something to work on? Here are some ideas:

- **Multi-shell support**: Bash compatibility
- **Cloud sync**: Optional sync between machines
- **Better pattern recognition**: ML-based suggestions
- **Fuzzy command search**: FZF integration
- **Command explanations**: Show what commands do
- **Time tracking**: Track time spent per project
- **Command templates**: Parameterized frequently-used commands
- **Export formats**: More export options (Markdown, HTML)

## Questions?

Feel free to open an issue with your question or reach out to [@josharsh](https://github.com/josharsh).

## License

By contributing, you agree that your contributions will be licensed under the MIT License.