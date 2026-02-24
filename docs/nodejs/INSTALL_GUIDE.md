# Node.js 离线安装脚本使用指南

## 功能概述

这是一个为 CentOS 7 环境设计的 Node.js 离线安装脚本，提供以下功能：

- ✅ 离线安装（支持 tar.gz、tar.xz、zip 格式）
- ✅ 自定义安装路径
- ✅ 本地 Node.js 版本检测
- ✅ 不需要 root 权限

## 前置条件

- CentOS 7 或相兼容系统
- 已下载 Node.js 二进制包

## 快速开始

### 1. 赋予脚本执行权限

```bash
chmod +x scripts/install_nodejs.sh
```

### 2. 检查本地 Node.js 版本

```bash
./scripts/install_nodejs.sh --check
```

输出示例：
```
[INFO] 检测本地 Node.js 版本...
[SUCCESS] 检测到 Node.js: v16.13.0
[SUCCESS] 检测到 npm: 7.24.0
[INFO] Node.js 位置: /opt/nodejs/bin/node
```

### 3. 开始交互式安装

```bash
./scripts/install_nodejs.sh --path /home/app/nodejs --pkg ./node-v16.20.0-linux-x64.tar.xz
```

安装过程中会进行多步交互确认：
- ✅ 第1步：确认安装信息（源包和目标路径）
- ✅ 第2步：检查并确认目标路径（如存在则确认是否覆盖）
- ✅ 第3-7步：自动执行创建、解压、复制、权限设置
- ✅ 第8步：交互配置环境变量
- ✅ 第9步：交互配置 npm 镜像源

## 详细命令说明

### 检查版本

```bash
./scripts/install_nodejs.sh --check
```

检查本地是否已安装 Node.js，如果已安装会显示：
- Node.js 版本号
- npm 版本号
- Node.js 安装位置

### 安装命令

```bash
./scripts/install_nodejs.sh --path <安装路径> --pkg <压缩包路径>
```

**必需选项：**
- `--path <路径>` - 指定安装路径
- `--pkg <文件>` - 指定本地压缩包路径

**安装过程 - 交互步骤：**

1. **步骤 1：确认安装信息**
   - 显示源包路径
   - 显示目标安装路径
   - 等待用户确认 (y/N)

2. **步骤 2：检查目标路径**
   - 检查安装路径是否存在
   - 如果存在：询问是否覆盖
   - 等待用户确认 (y/N)

3. **步骤 3-7：自动执行**
   - 创建安装目录
   - 自动检测压缩格式并解压
   - 复制文件到目标位置
   - 设置文件权限
   - 验证安装

4. **步骤 8：环境变量配置（交互）**
   - 显示 Node.js 和 npm 版本
   - 展示配置方式
   - 询问是否自动添加到 ~/.bashrc
   - 询问是否立即加载环境变量
   - 自动验证安装（如果加载成功）

5. **步骤 9：npm 镜像配置（交互）**
   - 询问是否配置国内镜像源
   - 列出推荐的镜像源选项
   - 让用户选择 (1-4)
   - 自动设置选定的镜像源

**示例：**
```bash
# 安装到用户主目录
./scripts/install_nodejs.sh --path ~/nodejs --pkg /tmp/node-v16.20.0-linux-x64.tar.xz

# 安装到应用目录
./scripts/install_nodejs.sh --path /home/app/nodejs --pkg ./node-v16.20.0-linux-x64.tar.xz

# 安装到自定义路径
./scripts/install_nodejs.sh --path /opt/nodejs --pkg /data/packages/node-v18.0.0-linux-x64.tar.xz
```

### 帮助

```bash
./scripts/install_nodejs.sh --help
```

## 配置环境变量

安装完成后，需要配置环境变量以使用 Node.js：

### 方式 1：临时配置（仅当前 shell 有效）

```bash
export PATH="/home/app/nodejs/bin:$PATH"
node --version
npm --version
```

### 方式 2：永久配置（推荐）

编辑 `~/.bashrc` 文件：

```bash
echo 'export PATH="/home/app/nodejs/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

验证配置：
```bash
node --version
npm --version
which node
which npm
```

## npm 镜像源配置

安装后配置 npm 镜像源加速包安装：

```bash
# 使用阿里云镜像
/home/app/nodejs/bin/npm config set registry https://registry.npmmirror.com

# 验证配置
/home/app/nodejs/bin/npm config get registry
```

常用镜像源：
- 阿里云：https://registry.npmmirror.com
- 官方：https://registry.npmjs.org
- 腾讯：https://mirrors.cloud.tencent.com/npm/
- 华为：https://repo.huaweicloud.com/repository/npm/

## 实际应用示例

### 示例 1：标准企业部署

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_PACKAGE="/data/packages/node-v16.20.0-linux-x64.tar.xz"
INSTALL_PATH="$HOME/nodejs"

# 检查版本
$SCRIPT_DIR/scripts/install_nodejs.sh --check

# 安装 Node.js
$SCRIPT_DIR/scripts/install_nodejs.sh --path "$INSTALL_PATH" --pkg "$NODE_PACKAGE"

# 配置环境变量
echo "export PATH=\"$INSTALL_PATH/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc

# 验证安装
node --version
npm --version

# 配置 npm 镜像源
npm config set registry https://registry.npmmirror.com

echo "安装完成！"
```

### 示例 2：多版本管理

```bash
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 安装 v14 到独立路径
$SCRIPT_DIR/scripts/install_nodejs.sh \
  --path ~/nodejs-v14 \
  --pkg /data/node-v14.20.0-linux-x64.tar.xz

# 安装 v16 到独立路径
$SCRIPT_DIR/scripts/install_nodejs.sh \
  --path ~/nodejs-v16 \
  --pkg /data/node-v16.20.0-linux-x64.tar.xz

echo "两个版本都已安装"
echo "v14 路径: $HOME/nodejs-v14/bin/node"
echo "v16 路径: $HOME/nodejs-v16/bin/node"

# 临时使用 v16
export PATH="$HOME/nodejs-v16/bin:$PATH"
node --version
```

### 示例 3：Docker 容器部署

```dockerfile
FROM centos:7

# 复制本地的 Node.js 包
COPY node-v16.20.0-linux-x64.tar.xz /tmp/
COPY scripts/install_nodejs.sh /tmp/

# 执行安装
RUN chmod +x /tmp/install_nodejs.sh && \
    /tmp/install_nodejs.sh \
        --path /opt/nodejs \
        --pkg /tmp/node-v16.20.0-linux-x64.tar.xz && \
    /opt/nodejs/bin/npm config set registry https://registry.npmmirror.com

# 配置环境变量
ENV PATH="/opt/nodejs/bin:$PATH"

# 验证安装
RUN node --version && npm --version

WORKDIR /app
```

## 压缩包下载

### Node.js 官方

```bash
# v16 LTS
wget https://nodejs.org/dist/v16.20.0/node-v16.20.0-linux-x64.tar.xz

# v18 LTS
wget https://nodejs.org/dist/v18.20.0/node-v18.20.0-linux-x64.tar.xz

# v20 Latest
wget https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-x64.tar.xz
```

### 镜像源下载

```bash
# 阿里云镜像（推荐国内使用）
wget https://mirrors.aliyun.com/nodejs-release/v16.20.0/node-v16.20.0-linux-x64.tar.xz

# 清华大学镜像
wget https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v16.20.0/node-v16.20.0-linux-x64.tar.xz
```

## 故障排除

### 问题 1：权限不足

错误信息：
```
mkdir: cannot create directory '/opt/nodejs': Permission denied
```

**解决**：
- 使用有权限的目录（如 `$HOME/nodejs`）
- 或联系系统管理员获取权限

### 问题 2：压缩包不存在

错误信息：
```
[ERROR] 压缩包不存在: /path/to/package
```

**解决**：
- 检查文件路径是否正确
- 确保文件名拼写无误
- 使用绝对路径而非相对路径

```bash
# 获取文件的绝对路径
cd /path/to/file
pwd  # 获取当前目录
ls -la node-v16.20.0-linux-x64.tar.xz
```

### 问题 3：安装后 node 命令不可用

错误信息：
```
node: command not found
```

**解决**：
```bash
# 重新加载环境变量
source ~/.bashrc

# 或开启新的 shell session
bash -l

# 验证配置
echo $PATH
which node
```

### 问题 4：npm 安装包失败

错误信息：
```
npm ERR! ETIME: connection timed out
```

**解决**：
```bash
# 检查网络连接
ping registry.npmmirror.com

# 更换镜像源
npm config set registry https://registry.npmmirror.com

# 清理缓存
npm cache clean --force

# 重新尝试
npm install -g webpack
```

## 日志文件

安装过程会生成日志文件：

```bash
# 日志位置
ls -la /tmp/nodejs_install_*.log

# 查看最新日志
tail -f /tmp/nodejs_install_*.log
```

## 备份和迁移

### 备份安装

```bash
# 备份整个安装
tar -czf nodejs_backup_$(date +%Y%m%d_%H%M%S).tar.gz ~/nodejs

# 备份 npm 配置
cp ~/.npmrc ~/.npmrc.backup
```

### 恢复

```bash
# 恢复备份
tar -xzf nodejs_backup_*.tar.gz -C ~/

# 恢复 npm 配置
cp ~/.npmrc.backup ~/.npmrc
```

## 性能优化

### 加速 npm 安装

```bash
# 设置国内镜像源
npm config set registry https://registry.npmmirror.com

# 提高超时时间
npm config set fetch-timeout 60000

# 设置重试参数
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# 提高并发数
npm config set max-sockets 50
```

### 使用 pnpm（可选，更快的包管理器）

```bash
# 安装 pnpm
npm install -g pnpm

# 配置 pnpm 镜像源
pnpm config set registry https://registry.npmmirror.com
```

## 常见问题

**Q: 可以安装到 /opt 目录吗？**

A: 可以，但需要该目录的写入权限。如果没有权限，使用用户主目录（如 `~/nodejs`）。

**Q: 如何卸载 Node.js？**

A: 由于脚本没有 sudo，安装在用户目录中的 Node.js 可以直接删除：
```bash
rm -rf ~/nodejs
# 从 ~/.bashrc 中删除 PATH 配置
```

**Q: 可以同时安装多个版本吗？**

A: 可以，每个版本安装到不同的路径，通过修改 PATH 环境变量切换。

**Q: npm 配置文件在哪里？**

A: `~/.npmrc`，也可以使用 `npm config list` 查看当前配置。

**Q: 如何升级 npm？**

A: 
```bash
~/nodejs/bin/npm install -g npm@latest
```

## 许可证

MIT License
