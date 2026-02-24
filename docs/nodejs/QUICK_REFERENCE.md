# Node.js 离线安装 - 快速参考

## 基本命令

### 检查本地版本
```bash
./scripts/install_nodejs.sh --check
```

### 安装到自定义路径
```bash
./scripts/install_nodejs.sh --path ~/nodejs --pkg ./node-v16.20.0-linux-x64.tar.xz
```

### 显示帮助
```bash
./scripts/install_nodejs.sh --help
```

---

## 环境变量配置

### 临时使用（仅当前 shell）
```bash
export PATH="/home/app/nodejs/bin:$PATH"
node --version
```

### 永久使用（推荐）
```bash
echo 'export PATH="/home/app/nodejs/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## npm 镜像源配置

### 设置国内镜像
```bash
npm config set registry https://registry.npmmirror.com
```

### 查看当前配置
```bash
npm config list
npm config get registry
```

### 常用镜像源

| 名称 | URL |
|------|-----|
| 阿里云 | https://registry.npmmirror.com |
| 官方 | https://registry.npmjs.org |
| 腾讯 | https://mirrors.cloud.tencent.com/npm/ |
| 华为 | https://repo.huaweicloud.com/repository/npm/ |

---

## 一键安装脚本

### 标准部署脚本
```bash
#!/bin/bash
set -e

# 检查版本
./scripts/install_nodejs.sh --check

# 安装 Node.js
./scripts/install_nodejs.sh --path ~/nodejs --pkg /tmp/node-v16.20.0-linux-x64.tar.xz

# 配置环境变量
echo 'export PATH="$HOME/nodejs/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 配置 npm 镜像源
npm config set registry https://registry.npmmirror.com

echo "安装完成！"
```

---

## 多版本管理

### 安装多个版本
```bash
# 安装 v14
./scripts/install_nodejs.sh --path ~/nodejs-v14 --pkg /tmp/node-v14.20.0-linux-x64.tar.xz

# 安装 v16
./scripts/install_nodejs.sh --path ~/nodejs-v16 --pkg /tmp/node-v16.20.0-linux-x64.tar.xz
```

### 切换版本（临时）
```bash
# 使用 v14
export PATH="$HOME/nodejs-v14/bin:$PATH"

# 使用 v16
export PATH="$HOME/nodejs-v16/bin:$PATH"
```

### 切换版本（永久）
编辑 `~/.bashrc`，修改 PATH 行：
```bash
# 使用 v14
export PATH="$HOME/nodejs-v14/bin:$PATH"

# 使用 v16
export PATH="$HOME/nodejs-v16/bin:$PATH"
```

---

## 常见问题速查

| 问题 | 解决方案 |
|------|--------|
| node 命令不存在 | `source ~/.bashrc` 或 `bash -l` |
| 权限不足 | 使用可写目录如 `~/nodejs` |
| 镜像源连接失败 | 检查网络，更换镜像源 |
| npm 命令找不到 | 确认安装完成，重新加载环境 |
| 压缩包损坏 | 重新下载压缩包 |

---

## 目录结构

```
scripts/
  └── install_nodejs.sh      # 主安装脚本

docs/
  ├── INSTALL_GUIDE.md       # 详细安装指南
  └── QUICK_REFERENCE.md     # 快速参考（本文件）
```

---

## 日志文件

```bash
# 查看最新安装日志
cat /tmp/nodejs_install_*.log

# 实时查看日志
tail -f /tmp/nodejs_install_*.log
```

---

## Node.js 下载链接

### 官方源
```
v16: https://nodejs.org/dist/v16.20.0/node-v16.20.0-linux-x64.tar.xz
v18: https://nodejs.org/dist/v18.20.0/node-v18.20.0-linux-x64.tar.xz
v20: https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-x64.tar.xz
```

### 国内镜像
```
阿里云：https://mirrors.aliyun.com/nodejs-release/v16.20.0/node-v16.20.0-linux-x64.tar.xz
清华：https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v16.20.0/node-v16.20.0-linux-x64.tar.xz
```

---

## 备份和恢复

### 备份
```bash
tar -czf nodejs_backup_$(date +%Y%m%d).tar.gz ~/nodejs ~/.npmrc
```

### 恢复
```bash
tar -xzf nodejs_backup_*.tar.gz -C ~/
```

---

## 卸载

```bash
# 删除 Node.js 目录
rm -rf ~/nodejs

# 从 ~/.bashrc 中删除 PATH 配置
# 并执行
source ~/.bashrc
```

---

## npm 常用命令

```bash
# 查看版本
npm --version

# 查看配置
npm config list

# 清理缓存
npm cache clean --force

# 全局安装包
npm install -g webpack

# 升级 npm
npm install -g npm@latest
```
