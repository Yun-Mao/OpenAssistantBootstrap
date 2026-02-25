# Copilot Instructions

## Project Overview

**OpenAssistantBootstrap** is a collection of offline installation tools for the OpenAssistant project. The core design philosophy:
- Zero root privileges required — everything installs to user home directories
- Fully interactive — no operational CLI arguments (any arg shows help and exits); all input via prompted dialogs
- Zero external dependencies — only bash and standard Unix tools (tar, unzip)
- Designed primarily for CentOS 7 / Linux environments

## Repository Structure

```
scripts/          # Installation scripts (one per tool)
packages/         # Drop offline tarballs here before running scripts
docs/<tool>/      # Per-tool documentation (INSTALL_GUIDE, INTERACTIVE_INSTALL, QUICK_REFERENCE)
.github/          # Git workflow automation scripts and docs
```

## Running the Scripts

```bash
# Grant execute permission (required first time)
chmod +x scripts/install_nodejs.sh

# Run interactive installer
./scripts/install_nodejs.sh

# Show help
./scripts/install_nodejs.sh --help
```

There are no build, test, or lint commands — this is a pure bash scripting project.

## Git Workflow

All development uses the `.github/git-workflow.sh` automation script. **Never develop directly on `main`.**

```bash
# 1. Start a feature branch
./.github/git-workflow.sh start feat/your-feature-name

# 2. Commit normally during development
git commit -m "feat: add new tool installer"

# 3. Push and open PR
./.github/git-workflow.sh submit "Feature description"

# 4. Merge PR (after review on GitHub)
./.github/git-workflow.sh merge

# 5. Clean up local/remote branches
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

## Branch Naming

```
feat/feature-name
fix/bug-description
docs/doc-topic
refactor/component-name
```

## Adding Support for a New Tool

Follow this pattern when adding a new tool (e.g., Python, Java):

1. **Script**: Create `scripts/install_<tool_name>.sh` — follow the interactive pattern from `install_nodejs.sh`
2. **Docs**: Create `docs/<tool_name>/` with `INSTALL_GUIDE.md`, `INTERACTIVE_INSTALL.md`, `QUICK_REFERENCE.md`
3. **Packages**: Users drop tarballs into `packages/` (optionally `packages/<tool_name>/`)
4. **README**: Add the new tool to the "支持的工具" (Supported Tools) section

## Script Conventions

- All scripts use `set -e` (fail on error)
- Color output uses named variables: `RED`, `GREEN`, `YELLOW`, `BLUE`, `CYAN`, `NC`
- Logging via functions: `log_info`, `log_success`, `log_warn`, `log_error`
- User prompts via `confirm_action` helper (returns 0 for yes, non-zero for no)
- Default install path pattern: `$HOME/<tool_name>`
- Package auto-detection: scripts search `packages/` relative to script location via `DEFAULT_PKG_DIR="${SCRIPT_DIR}/../packages"`
- Install records written to `$HOME/.<tool>_install_record`
- Logs written to `/tmp/<tool>_install_<timestamp>.log`
