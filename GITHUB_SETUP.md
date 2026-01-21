# GitHub Repository Organization Guide - Math Blast

## Step 1: Flatten the Repository (Remove Nested Folder)

Your repo currently has: `codepy-main/codepy-main/` - this is nested unnecessarily.

### Option A: Using Git (Recommended - Preserves History)
```bash
# From repo root
git filter-branch --subdirectory-filter codepy-main -- --all
git reset --hard
git gc --aggressive
git prune
```

### Option B: Manual Move
```bash
# Move everything from inner folder to root
mv codepy-main/* ./
mv codepy-main/.git* ./
rmdir codepy-main
git add .
git commit -m "flatten: move project files to root"
```

---

## Step 2: Create GitHub Release

```bash
# Tag the version
git tag -a v1.0 -m "Math Blast v1.0 - Release Ready"
git push origin v1.0

# Or use GitHub UI:
# 1. Go to Releases
# 2. Click "Create a new release"
# 3. Tag: v1.0
# 4. Title: "Math Blast v1.0"
# 5. Description: (see RELEASE_TEMPLATE.md)
# 6. Upload builds (Windows, Linux, Mac, Android, iOS, Web)
```

---

## Step 3: Polish README (Add GIF & Badges)

Add to top of README.md:
```markdown
# Math Blast 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Godot 4.5](https://img.shields.io/badge/Godot-4.5-blue.svg)](https://godotengine.org)
[![Downloads](https://img.shields.io/badge/Downloads-1K%2B-brightgreen.svg)](https://itch.io/mathblast)

> Fast-paced multiplayer math puzzle game. Solo, local co-op, or network play.

![Math Blast Gameplay](https://media.giphy.com/math-blast-demo.gif)

[📥 Download](https://itch.io/mathblast) • [📖 Docs](./README.md) • [🐛 Issues](../../issues) • [☕ Support](https://ko-fi.com/mathblast)
```

---

## Step 4: File Organization

Create `.github/` folder structure:
```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── feature_request.md
│   └── question.md
├── PULL_REQUEST_TEMPLATE.md
└── workflows/
    └── build.yml
```

---

## Step 5: Clean Up Root

**Archive old docs** → Move to `/docs/ARCHIVE/`:
- IMPLEMENTATION_COMPLETE.md
- COMPLETION_SUMMARY.md
- FAILSAFE_COMPLETE.md
- FINAL_SUMMARY.txt
- All `*_SUMMARY.md` files

**Keep essential docs** at root:
- README.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- LICENSE.md

**Move to `/docs/`**:
- EXPORT_CHECKLIST.md
- INSTALLATION_SETUP.md
- TEACHER_MODE_DOCUMENTATION.md
- API documentation

---

## Step 6: Add Essential GitHub Files

### .github/CODEOWNERS
```
* @yourusername
/scripts/accessibility*.gd @yourusername
/scripts/badge*.gd @yourusername
```

### .github/PULL_REQUEST_TEMPLATE.md
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation

## Testing
How was this tested?

## Checklist
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] Tests pass
```

### CONTRIBUTING.md
```markdown
# Contributing to Math Blast

## Getting Started
1. Fork the repo
2. Clone your fork
3. Create feature branch: `git checkout -b feature/your-feature`
4. Make changes
5. Test thoroughly
6. Push and open Pull Request

## Code Standards
See CODE_STYLE_GUIDE.md

## Reporting Issues
Use GitHub Issues with clear reproduction steps

## Questions?
Open a Discussion or email support
```

---

## Step 7: Repository Settings

### General
- [ ] Make repository public
- [ ] Enable "Discussions"
- [ ] Enable "Wikis" (for expanded documentation)
- [ ] Set default branch to `main`

### Branch Protection (main)
- [ ] Require pull request reviews
- [ ] Require status checks to pass
- [ ] Include administrators

### Actions
- [ ] Enable GitHub Actions (for CI/CD)

### Pages
- [ ] Enable GitHub Pages
- [ ] Use `docs/` folder as source
- [ ] Custom domain (optional)

---

## Step 8: Release Builds

Create `release-builds/` folder with:
- `MathBlast-v1.0-Windows.exe`
- `MathBlast-v1.0-Linux.x86_64`
- `MathBlast-v1.0-macOS.dmg`
- `MathBlast-v1.0-Android.apk`

Upload to GitHub Release as assets.

---

## Step 9: Topics & Tags

Add to Repository Settings → Topics:
- `godot`
- `math-game`
- `multiplayer`
- `educational`
- `puzzle`
- `open-source`

---

## Step 10: Social Media Links

Update README footer:
```markdown
## 🌐 Connect

- **Website**: [mathblast.dev](https://mathblast.dev)
- **Discord**: [Join Server](https://discord.gg/mathblast)
- **Twitter**: [@MathBlastGame](https://twitter.com/mathblastgame)
- **Reddit**: [r/MathBlast](https://reddit.com/r/mathblast)
- **Itch.io**: [Download Free](https://itch.io/mathblast)
```

---

## Final Checklist

- [ ] Repo flattened (removed nested folder)
- [ ] README with GIF and badges
- [ ] v1.0 release created with builds
- [ ] .github/ templates added
- [ ] Old docs archived
- [ ] Contributing guide added
- [ ] Branch protection enabled
- [ ] Topics added
- [ ] Social links in README
- [ ] LICENSE file present
- [ ] .gitignore configured

Your GitHub page is now professional and ready! 🎉
