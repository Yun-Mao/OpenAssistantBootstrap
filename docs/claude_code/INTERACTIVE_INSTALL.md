# Claude Code 交互式安装流程

## fetch_claude_code.sh — 获取离线包

```
╔═════════════════════════════════════╗
║  Claude Code 离线包获取工具        ║
╚═════════════════════════════════════╝
```

### 步骤 1: 检查前置条件
- 检测 curl 或 wget
- 检测 sha256sum / shasum（用于校验）

### 步骤 2: 选择目标平台
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

### 步骤 3: 选择版本
```
  [INFO] 正在查询最新版本...
  [SUCCESS] 最新版本: v2.1.56

  输入版本号（直接回车使用最新版 v2.1.56）:
```

### 步骤 4: 下载二进制
- 从官方 GCS 下载预编译二进制
- 获取 manifest.json 并验证 SHA256

### 步骤 5: 创建离线安装包
- 打包为 `packages/claude-code-<版本>-<平台>.tar.gz`

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

### 步骤 10: 完成配置
```
  [SUCCESS] 安装路径: /home/user/claude-code
  [SUCCESS] Claude Code 版本: Claude Code v2.1.56
  [SUCCESS] 平台: linux-x64

  是否自动配置环境变量到 ~/.bashrc? (y/N):
```
