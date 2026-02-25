# OpenAssistant 环境安装工具

## 项目概述

这是一个为 OpenAssistant 项目提供多工具环境离线安装的工具集合。支持无 root 权限安装，交互式配置，以及自定义安装路径。目前支持 **Node.js** 和 **Claude Code** 安装，后续将继续扩展支持更多开发工具。

## 项目特点

✅ **无需 root 权限** - 所有操作都可以以普通用户身份执行
✅ **纯交互式** - 无命令行参数，全通过交互式对话框输入
✅ **现有版本检测** - 安装前自动检测现有工具安装并显示版本和路径
✅ **智能默认值** - 默认安装路径为 `$HOME/<tool_name>`，自动识别 packages 目录
✅ **步步确认** - 每个关键步骤都有用户确认
✅ **多格式支持** - 支持 tar.gz、tar.xz、zip 等多种压缩格式
✅ **清晰的输出** - 彩色输出和详细的日志记录
✅ **零依赖** - 仅使用 bash 和基础 Unix 工具

## 项目结构

```
.
├── scripts/                          # 安装脚本目录
│   ├── install_nodejs.sh            # Node.js 安装脚本
│   ├── fetch_claude_code.sh         # Claude Code 离线包获取脚本
│   ├── install_claude_code.sh       # Claude Code 安装脚本
│   └── ...                          # 其他工具安装脚本（后续添加）
├── packages/                        # 离线包目录
│   └── README.md                   # 放置压缩包说明
├── docs/                            # 文档目录
│   ├── nodejs/                      # Node.js 相关文档
│   │   ├── INSTALL_GUIDE.md        # 详细安装指南
│   │   ├── INTERACTIVE_INSTALL.md  # 交互式安装指南
│   │   └── QUICK_REFERENCE.md      # 快速参考卡
│   ├── claude_code/                 # Claude Code 相关文档
│   │   ├── INSTALL_GUIDE.md        # 详细安装指南
│   │   ├── INTERACTIVE_INSTALL.md  # 交互式安装指南
│   │   └── QUICK_REFERENCE.md      # 快速参考卡
│   └── ...                          # 其他工具文档（后续添加）
└── README.md                        # 项目说明（本文件）
```

## 支持的工具

### Node.js

- 📍 **文档位置**: [docs/nodejs/](docs/nodejs/)
- 🔧 **安装脚本**: `scripts/install_nodejs.sh`

### Claude Code

- 📍 **文档位置**: [docs/claude_code/](docs/claude_code/)
- 🔧 **获取离线包**: `scripts/fetch_claude_code.sh`（在有网机器上运行）
- 🔧 **安装脚本**: `scripts/install_claude_code.sh`
- 💡 **特点**: 官方预编译独立二进制，无需 Node.js

## 快速开始

### Node.js 安装

#### 1. 赋予脚本执行权限

```bash
chmod +x scripts/install_nodejs.sh
```

#### 2. 运行交互式安装

```bash
./scripts/install_nodejs.sh
```

**交互式安装流程：**

系统会依次询问：

1. 🔍 **步骤 1: 检测现有 Node.js 安装**
   - 如果已安装，显示版本号和路径
   - 询问是否继续安装新版本

2. 📍 **步骤 2: 选择安装路径**
   - 默认值：`$HOME/nodejs`
   - 直接回车使用默认，或输入自定义路径

3. 📦 **步骤 3: 选择压缩包**
   - 自动在 `packages/` 目录查找
   - 找到时，询问是否使用该包
   - 未找到时，要求手动输入路径

4. ✓ **步骤 4: 确认安装信息**
   - 显示源包和目标路径
   - 最后确认是否继续

5. 🔧 **步骤 5-9: 自动安装**
   - 检查目标路径（存在时询问覆盖）
   - 创建安装目录
   - 解压压缩包
   - 复制文件
   - 设置权限

6. ✨ **步骤 10: 完成配置**
   - 显示 Node.js/npm 版本
   - 提供后续配置命令

详见 [Node.js 交互式安装指南](docs/nodejs/INTERACTIVE_INSTALL.md)

#### 3. 配置环境变量

按照脚本提示运行命令（通常为）：

```bash
echo 'export PATH="$HOME/nodejs/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 4. 验证安装

```bash
node --version
npm --version
```

### Claude Code 安装

Claude Code 使用官方预编译独立二进制，**无需 Node.js**，分两步完成。

#### 1. 在有网络的机器上获取离线包

```bash
chmod +x scripts/fetch_claude_code.sh
./scripts/fetch_claude_code.sh
```

脚本会交互式选择目标平台（CentOS 7 选 `linux-x64`）和版本，下载后输出：

```
packages/claude-code-v2.1.56-linux-x64.tar.gz
```

将此文件复制到离线机器的 `packages/` 目录。

#### 2. 在离线机器上安装

```bash
chmod +x scripts/install_claude_code.sh
./scripts/install_claude_code.sh
```

#### 3. 验证安装

```bash
source ~/.bashrc
claude --version
```

详见 [Claude Code 安装指南](docs/claude_code/INSTALL_GUIDE.md)

## 文档

- [Node.js 详细安装指南](docs/nodejs/INSTALL_GUIDE.md)
- [Node.js 交互式安装指南](docs/nodejs/INTERACTIVE_INSTALL.md)
- [Node.js 快速参考](docs/nodejs/QUICK_REFERENCE.md)
- [Claude Code 详细安装指南](docs/claude_code/INSTALL_GUIDE.md)
- [Claude Code 交互式安装指南](docs/claude_code/INTERACTIVE_INSTALL.md)
- [Claude Code 快速参考](docs/claude_code/QUICK_REFERENCE.md)

## 命令参考

### 运行 Node.js 安装脚本

```bash
./scripts/install_nodejs.sh
```

脚本会交互式询问安装路径、现有版本检测和压缩包位置。所有参数均通过对话框输入。

### 运行 Claude Code 脚本

```bash
# 有网机器：获取离线包
./scripts/fetch_claude_code.sh

# 离线机器：安装
./scripts/install_claude_code.sh
```

### 显示帮助

```bash
./scripts/install_nodejs.sh --help
./scripts/fetch_claude_code.sh --help
./scripts/install_claude_code.sh --help
```

显示脚本使用说明和功能介绍。

## 脚本说明

### install_nodejs.sh

**功能：**
- 检测本地现有 Node.js 安装（若有，显示版本和路径）
- 交互式输入安装路径和压缩包路径
- 自动在 packages/ 目录查找并识别安装包
- 支持多种压缩格式（tar.gz、tar.xz、zip）
- 自动设置目录权限

**核心特性：**
- 纯交互式，无命令行参数输入
- 智能默认值（路径：$HOME/nodejs）
- 自动包检测
- 安装后自动显示版本号和配置提示

### fetch_claude_code.sh

**功能：**
- 自动检测当前机器平台或交互式选择目标平台
- 查询并下载指定版本或最新版官方二进制
- SHA256 校验和验证
- 打包为标准 tar.gz 离线安装包

**核心特性：**
- 无需 Node.js 或 npm
- 支持 6 种平台（linux-x64/arm64/musl、darwin-x64/arm64）
- 输出命名清晰（含版本和平台信息）

### install_claude_code.sh

**功能：**
- 检测本地现有 Claude Code 安装
- 交互式输入安装路径和离线包路径
- 自动在 packages/ 目录查找并识别安装包
- 安装官方预编译独立二进制

**核心特性：**
- 纯交互式，无命令行参数输入
- 无需 Node.js，独立二进制直接运行
- 智能默认值（路径：$HOME/claude-code）
- 自动包检测（优先最新版）

## 扩展性设计

此项目设计为可扩展的工具集合。后续可按以下方式添加新工具支持：

1. **在 `scripts/` 目录创建新的安装脚本**
   - 命名规范：`install_<tool_name>.sh`
   - 遵循交互式安装模式

2. **在 `docs/<tool_name>/` 创建相关文档**
   - `INSTALL_GUIDE.md` - 详细安装指南
   - `INTERACTIVE_INSTALL.md` - 交互式安装流程
   - `QUICK_REFERENCE.md` - 快速参考

3. **在 `packages/` 目录下按工具分类**
   - 推荐结构：`packages/<tool_name>/`

4. **更新本 README.md**
   - 在"支持的工具"部分添加新工具条目

## 常见问题

**Q: 是否需要 root 权限？**

A: 不需要。所有操作都可以以普通用户身份完成。

**Q: 可以同时安装多个版本吗？**

A: 可以，每个版本安装到不同的路径，通过修改 PATH 环境变量切换使用。

**Q: 如何卸载？**

A: 由于安装在用户目录，直接删除即可（以 Node.js 为例）：
```bash
rm -rf ~/nodejs
```

**Q: 支持哪些系统？**

A: 主要针对 Linux 系统（CentOS 7 及以上，Ubuntu 等）。

**Q: 脚本依赖什么？**

A: 仅需要基础的 bash、tar、unzip 等标准 Unix 工具。

## 许可证

MIT License

---

**快速链接：**
- [Node.js 详细安装指南](docs/nodejs/INSTALL_GUIDE.md)
- [Node.js 快速参考卡](docs/nodejs/QUICK_REFERENCE.md)
