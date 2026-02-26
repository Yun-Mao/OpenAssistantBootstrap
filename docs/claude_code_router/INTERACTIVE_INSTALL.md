# Claude Code Router 交互式安装指南

## 快速概览

本指南展示了在运行 `install_claude_code_router.sh` 时会看到的完整交互式流程，与脚本实际行为一一对应。

## 完整交互流程

### 初始化阶段

```bash
$ cd OpenAssistantBootstrap
$ chmod +x scripts/install_claude_code_router.sh
$ ./scripts/install_claude_code_router.sh


╔═════════════════════════════════════╗
║  Claude Code Router 管理工具      ║
╚═════════════════════════════════════╝

请选择操作:

  1. 安装 Claude Code Router
  2. 卸载 Claude Code Router
  0. 退出

  请输入选择 (0-2):
```

**用户输入**: `1` 然后回车

---

### 步骤 1: 检查环境要求

```
┌─────────────────────────────────────┐
│  步骤 1: 检查环境要求              │
└─────────────────────────────────────┘

[SUCCESS] Node.js 已安装: v18.20.0
[SUCCESS] npm 已安装: 9.8.1
```

**Node.js 未安装时**：
```
[ERROR] 未找到 Node.js，安装失败
请先安装 Node.js 16.0.0 或更高版本
```
脚本退出，需先安装 Node.js。

---

### 步骤 2: 检查现有安装

```
┌─────────────────────────────────────┐
│  步骤 2: 检查现有安装              │
└─────────────────────────────────────┘
```

**场景 A: 首次安装**
```
[INFO] 未检测到已安装的 Claude Code Router
```
无需确认，继续下一步。

**场景 B: 已有安装**
```
[SUCCESS] 检测到已安装: @musistudio/claude-code-router@1.0.40

  已安装，是否继续安装新版本? (y/N):
```
输入 `y` 继续，`n` 则退出。

---

### 步骤 3: 选择离线包

#### 场景 A: 自动检测到离线包（推荐）

```
┌─────────────────────────────────────┐
│  步骤 3: 选择离线包                │
└─────────────────────────────────────┘

  找到离线包:
    musistudio-claude-code-router-1.0.40.tgz
  使用此文件? (Y/n):
```

**选择是**（直接回车或输入 `Y`）：
```
  使用此文件? (Y/n):
[INFO] 使用离线包: musistudio-claude-code-router-1.0.40.tgz
```

**选择否**：
```
  使用此文件? (Y/n): n
  包目录: /path/to/OpenAssistantBootstrap/packages
  输入离线包路径:
```

然后输入完整路径：
```
  输入离线包路径: /home/user/Downloads/musistudio-claude-code-router-1.0.40.tgz
[INFO] 使用离线包: /home/user/Downloads/musistudio-claude-code-router-1.0.40.tgz
```

#### 场景 B: 未自动检测到离线包

```
┌─────────────────────────────────────┐
│  步骤 3: 选择离线包                │
└─────────────────────────────────────┘

  包目录: /path/to/OpenAssistantBootstrap/packages
  输入离线包路径:
```

输入完整路径：
```
  输入离线包路径: ~/Downloads/musistudio-claude-code-router-1.0.40.tgz
[INFO] 使用离线包: /home/user/Downloads/musistudio-claude-code-router-1.0.40.tgz
```

---

### 步骤 4: 确认安装

```
┌─────────────────────────────────────┐
│  步骤 4: 确认安装                  │
└─────────────────────────────────────┘

  离线包: /path/to/packages/musistudio-claude-code-router-1.0.40.tgz
  安装方式: npm install -g <package>

  确认开始安装? (y/N):
```

**确认安装**：
```
  确认开始安装? (y/N): y
[INFO] 开始安装 Claude Code Router...
```

**取消安装**：
```
  确认开始安装? (y/N): n
[WARN] 安装已取消
```

---

### 步骤 5: 执行 npm 安装

```
┌─────────────────────────────────────┐
│  步骤 5: 执行 npm 安装             │
└─────────────────────────────────────┘

[INFO] 执行: npm install -g "/path/to/packages/musistudio-claude-code-router-1.0.40.tgz"

added 1 package in 2s
[SUCCESS] npm 安装完成
```

---

### 步骤 6: 验证安装

```
┌─────────────────────────────────────┐
│  步骤 6: 验证安装                  │
└─────────────────────────────────────┘

[SUCCESS] Claude Code Router 已安装成功
[SUCCESS] 命令别名: ccr
[SUCCESS] 版本: 1.0.40
```

---

### 安装完成

```
┌─────────────────────────────────────┐
│  安装完成                         │
└─────────────────────────────────────┘

[SUCCESS] Claude Code Router 已成功安装

快速开始:
  • 查看版本: ccr --version 或 claude-code-router --version
  • 查看帮助: ccr --help 或 claude-code-router --help

安装日志:
  /tmp/claude_code_router_install_<timestamp>.log
```

---

## 卸载流程

选择菜单 `2` 进入卸载模式：

```
  请输入选择 (0-2): 2


╔═════════════════════════════════════╗
║  Claude Code Router 卸载          ║
╚═════════════════════════════════════╝

┌─────────────────────────────────────┐
│  检测到安装信息                    │
└─────────────────────────────────────┘

  包名: @musistudio/claude-code-router
  版本: 1.0.40

  确认卸载? (y/N): y
[INFO] 执行: npm uninstall -g @musistudio/claude-code-router
[SUCCESS] Claude Code Router 卸载成功
```

**未检测到安装时**：
```
[WARN] 未检测到已安装的 Claude Code Router
[INFO] 可能未通过 npm 安装或已卸载
```

---

## 顺序流程图

```
START
  ↓
[Main Menu]
  ├─ 1: Install
  │  ├─ Step 1: Check Node.js/npm
  │  ├─ Step 2: Check Existing Installation
  │  ├─ Step 3: Select .tgz Package
  │  ├─ Step 4: Confirm
  │  ├─ Step 5: npm install -g
  │  └─ Step 6: Verify (ccr --version)
  │
  ├─ 2: Uninstall
  │  ├─ Check npm list -g
  │  ├─ Confirm Uninstall
  │  └─ npm uninstall -g
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
| 验证安装 | `ccr --version` |

---

**提示**: 在任何提示符处按 `Ctrl+C` 可随时退出。

---

**最后更新**: 2026年2月  
**作者**: OpenAssistantBootstrap 维护团队
