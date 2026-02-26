# Claude Code Router 交互式安装指南

## 快速概览

本指南展示了在运行 `install_claude_code_router.sh` 时会看到的完整交互式流程。每个步骤都是交互式的，允许您输入和确认决策。

## 完整交互流程

### 初始化阶段

```bash
$ cd OpenAssistantBootstrap
$ chmod +x scripts/install_claude_code_router.sh
$ ./scripts/install_claude_code_router.sh


╔═════════════════════════════════════╗
║  Claude Code Router 管理工具      ║
╚═════════════════════════════════════╝

选择操作模式:

  1. 安装 Claude Code Router
  2. 卸载 Claude Code Router
  3. 更新配置
  0. 退出

  请选择 (0-3):
```

**用户输入**: `1` 然后回车

---

### 步骤 1: 检测现有安装

```
╔═════════════════════════════════════╗
║  Claude Code Router 离线安装      ║
║         交互式模式                 ║
╚═════════════════════════════════════╝

┌─────────────────────────────────────┐
│  步骤 1: 检测现有安装              │
└─────────────────────────────────────┘

[INFO] 未检测到现有 Claude Code Router 安装

  继续安装新版本? (y/N):
```

**场景 A: 首次安装**
```
  继续安装新版本? (y/N): y
```

**场景 B: 更新安装**（如果已有旧版本）
```
[SUCCESS] 检测到现有 Claude Code Router 安装
  版本: 0.9.5
  路径: /home/user/claude-code-router/bin/claude-code-router

  是否继续安装新版本? (y/N): y
```

---

### 步骤 2: 选择安装路径

```
┌─────────────────────────────────────┐
│  步骤 2: 选择安装路径              │
└─────────────────────────────────────┘

  默认路径: /home/user/claude-code-router
  输入安装路径（直接回车使用默认）:
```

**选项 A: 使用默认路径**（推荐）
```
  输入安装路径（直接回车使用默认）:
[INFO] 使用默认安装路径: /home/user/claude-code-router
```

**选项 B: 自定义路径**
```
  输入安装路径（直接回车使用默认）: /data/software/ccr
[INFO] 使用自定义安装路径: /data/software/ccr
```

**选项 C: 使用波浪号**
```
  输入安装路径（直接回车使用默认）: ~/my-tools/ccr
[INFO] 使用自定义安装路径: /home/user/my-tools/ccr
```

---

### 步骤 3: 选择压缩包

#### 场景 A: 自动检测到压缩包（推荐）

```
┌─────────────────────────────────────┐
│  步骤 3: 选择压缩包                │
└─────────────────────────────────────┘

  找到默认压缩包:
    claude-code-router-1.0.0-x86_64-linux.tar.gz
  使用此文件? (Y/n):
```

**选择是**（推荐）:
```
  使用此文件? (Y/n): 
[INFO] 使用默认压缩包: claude-code-router-1.0.0-x86_64-linux.tar.gz
```

**选择否**:
```
  使用此文件? (Y/n): n
  默认目录: /path/to/OpenAssistantBootstrap/packages
  输入压缩包路径:
```

然后输入其他路径：
```
  输入压缩包路径: /home/user/Downloads/claude-code-router-1.0.0-aarch64-linux.tar.xz
[INFO] 使用压缩包: /home/user/Downloads/claude-code-router-1.0.0-aarch64-linux.tar.xz
```

#### 场景 B: 未自动检测到压缩包

```
┌─────────────────────────────────────┐
│  步骤 3: 选择压缩包                │
└─────────────────────────────────────┘

  默认目录: /path/to/OpenAssistantBootstrap/packages
  输入压缩包路径:
```

输入完整路径：
```
  输入压缩包路径: ~/Downloads/claude-code-router-1.0.0-x86_64-linux.tar.gz
[INFO] 使用压缩包: /home/user/Downloads/claude-code-router-1.0.0-x86_64-linux.tar.gz
```

---

### 步骤 4: 确认安装信息

```
┌─────────────────────────────────────┐
│  步骤 4: 确认安装信息              │
└─────────────────────────────────────┘

  源包: packages/claude-code-router-1.0.0-x86_64-linux.tar.gz
  目标路径: /home/user/claude-code-router

  确认开始安装? (y/N):
```

**确认安装**:
```
  确认开始安装? (y/N): y
[INFO] 开始安装 Claude Code Router...
```

**取消安装**:
```
  确认开始安装? (y/N): n
[WARN] 安装已取消
```

---

### 步骤 5: 检查目标路径

```
┌─────────────────────────────────────┐
│  步骤 5: 检查目标路径              │
└─────────────────────────────────────┘

[INFO] 已创建目录: /home/user/claude-code-router
```

#### 场景：目录已存在

```
[WARN] 安装路径已存在: /home/user/claude-code-router

  是否覆盖现有目录? (y/N):
```

**选择是**:
```
  是否覆盖现有目录? (y/N): y
[INFO] 删除现有目录...
[INFO] 已创建目录: /home/user/claude-code-router
```

**选择否**:
```
  是否覆盖现有目录? (y/N): n
[WARN] 安装已取消
```

---

### 步骤 6-7: 解压安装包

```
┌─────────────────────────────────────┐
│  步骤 6: 创建安装目录              │
└─────────────────────────────────────┘

[INFO] 已创建目录: /home/user/claude-code-router

┌─────────────────────────────────────┐
│  步骤 7: 解压压缩包                │
└─────────────────────────────────────┘

[INFO] 解压文件...
[SUCCESS] 解压完成（tar.gz）
```

---

### 步骤 8: 复制文件

```
┌─────────────────────────────────────┐
│  步骤 8: 复制文件到目标路径        │
└─────────────────────────────────────┘

[INFO] 复制文件: claude-code-router-1.0.0-x86_64-linux -> /home/user/claude-code-router
[SUCCESS] 文件复制完成
[SUCCESS] 目录结构验证通过: bin/claude-code-router 在 /home/user/claude-code-router 下
```

---

### 步骤 9: 设置权限

```
┌─────────────────────────────────────┐
│  步骤 9: 设置文件权限              │
└─────────────────────────────────────┘

[INFO] 设置文件权限...
[SUCCESS] 权限设置完成
```

---

### 步骤 10: 完成安装

```
[SUCCESS] Claude Code Router 安装成功!
[INFO] 安装记录已保存到: /home/user/.claude_code_router_install_record

┌─────────────────────────────────────┐
│  步骤 10: 安装完成                 │
└─────────────────────────────────────┘

[SUCCESS] 安装路径: /home/user/claude-code-router
[SUCCESS] Claude Code Router 版本: 1.0.0

┌─────────────────────────────────────┐
│  后续配置步骤                      │
└─────────────────────────────────────┘

  是否自动配置环境变量到 ~/.bashrc? (y/N):
```

#### 选项 A: 自动配置（推荐）

```
  是否自动配置环境变量到 ~/.bashrc? (y/N): y
[INFO] 添加环境变量到 /home/user/.bashrc
[SUCCESS] 环境变量已配置

重要提示:
  请勿在以下标记之间添加或修改内容：
  # >>> Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS >>>
  # <<< Claude Code Router Environment Variables - DO NOT EDIT BETWEEN MARKERS <<<
  卸载时将自动删除这些标记之间的所有内容

  请执行以下命令使配置生效:
   source ~/.bashrc

验证安装:
   source ~/.bashrc
   claude-code-router --version

快速开始:
   claude-code-router --help
```

#### 选项 B: 手动配置

```
  是否自动配置环境变量到 ~/.bashrc? (y/N): n
手动配置环境变量:
   echo 'export PATH="/home/user/claude-code-router/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc

验证安装:
   source ~/.bashrc
   claude-code-router --version

快速开始:
   claude-code-router --help
```

---

## 安装后的验证

### 命令 1: 应用配置

```bash
$ source ~/.bashrc
```

### 命令 2: 验证版本

```bash
$ claude-code-router --version
Claude Code Router version 1.0.0
```

### 命令 3: 查看帮助

```bash
$ claude-code-router --help
Claude Code Router - Code Analysis and Routing Tool

Usage:
  claude-code-router [options] [command]

Commands:
  analyze     Analyze code files
  route       Route analysis tasks
  config      Manage configuration
  help        Show help information

Options:
  --version   Show version
  -h, --help  Show this help message
```

---

## 其他操作模式

### 卸载模式

```bash
$ ./scripts/install_claude_code_router.sh

╔═════════════════════════════════════╗
║  Claude Code Router 管理工具      ║
╚═════════════════════════════════════╝

选择操作模式:

  1. 安装 Claude Code Router
  2. 卸载 Claude Code Router
  3. 更新配置
  0. 退出

  请选择 (0-3): 2


╔═════════════════════════════════════╗
║  Claude Code Router 卸载          ║
║            交互式模式              ║
╚═════════════════════════════════════╝

┌─────────────────────────────────────┐
│  检测到安装信息                    │
└─────────────────────────────────────┘

  安装路径: /home/user/claude-code-router

  确认卸载此安装? (y/N): y
[INFO] 开始卸载...

[...]

[SUCCESS] Claude Code Router 卸载完成!
```

### 更新配置模式

```bash
$ ./scripts/install_claude_code_router.sh

╔═════════════════════════════════════╗
║  Claude Code Router 管理工具      ║
╚═════════════════════════════════════╝

选择操作模式:

  1. 安装 Claude Code Router
  2. 卸载 Claude Code Router
  3. 更新配置
  0. 退出

  请选择 (0-3): 3


╔═════════════════════════════════════╗
║  Claude Code Router 更新配置      ║
║         交互式模式                 ║
╚═════════════════════════════════════╝

[...]
```

---

## 顺序流程图

```
START
  ↓
[Main Menu]
  ├─ 1: Install
  │  ├─ Step 1: Check Existing
  │  ├─ Step 2: Input Install Path
  │  ├─ Step 3: Select Package
  │  ├─ Step 4: Confirm
  │  ├─ Step 5-9: Auto Installation
  │  ├─ Step 10: Show Info
  │  └─ Configure Env Vars?
  │
  ├─ 2: Uninstall
  │  ├─ Check Record
  │  ├─ Confirm Uninstall
  │  ├─ Delete Files
  │  └─ Clean Config
  │
  ├─ 3: Update Config
  │  ├─ Show Current Info
  │  └─ Config Options Menu
  │
  └─ 0: Exit
```

---

## 快速命令参考

| 操作 | 命令 |
|------|------|
| 显示帮助 | `./scripts/install_claude_code_router.sh --help` |
| 安装 | `./scripts/install_claude_code_router.sh` → 选择 `1` |
| 卸载 | `./scripts/install_claude_code_router.sh` → 选择 `2` |
| 更新配置 | `./scripts/install_claude_code_router.sh` → 选择 `3` |
| 应用配置 | `source ~/.bashrc` |
| 验证安装 | `claude-code-router --version` |

---

**提示**: 在任何提示符处答错后，脚本不会自动退出，而是要求重新输入。如需完全退出，按 `Ctrl+C`。

---

**最后更新**: 2026年2月  
**作者**: OpenAssistantBootstrap 维护团队
