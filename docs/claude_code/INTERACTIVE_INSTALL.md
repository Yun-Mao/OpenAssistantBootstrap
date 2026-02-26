# Claude Code 交互式安装流程

## 获取离线包

### 方式 1: fetch_claude_code.sh — 独立二进制模式

```
╔═════════════════════════════════════╗
║  Claude Code 离线包获取工具        ║
╚═════════════════════════════════════╝
```

#### 步骤 1: 检查前置条件
- 检测 curl 或 wget
- 检测 sha256sum / shasum（用于校验）

#### 步骤 2: 选择目标平台
```
  支持的平台:
  1. linux-x64       (Linux x86_64, glibc，推荐 CentOS 7)
  2. linux-arm64     (Linux ARM64, glibc)
  3. linux-x64-musl  (Linux x86_64, musl/Alpine)
  4. linux-arm64-musl(Linux ARM64, musl)
  5. darwin-x64      (macOS Intel)
  6. darwin-arm64    (macOS Apple Silicon)

  自动检测到当前机器平台: linux-x64
  使用此平台下载? (Y/n):
```

#### 步骤 3: 选择版本
```
  [INFO] 正在查询最新版本...
  [SUCCESS] 最新版本: v2.1.56

  输入版本号（直接回车使用最新版 v2.1.56）:
```

#### 步骤 4: 下载二进制
- 从官方 GCS 下载预编译二进制
- 获取 manifest.json 并验证 SHA256

#### 步骤 5: 创建离线安装包
- 打包为 `packages/claude-code-<版本>-<平台>.tar.gz`

### 方式 2: pack_claude_code_npm.sh — npm 安装模式

```
╔═════════════════════════════════════╗
║  Claude Code npm 打包工具          ║
╚═════════════════════════════════════╝
```

#### 步骤 1: 检查系统环境
- 检测 bash, tar, grep, sed
- 检测 npm

#### 步骤 2: 从 npm 源下载并打包
- 使用 `npm pack @anthropic-ai/claude-code` 下载
- 保存到 `packages/anthropic-claude-code-<版本>.tgz`

---

## install_claude_code.sh — 离线安装

```
╔═════════════════════════════════════╗
║  Claude Code 管理工具              ║
╚═════════════════════════════════════╝

选择操作模式:
  1. 安装 Claude Code
  2. 卸载 Claude Code
  3. 更新配置
  0. 退出
```

### 选择安装模式

当选择 `1. 安装 Claude Code` 后，会提示选择安装模式：

```
┌─────────────────────────────────────┐
│  选择安装模式                      │
└─────────────────────────────────────┘

Claude Code 支持两种安装模式:

  1. 独立二进制模式（推荐）
     • 无需 Node.js，使用官方预编译二进制
     • 安装到自定义目录
     • 支持低版本系统的 glibc patch

  2. npm 全局安装模式
     • 需要 Node.js 16+ 环境
     • 通过 npm 全局安装
     • 与 Node.js 生态系统集成

  请选择安装模式 (1/2, 默认 1):
```

---

## 模式 1: 独立二进制安装流程

### 步骤 1: 检测现有 Claude Code 安装
```
  [SUCCESS] 检测到现有 Claude Code 安装
  版本: Claude Code v2.1.50
  路径: /home/user/claude-code/bin/claude

  是否继续安装新版本? (y/N):
```

### 步骤 2: 选择安装路径
```
  默认路径: /home/user/claude-code
  输入安装路径（直接回车使用默认）:
```

### 步骤 3: 选择离线安装包
```
  找到离线安装包:
    claude-code-v2.1.56-linux-x64.tar.gz
  使用此文件? (Y/n):
```

### 步骤 4: 确认安装信息
```
  源包:     /path/to/packages/claude-code-v2.1.56-linux-x64.tar.gz
  目标路径: /home/user/claude-code

  确认开始安装? (y/N):
```

### 步骤 5-9: 自动安装
- 检查目标路径（存在时询问覆盖）
- 创建安装目录
- 解压离线包
- 复制 bin/claude 二进制
- 设置 755 权限

### 步骤 9.5: 智能检测 patch（可选）

如果检测到 glibc 版本过低，脚本会提示并自动使用 packages/ 中的 patchelf + glibc 2.31 进行 patch。

也可以提前运行通用安装脚本安装 patch 工具：

```bash
chmod +x scripts/install_patch_tools.sh
./scripts/install_patch_tools.sh
```

### 步骤 10: 完成配置
```
  [SUCCESS] 安装路径: /home/user/claude-code
  [SUCCESS] Claude Code 版本: Claude Code v2.1.56
  [SUCCESS] 平台: linux-x64

  是否自动配置环境变量到 ~/.bashrc? (y/N):
```

---

## 模式 2: npm 全局安装流程

### 步骤 1: 检查 npm 环境要求
```
┌─────────────────────────────────────┐
│  检查 npm 环境要求                │
└─────────────────────────────────────┘

  [SUCCESS] Node.js 已安装: v18.20.0
  [SUCCESS] npm 已安装: 9.8.1
```

### 步骤 2: 检查现有安装
```
┌─────────────────────────────────────┐
│  检查现有安装                      │
└─────────────────────────────────────┘

  [SUCCESS] 检测到已安装（npm）: @anthropic-ai/claude-code@2.1.50

  是否继续安装新版本? (y/N):
```

### 步骤 3: 选择 npm 离线包
```
┌─────────────────────────────────────┐
│  选择 npm 离线包                   │
└─────────────────────────────────────┘

  找到离线包:
    anthropic-claude-code-2.1.56.tgz
  使用此文件? (Y/n):
```

### 步骤 4: 确认 npm 安装
```
┌─────────────────────────────────────┐
│  确认 npm 安装                     │
└─────────────────────────────────────┘

  离线包: /path/to/packages/anthropic-claude-code-2.1.56.tgz
  安装方式: npm install -g <package>

  确认开始安装? (y/N):
```

### 步骤 5: 执行 npm 安装
```
┌─────────────────────────────────────┐
│  执行 npm 安装                      │
└─────────────────────────────────────┘

  [INFO] 执行: npm install -g "/path/to/anthropic-claude-code-2.1.56.tgz"
  added 1 package in 2s
  [SUCCESS] npm 安装完成
```

### 步骤 6: 验证安装
```
┌─────────────────────────────────────┐
│  验证安装                           │
└─────────────────────────────────────┘

  [SUCCESS] Claude Code 已安装成功
  [SUCCESS] 版本: Claude Code v2.1.56
  [INFO] 安装记录已保存到: /home/user/.claude_code_install_record
```

### 完成
```
┌─────────────────────────────────────┐
│  安装完成                           │
└─────────────────────────────────────┘

  [SUCCESS] Claude Code 已成功安装（npm 模式）

  快速开始:
    • 查看版本: claude --version
    • 查看帮助: claude --help

  安装日志:
    /tmp/claude_code_install_*.log
```

---

## 卸载流程

脚本会根据安装记录自动识别安装模式：

### 独立二进制模式卸载
```
╔═════════════════════════════════════╗
║  Claude Code 卸载 - 交互式模式    ║
╚═════════════════════════════════════╝

  检测到安装信息
    安装路径: /home/user/claude-code

  确认卸载此安装? (y/N):
```

### npm 模式卸载
```
╔═════════════════════════════════════╗
║  Claude Code 卸载（npm 模式）      ║
╚═════════════════════════════════════╝

  检测到安装信息
    包名: @anthropic-ai/claude-code
    版本: 2.1.56

  确认卸载? (y/N):

  [INFO] 执行: npm uninstall -g @anthropic-ai/claude-code
  [SUCCESS] Claude Code 卸载成功
```
