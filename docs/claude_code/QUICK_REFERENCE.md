# Claude Code 快速参考

## 安装模式

Claude Code 支持两种安装模式：

| 模式 | 特点 | 适用场景 |
|------|------|---------|
| **独立二进制** | 无需 Node.js，自定义路径，支持 glibc patch | CentOS 7、无 Node.js 环境 |
| **npm 全局** | 需要 Node.js 16+，与 npm 生态集成 | 有 Node.js 环境 |

## 一键命令

### 独立二进制模式

```bash
# 有网机器：获取离线包
chmod +x scripts/fetch_claude_code.sh && ./scripts/fetch_claude_code.sh

# 离线机器：安装（选择模式 1）
chmod +x scripts/install_claude_code.sh && ./scripts/install_claude_code.sh

# 验证安装
source ~/.bashrc && claude --version
```

### npm 安装模式

```bash
# 有网机器：获取 npm 离线包
chmod +x scripts/pack_claude_code_npm.sh && ./scripts/pack_claude_code_npm.sh

# 离线机器：安装（选择模式 2）
chmod +x scripts/install_claude_code.sh && ./scripts/install_claude_code.sh

# 验证安装
source ~/.bashrc && claude --version
```

## 离线包命名规则

### 独立二进制模式

```
claude-code-<VERSION>-<PLATFORM>.tar.gz

示例:
  claude-code-v2.1.56-linux-x64.tar.gz
  claude-code-v2.1.56-linux-arm64.tar.gz
```

### npm 安装模式

```
anthropic-claude-code-<VERSION>.tgz

示例:
  anthropic-claude-code-2.1.56.tgz
```

## Patch 依赖包（可选，仅独立二进制模式）

低版本 glibc 环境可能需要 patch，脚本会自动检测并使用以下离线包：

```
patchelf-<version>-linux-x64.tar.gz
glibc-2.31-linux-x64.tar.gz
```

## Patch 工具安装（可选）

```bash
chmod +x scripts/install_patch_tools.sh
./scripts/install_patch_tools.sh
```

## 平台速查

| 系统 | 选择平台 |
|------|---------|
| CentOS 7 x86_64 | `linux-x64` |
| Ubuntu x86_64 | `linux-x64` |
| Alpine Linux | `linux-x64-musl` |
| macOS Intel | `darwin-x64` |
| macOS M1/M2 | `darwin-arm64` |

## 默认路径

| 项目 | 独立二进制模式 | npm 模式 |
|------|---------------|----------|
| 安装目录 | `$HOME/claude-code` | `$(npm root -g)/@anthropic-ai/claude-code` |
| 可执行文件 | `$HOME/claude-code/bin/claude` | `$(npm bin -g)/claude` |
| 安装记录 | `$HOME/.claude_code_install_record` | `$HOME/.claude_code_install_record` |
| 安装日志 | `/tmp/claude_code_install_<时间戳>.log` | `/tmp/claude_code_install_<时间戳>.log` |

## 管理操作

```bash
# 安装（会提示选择安装模式）
./scripts/install_claude_code.sh   # 选择 1

# 卸载（自动识别安装模式）
./scripts/install_claude_code.sh   # 选择 2

# 更新配置（重新配置 PATH 等）
./scripts/install_claude_code.sh   # 选择 3

# 查看帮助
./scripts/install_claude_code.sh --help
./scripts/fetch_claude_code.sh --help
./scripts/pack_claude_code_npm.sh --help
```

## 手动配置 PATH（如未自动配置）

### 独立二进制模式

```bash
echo 'export PATH="$HOME/claude-code/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### npm 模式

```bash
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 模式切换

```bash
# 1. 卸载当前模式
./scripts/install_claude_code.sh   # 选择 2

# 2. 使用新模式安装
./scripts/install_claude_code.sh   # 选择 1 → 选择目标模式
```
