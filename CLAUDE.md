# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OpenAssistantBootstrap** is a collection of offline installation tools for the OpenAssistant project. All tools are pure bash scripts with zero external dependencies (only standard Unix tools: bash, tar, unzip).

**Core Design Philosophy:**
- Zero root privileges required — everything installs to user home directories
- Fully interactive — no operational CLI arguments (any argument shows help); all input via prompted dialogs
- Designed primarily for CentOS 7 / Linux environments

## Repository Structure

```
scripts/          # Installation scripts (one per tool)
packages/         # Drop offline tarballs here (gitignored)
docs/<tool>/      # Per-tool documentation
.github/          # Git workflow automation
```

## Running the Scripts

There are no build, test, or lint commands in this project.

```bash
# Grant execute permission (required first time)
chmod +x scripts/install_nodejs.sh

# Run interactive installer (any arg shows help)
./scripts/install_nodejs.sh
./scripts/install_nodejs.sh --help
```

## Git Workflow

All development uses `.github/git-workflow.sh`. **Never develop directly on `main`.**

```bash
# Start a feature branch
./.github/git-workflow.sh start feat/your-feature-name

# Commit during development
git commit -m "feat: add new tool installer"

# Push and open PR
./.github/git-workflow.sh submit "Feature description"

# Merge PR (after review)
./.github/git-workflow.sh merge

# Clean up branches
./.github/git-workflow.sh finalize
```

## Commit Message Convention (Conventional Commits)

Format: `<type>(<scope>): <subject>`

| Type | When to use |
|------|-------------|
| `feat` | New installer script or feature |
| `fix` | Bug fix in a script |
| `docs` | Documentation changes |
| `refactor` | Code restructure without behavior change |
| `chore` | Build/tooling changes |

Example:
```
feat(nodejs): add offline installation script

- Support non-root user installation
- Automatic version detection
- Smart package detection from packages/ directory
```

## Script Conventions

When adding a new tool installer, follow the pattern from `scripts/install_nodejs.sh`:

- **No CLI arguments**: Any argument triggers `--help` display and exits
- **Interactive prompts**: Use `confirm_action()` helper for y/N confirmations
- **Color output**: Use named variables `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `NC`
- **Logging functions**: `log_info`, `log_success`, `log_warn`, `log_error`
- **Install path pattern**: `$HOME/<tool_name>` as default
- **Package auto-detection**: `DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"`
- **Install record**: Write to `$HOME/.<tool>_install_record`
- **Log file**: Write to `/tmp/<tool>_install_<timestamp>.log`
- **Error handling**: Always use `set -e`

## Adding a New Tool

1. Create `scripts/install_<tool_name>.sh` following the interactive pattern
2. Create `docs/<tool_name>/` with three files:
   - `INSTALL_GUIDE.md` - Detailed installation guide
   - `INTERACTIVE_INSTALL.md` - Interactive installation flow
   - `QUICK_REFERENCE.md` - Quick reference card
3. Update `README.md` to add the new tool to the "支持的工具" section

## Supported Tools

- **Node.js** ([docs/nodejs/](docs/nodejs/)): `scripts/install_nodejs.sh`
- **Claude Code** ([docs/claude_code/](docs/claude_code/)): `scripts/fetch_claude_code.sh` + `scripts/install_claude_code.sh` (with optional glibc patching via `scripts/install_patch_tools.sh`)
