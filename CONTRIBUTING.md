# Contributing to Math Blast

We love your input! Whether it's bug reports, feature requests, or code contributions, your help makes Math Blast better.

## Getting Started

### Prerequisites
- Godot 4.5+
- Git
- Basic knowledge of GDScript

### Local Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/math-blast.git
cd math-blast

# Create a feature branch
git checkout -b feature/your-feature-name

# Open with Godot
godot --path .
```

## Making Changes

### Before You Start
1. Check [existing issues](../../issues) and [PRs](../../pulls)
2. Review [CODE_STYLE_GUIDE.md](CODE_STYLE_GUIDE.md)
3. Review [ACCESSIBILITY_STANDARDS.md](docs/ACCESSIBILITY.md) if modifying UI/gameplay

### Code Standards
- Follow GDScript conventions (snake_case for functions, PascalCase for classes)
- Add docstring comments above all public functions
- Use type hints for all variables and return types
- Maximum 100 characters per line (flexible for readability)
- 1 space indentation (Godot standard)

### Commit Messages
```
type(scope): subject

body (optional, wrapped at 72 chars)

footer (optional - references to issues)

Types: feat, fix, docs, style, refactor, test, chore
Example: feat(accessibility): add colorblind mode support

Fixes #123
```

## Testing

Before submitting:
```bash
# Test locally
godot --path . &

# If applicable, test multiplayer
# - Start as host
# - Connect as client
# - Verify sync works
```

### Test Checklist
- [ ] Game runs without crashes
- [ ] No console warnings/errors
- [ ] Multiplayer works (if applicable)
- [ ] Performance acceptable (60 FPS)
- [ ] Accessibility maintained
- [ ] Tested on Windows/Linux/Mac (if possible)

## Submitting Changes

### Create a Pull Request

1. **Fork and branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make changes**
   - Follow code standards
   - Test thoroughly
   - Add comments for complex logic

3. **Commit and push**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   git push origin feature/your-feature
   ```

4. **Open PR**
   - Use the PR template
   - Reference related issues
   - Add screenshots if UI changes
   - Describe testing steps

### PR Review Process
- Maintainers will review within 7 days
- Changes requested? Update your branch
- Approved PRs will be merged to `develop`, then `main`

## Reporting Bugs

Use [GitHub Issues](../../issues) with:
- **Clear title**: `[BUG] Brief description`
- **Version**: What version are you using?
- **Steps to reproduce**: Specific, numbered steps
- **Expected vs actual**: What should happen vs what did happen
- **Environment**: OS, Godot version, etc.
- **Screenshots/logs**: Error messages or images

## Feature Requests

Use [GitHub Issues](../../issues) with:
- **Clear title**: `[FEATURE] Brief description`
- **Use case**: Why do you need this?
- **Proposed solution**: How should it work?
- **Alternatives**: Other approaches considered
- **Examples**: Similar features in other games

## Documentation

Documentation is just as important as code! Help by:
- Clarifying README sections
- Improving API documentation
- Adding tutorials or guides
- Fixing typos or grammar

See [docs/](docs/) for existing documentation structure.

## Community

- **Issues**: For bugs and features
- **Discussions**: For general questions
- **Discord**: Real-time chat (link in README)

## Recognition

Contributors are recognized in:
- README.md contributors section
- GitHub contributors list
- Major release notes

## Questions?

Don't be shy! Ask in:
- GitHub Discussions
- Issues (prefixed with `[QUESTION]`)
- Email maintainer

---

**Thank you for contributing to Math Blast! 🚀**
