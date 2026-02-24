# Node.js 离线安装 - 交互式安装指南

## 功能特性

脚本采用**纯交互式**设计，所有参数均通过对话框输入，无需记忆命令行参数：

✅ **现有版本检测** - 安装前检测是否已有 Node.js 安装，显示版本和路径
✅ **纯交互式输入** - 所有参数（路径、包）通过对话框输入，无命令行参数
✅ **智能默认值** - 安装路径默认为 `$HOME/nodejs`，自动识别 packages 目录中的包
✅ **步步确认** - 每个关键步骤都需要用户确认
✅ **彩色界面** - 清晰美观的交互界面
✅ **详细日志** - 完整记录每个安装步骤

## 使用方式

### 唯一方式：运行交互式安装

```bash
./scripts/install_nodejs.sh
```

脚本会依次进行以下交互：

## 交互式流程

### 步骤 1: 检测现有 Node.js 安装

**如果已有安装：**
```
[SUCCESS] 检测到现有 Node.js 安装
  版本: v16.13.0
  npm 版本: 7.24.0
  路径: /usr/local/bin/node

是否继续安装新版本? (y/N):
```
- 输入 `y` 继续安装新版本
- 输入 `N` 或直接回车取消

**如果未有安装：**
```
[INFO] 未检测到现有 Node.js 安装

继续安装新版本? (y/N):
```
- 输入 `y` 继续
- 输入 `N` 取消

### 步骤 2: 选择安装路径

```
┌─────────────────────────────────────┐
│  步骤 2: 选择安装路径              │
└─────────────────────────────────────┘

  默认路径: /home/user/nodejs
输入安装路径（直接回车使用默认）:
```

- **直接回车** - 使用默认路径 `$HOME/nodejs`
- **输入路径** - 如 `/opt/nodejs` 或 `~/my-nodejs`

### 步骤 3: 选择压缩包

**情景 A：找到默认包**
```
┌─────────────────────────────────────┐
│  步骤 3: 选择压缩包                │
└─────────────────────────────────────┘

  找到默认压缩包:
    node-v16.20.0-linux-x64.tar.xz
使用此文件? (Y/n):
```

- **直接回车** 或 **输入 y** - 使用找到的包
- **输入 n** - 输入其他包路径

**情景 B：未找到默认包**
```
┌─────────────────────────────────────┐
│  步骤 3: 选择压缩包                │
└─────────────────────────────────────┘

  默认目录: /path/to/packages/
输入压缩包路径:
```

输入压缩包的完整路径，如 `/tmp/node-v16.20.0-linux-x64.tar.xz`

### 步骤 4: 确认安装信息

```
┌─────────────────────────────────────┐
│  步骤 4: 确认安装信息              │
└─────────────────────────────────────┘

  源包: /path/to/node-v16.20.0-linux-x64.tar.xz
  目标路径: /home/user/nodejs

确认开始安装? (y/N):
```

- **输入 y** - 开始安装
- **输入 N** 或直接回车 - 取消安装

### 步骤 5-9: 自动安装

确认后，脚本自动执行：

1. **步骤 5** - 检查目标路径（若存在询问是否覆盖）
2. **步骤 6** - 创建安装目录
3. **步骤 7** - 解压压缩包
4. **步骤 8** - 复制文件到目标路径
5. **步骤 9** - 设置文件权限

### 步骤 10: 安装完成

```
┌─────────────────────────────────────┐
│  步骤 10: 安装完成                 │
└─────────────────────────────────────┘

[SUCCESS] 安装路径: /home/user/nodejs
[SUCCESS] Node.js 版本: v16.20.0
[SUCCESS] npm 版本: 8.1.0

┌─────────────────────────────────────┐
│  后续配置步骤                      │
└─────────────────────────────────────┘

1. 配置环境变量（永久使用）:
   echo 'export PATH="/home/user/nodejs/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc

2. 验证安装:
   source ~/.bashrc
   node --version
   npm --version

3. 配置 npm 镜像源（可选）:
   npm config set registry https://registry.npmmirror.com
```

## 环境变量配置

安装完成后，按照脚本提示配置环境变量：

### 永久配置

```bash
# 方式 1: 自动添加（推荐）
echo 'export PATH="/home/user/nodejs/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 方式 2: 手动编辑
vim ~/.bashrc
```

在文件末尾添加：

```bash
export PATH="/home/user/nodejs/bin:$PATH"
```

保存后执行 `source ~/.bashrc` 使配置生效。

### 验证安装

```bash
source ~/.bashrc
node --version
npm --version
```

## 常见问题

### 问题 1: 找不到压缩包

**症状：** 脚本显示"未找到默认压缩包"

**解决方案：**
1. 确保压缩包放在 `packages/` 目录
2. 检查文件名是否以 `node-` 开头
3. 确保文件格式为 `.tar.gz`、`.tar.xz` 或 `.zip`
4. 使用完整路径手动输入压缩包位置

### 问题 2: 权限不足

**症状：** 脚本显示"Permission denied"

**解决方案：**
```bash
# 确保脚本有执行权限
chmod +x scripts/install_nodejs.sh

# 重新运行
./scripts/install_nodejs.sh
```

### 问题 3: 安装路径已存在

**症状：** 脚本询问是否覆盖现有目录

**解决方案：**
- 输入 `y` 覆盖现有安装
- 或在步骤 2 中指定不同的路径

## 更多信息

- [快速参考](QUICK_REFERENCE.md) - 命令速查
- [详细安装指南](INSTALL_GUIDE.md) - 完整说明
- [主项目说明](../README.md) - 项目概览

# 在末尾添加: export PATH="/home/user/nodejs/bin:$PATH"
source ~/.bashrc
```

### 验证配置

```bash
# 重新加载环境变量
source ~/.bashrc

# 验证 node 命令
which node
node --version

# 验证 npm 命令
which npm
npm --version
```

## npm 配置

### 配置镜像源

国内推荐使用阿里云镜像：

```bash
npm config set registry https://registry.npmmirror.com
```

### 验证配置

```bash
npm config get registry
```

## 故障排除

### 问题 1: "未找到压缩包"

**原因：** `packages/` 目录中没有 Node.js 包

**解决：**
1. 确认 `packages/` 目录存在
2. 在该目录放置 Node.js 离线包
3. 包名格式：`node-v16.20.0-linux-x64.tar.xz`

### 问题 2: "权限不足"

**原因：** 无法在指定目录创建文件夹

**解决：** 使用有权限的目录，如用户主目录

### 问题 3: "node 命令找不到"

**原因：** 环境变量未生效
**解决：**
```bash
source ~/.bashrc
bash -l
which node
node --version
```

## 更多信息

- [快速参考](QUICK_REFERENCE.md) - 命令速查
- [详细安装指南](INSTALL_GUIDE.md) - 完整说明
- [主项目说明](../README.md) - 项目概览
