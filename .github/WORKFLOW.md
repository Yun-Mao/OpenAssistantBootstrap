# Git工作流规范和自动化指南

## 📋 快速开始

### 四步完成开发周期

```bash
# 1️⃣ 创建feature分支
./.github/git-workflow.sh start feat/your-feature-name

# 2️⃣ 开发完成后提交到远端
./.github/git-workflow.sh submit "Your feature description"

# 3️⃣ 审核通过后合并PR
./.github/git-workflow.sh merge

# 4️⃣ 合并后进行清理
./.github/git-workflow.sh finalize
```

## 📖 详细工作流

### 完整示例

```bash
# 假设要添加Python安装工具支持

# 步骤1: 创建feature分支
./.github/git-workflow.sh start feat/python-installer

# 步骤2: 进行开发工作
# - 编写代码
# - 提交到本地git
git add scripts/install_python.sh
git commit -m "feat: add Python offline installation script

- Support non-root installation
- Automatic version detection
- Multiple compression formats"

git add docs/python/
git commit -m "docs: add Python installation documentation"

# 步骤3: 提交到远端并发起PR
./.github/git-workflow.sh submit "Add Python offline installer"

# 步骤4: 在GitHub上review和merge PR

# 步骤5: 清理本地分支
./.github/git-workflow.sh finalize
```

## 🎯 提交规范（Conventional Commits）

### 类型分类

| 类型 | 说明 | 示例 |
|------|------|------|
| feat | 新增功能 | `feat: add Python installer script` |
| fix | 修复bug | `fix: resolve PATH variable issue` |
| docs | 文档更新 | `docs: update installation guide` |
| style | 代码格式（不影响功能） | `style: format bash script` |
| refactor | 重构代码 | `refactor: simplify package detection` |
| perf | 性能优化 | `perf: optimize file extraction` |
| chore | 构建/工具相关 | `chore: add utility scripts` |
| ci | CI/CD配置 | `ci: add GitHub Actions` |
| test | 测试相关 | `test: add installation tests` |

### 提交消息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**示例:**

```
feat(nodejs): add offline installation script

- Support non-root user installation
- Automatic version detection
- Smart package detection from packages/ directory
- Support for tar.gz, tar.xz, zip formats
- Interactive mode with step-by-step guidance

Closes #123
```

## 🌿 分支命名规范

```
feat/feature-name          # 新功能分支
fix/bug-name              # bug修复分支
docs/documentation-name   # 文档更新分支
refactor/component-name   # 重构分支
chore/task-name          # 构建/工具相关分支
```

## 📤 推送和PR流程

### 自动化脚本处理的步骤：

```bash
./.github/git-workflow.sh start feat/python-installer
  ↓
# [开发工作...]
  ↓
./.github/git-workflow.sh submit "Add Python support"
  ↓
# [脚本自动]:
# 1. git push -u origin feat/python-installer
# 2. 创建Pull Request
  ↓
# [用户在GitHub上]: Code Review
  ↓
./.github/git-workflow.sh merge
  ↓
# [脚本自动]:
# 1. 确认PR信息
# 2. 合并PR到main分支
  ↓
./.github/git-workflow.sh finalize
  ↓
# [脚本自动]:
# 1. git checkout main
# 2. git pull origin main
# 3. git branch -d feat/python-installer
# 4. 删除远端feature分支
```

## 💻 脚本命令详解

### 1. 创建feature分支

```bash
./.github/git-workflow.sh start feat/your-feature

# 脚本执行:
# ✓ 更新本地main分支
# ✓ 创建新的feature分支
# ✓ 切换到feature分支
```

### 2. 提交代码到远端

```bash
./.github/git-workflow.sh submit "Feature description"

# 脚本执行:
# ✓ 检查当前分支不是main
# ✓ 推送代码到remote
# ✓ 创建Pull Request
# ✓ 输出PR链接
```

### 3. 合并PR

```bash
./.github/git-workflow.sh merge [pr-number]

# 脚本执行:
# ✓ 查找当前分支的PR（或使用指定PR号）
# ✓ 显示PR信息供确认
# ✓ 合并PR到main分支
```

### 4. 合并后清理

```bash
./.github/git-workflow.sh finalize

# 脚本执行:
# ✓ 切换到main分支
# ✓ 同步远端最新内容
# ✓ 删除本地feature分支
# ✓ 删除远端feature分支
```

## 🔧 脚本使用场景

### 场景1: 完整的feature开发

```bash
# 创建分支
./.github/git-workflow.sh start feat/new-tool

# ... 进行开发和多次提交 ...
git commit -m "feat: implement new tool"
git commit -m "docs: add documentation"
git commit -m "test: add unit tests"

# 提交到远端
./.github/git-workflow.sh submit "Implement new tool with documentation"

# ... 在GitHub完成review ...

# 合并PR
./.github/git-workflow.sh merge

# 清理
./.github/git-workflow.sh finalize
```

### 场景2: 快速bug修复

```bash
# 创建fix分支
./.github/git-workflow.sh start fix/path-issue

# 修复bug并提交
git commit -m "fix: resolve PATH variable issue

- Properly expand tilde in paths
- Handle whitespace in directory names"

# 推送PR
./.github/git-workflow.sh submit "Fix PATH variable handling"

# ... review ...

# 合并PR
./.github/git-workflow.sh merge

# 清理
./.github/git-workflow.sh finalize
```

### 场景3: 文档更新

```bash
./.github/git-workflow.sh start docs/installation-guide

git add docs/
git commit -m "docs: improve installation guide with examples"

./.github/git-workflow.sh submit "Improve documentation clarity"

# ... review ...

# 合并PR
./.github/git-workflow.sh merge

./.github/git-workflow.sh finalize
```

## 📊 提交历史规范

执行脚本后，提交历史应该看起来像：

```
* dd9963e - Merge pull request #1 from Yun-Mao/feat/nodejs-installation-tool
* 3374582 - docs: update project README for multi-tool extensibility
* f16e9d5 - chore: add packages directory structure
* d912b8c - docs: add comprehensive Node.js installation documentation
* 3a0bc6e - feat: add Node.js offline installation script
* 17a53e3 - Initial commit
```

✅ 清晰的分类  
✅ 易于追踪  
✅ 便于生成CHANGELOG  
✅ 符合业界规范  

## 🚫 常见错误

### ❌ 错误1: 在main分支上开发

```bash
# 错误
git checkout main
git add .
git commit -m "add new feature"

# 正确
./scripts/git-workflow.sh start feat/new-feature
git add .
git commit -m "feat: add new feature"
```

### ❌ 错误2: 不规范的提交消息

```bash
# 错误
git commit -m "update files"
git commit -m "fix bugs"
git commit -m "修复问题"

# 正确
git commit -m "feat: add Node.js installation script"
git commit -m "fix: resolve PATH expansion issue"
git commit -m "docs: improve README with examples"
```

### ❌ 错误3: 忘记删除本地分支

```bash
# 错误: 合并后分支仍在本地
git branch
# * main
#   feat/old-feature
#   feat/another-feature

# 正确
./scripts/git-workflow.sh finalize
# 所有feature分支自动清理
```

## 🎓 最佳实践

1. **原子性提交**: 一个提交对应一个逻辑单位
   ```bash
   git commit -m "feat: add installation script"
   git commit -m "docs: add related documentation"
   git commit -m "test: add unit tests"
   ```

2. **清晰的提交消息**: 遵循规范，说明why而不仅是what
   ```bash
   git commit -m "feat: add non-root installation support

   - Users can install without sudo
   - Default path: \$HOME/nodejs
   - Supports custom paths"
   ```

3. **定期同步**: 在feature分支完成时进行push
   ```bash
   ./scripts/git-workflow.sh submit "Your feature description"
   ```

4. **及时清理**: PR合并后立即清理本地分支
   ```bash
   ./scripts/git-workflow.sh finalize
   ```

## 📝 下次使用提示

下次开发时，只需告诉我：

```
"提交Python安装工具功能"
```

或者：

```
".github/git-workflow.sh start feat/python-installer"
"...开发中..."
".github/git-workflow.sh submit Add Python support"
"...PR已合并..."
".github/git-workflow.sh finalize"
```

我就会自动执行整个工作流，无需解释细节！🚀

