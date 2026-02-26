# Claude Code 离线安装指南

## 功能概述

这是一个为 CentOS 7 / Linux 环境设计的 Claude Code 离线安装方案，提供以下功能：

- ✅ 离线安装（官方预编译独立二进制，无需 Node.js）
- ✅ 自定义安装路径
- ✅ 本地 Claude Code 版本检测
- ✅ SHA256 校验和验证
- ✅ 不需要 root 权限
- ✅ 支持多平台（linux-x64、linux-arm64、darwin 等）

## 两步走流程

### 第一步：在有网机器上获取离线包

```bash
chmod +x scripts/fetch_claude_code.sh
./scripts/fetch_claude_code.sh
```

脚本会交互式询问：
- 目标平台（自动检测或手动选择）
- 版本号（自动获取最新或手动指定）

输出：`packages/claude-code-<版本>-<平台>.tar.gz`

**将此文件复制到离线机器的 `packages/` 目录。**

### 第二步：在离线机器上安装

```bash
chmod +x scripts/install_claude_code.sh
./scripts/install_claude_code.sh
```

## 前置条件

| 环境 | 需求 |
|------|------|
| 有网机器（fetch） | curl 或 wget |
| 离线机器（install） | bash、tar（标准 Unix 工具即可） |
| 权限 | 无需 root |

可选依赖（仅在低版本 glibc 环境需要 patch 时使用）：

- patchelf 离线包
- glibc 2.31 离线包

## 支持的平台

| 平台标识 | 适用系统 |
|----------|---------|
| `linux-x64` | Linux x86_64，glibc（CentOS 7 / Ubuntu 等） |
| `linux-arm64` | Linux ARM64，glibc |
| `linux-x64-musl` | Linux x86_64，musl（Alpine Linux 等） |
| `linux-arm64-musl` | Linux ARM64，musl |
| `darwin-x64` | macOS Intel |
| `darwin-arm64` | macOS Apple Silicon |

## 安装后目录结构

```
$HOME/claude-code/        ← 默认安装路径
├── bin/
│   └── claude            ← 可执行二进制
├── VERSION               ← 版本号记录
└── PLATFORM              ← 平台标识记录
```

## Patch 说明（可选）

在 CentOS 7 / glibc 版本偏低的环境中，Claude Code 可能会提示缺少 GLIBC_2.28/GLIBC_2.31。
安装脚本会自动检测并尝试使用 patchelf + glibc 2.31 对二进制进行 patch。

请提前在 packages/ 目录中放入以下离线包：

```
patchelf-<version>-linux-x64.tar.gz
glibc-2.31-linux-x64.tar.gz
```

也可以提前运行通用安装脚本安装 patch 工具：

```bash
chmod +x scripts/install_patch_tools.sh
./scripts/install_patch_tools.sh
```

## 版本管理

安装记录保存在 `$HOME/.claude_code_install_record`，用于卸载时定位安装路径。

## 常见问题

**Q: 安装后如何验证？**

```bash
source ~/.bashrc
claude --version
```

**Q: 如何卸载？**

```bash
./scripts/install_claude_code.sh
# 选择 2. 卸载 Claude Code
```

**Q: 是否需要 Node.js？**

不需要。Claude Code 官方提供独立预编译二进制，内置所有依赖。

**Q: CentOS 7 用哪个平台版本？**

选择 `linux-x64`（glibc 版本，适用于 CentOS 7 及 glibc 系 Linux）。
