# Claude Code Router 快速参考卡

## 3 分钟快速开始

```bash
# 1. 进入项目目录
cd OpenAssistantBootstrap

# 2. 赋予脚本权限
chmod +x scripts/install_claude_code_router.sh

# 3. 将离线包放入 packages 目录
cp /path/to/claude-code-router-*.tar.gz packages/

# 4. 运行安装
./scripts/install_claude_code_router.sh
# 出现菜单时选择：1（安装）
# 后续提示都直接回车使用默认值，最后选择 y 配置环境变量

# 5. 应用配置
source ~/.bashrc

# 6. 验证
claude-code-router --version
```

---

## 常用命令

### 安装

```bash
./scripts/install_claude_code_router.sh
# 菜单选择：1
```

**默认安装路径**: `$HOME/claude-code-router`

### 卸载

```bash
./scripts/install_claude_code_router.sh
# 菜单选择：2
```

**自动删除**: 安装目录、环境变量、安装记录

### 更新配置

```bash
./scripts/install_claude_code_router.sh
# 菜单选择：3
```

**常见操作**: 配置环境变量、查看版本信息

### 显示帮助

```bash
./scripts/install_claude_code_router.sh --help
```

---

## 安装前检查清单

- [ ] 系统：Linux (CentOS 7, Ubuntu, Debian 等)
- [ ] 权限：普通用户（无需 root）
- [ ] 工具：tar, unzip, bash 4.0+（通常预装）
- [ ] 磁盘：≥ 100MB 自由空间
- [ ] 离线包：.tar.gz / .tar.xz / .zip 格式

命令验证：
```bash
# 检查 bash 版本
bash --version

# 检查必要工具
command -v tar && command -v unzip && command -v find
```

---

## 环境变量配置

### 自动配置

安装完成后选择 `y`，脚本自动添加到 `~/.bashrc`：

```bash
# >>> Claude Code Router Environment Variables >>>
export PATH="/home/user/claude-code-router/bin:$PATH"
# <<< Claude Code Router Environment Variables <<<
```

### 手动配置（如需）

```bash
# 编辑配置文件
cat >> ~/.bashrc << 'EOF'

export PATH="$HOME/claude-code-router/bin:$PATH"
EOF

# 应用配置
source ~/.bashrc
```

### 验证配置

```bash
# 检查 PATH
echo $PATH | grep claude-code-router

# 检查命令位置
which claude-code-router

# 运行命令
claude-code-router --version
```

---

## 离线包信息

### 文件名格式

```
claude-code-router-<版本>-<平台>.tar.gz
claude-code-router-<版本>-<平台>.tar.xz
claude-code-router-<版本>-<平台>.zip
```

### 示例文件名

- `claude-code-router-1.0.0-x86_64-linux.tar.gz`（64位 Intel/AMD）
- `claude-code-router-1.0.0-aarch64-linux.tar.xz`（ARM64）
- `claude-code-router-1.0.0-x86_64-linux.zip`（Windows 兼容压缩）

### 支持的架构

| 架构 | 文件名标识 |
|------|-----------|
| x86_64 (Intel/AMD 64位) | `x86_64` |
| ARM64 (阿里云飞天等) | `aarch64` / `arm64` |
| 其他 | 按官方标识 |

### 文件验证

```bash
# 查看压缩包内容（不解压）
tar -tzf claude-code-router-*.tar.gz | head -20

# 列出关键文件
tar -tzf claude-code-router-*.tar.gz | grep "bin/claude-code-router"

# 检查文件大小
ls -lh claude-code-router-*.tar.gz
```

---

## 安装目录结构

```
claude-code-router-1.0.0-x86_64-linux/
├── bin/
│   └── claude-code-router          # 主可执行文件
├── lib/
│   ├── libfoo.so.1                 # 依赖库
│   └── ...
├── README.md                        # 项目说明
├── LICENSE                          # 许可证
└── ...
```

安装后（默认路径）:
```
~/claude-code-router/
├── bin/
│   └── claude-code-router
├── lib/
├── README.md
└── ...
```

---

## 常见问题快速解决

### 找不到压缩包

```bash
# 检查 packages 目录
ls -la packages/

# 手动复制文件
cp /path/to/claude-code-router-*.tar.gz packages/

# 或在提示时输入完整路径
/home/user/Downloads/claude-code-router-1.0.0-x86_64-linux.tar.gz
```

### 权限错误

```bash
# 修复脚本权限
chmod +x scripts/install_claude_code_router.sh

# 修复包文件权限
chmod +r packages/claude-code-router-*.tar.gz

# 使用用户有权限的路径（如 $HOME）
# 在安装时选择 /home/username/claude-code-router
```

### 命令未找到

```bash
# 应用配置
source ~/.bashrc

# 验证 PATH
echo $PATH

# 直接使用完整路径
~/claude-code-router/bin/claude-code-router --version

# 重新手动配置
echo 'export PATH="$HOME/claude-code-router/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 文件缺失错误

```bash
# 检查压缩包完整性
tar -tzf packages/claude-code-router-*.tar.gz | wc -l

# 验证关键文件存在
tar -tzf packages/claude-code-router-*.tar.gz | grep "bin/claude-code-router"

# 重新下载官方包
```

---

## 安装前后对比

### 安装前

```bash
$ which claude-code-router
# (无输出或找不到)

$ echo $PATH
# /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:...
```

### 安装后

```bash
$ which claude-code-router
/home/user/claude-code-router/bin/claude-code-router

$ echo $PATH
/home/user/claude-code-router/bin:/usr/local/sbin:/usr/local/bin:...

$ claude-code-router --version
Claude Code Router version 1.0.0
```

---

## 日志文件位置

```bash
# 最新安装日志
/tmp/claude_code_router_install_<timestamp>.log

# 查看日志
tail -50 /tmp/claude_code_router_install_*.log

# 搜索错误
grep ERROR /tmp/claude_code_router_install_*.log

# 列出所有日志
ls -lt /tmp/claude_code_router_install_*.log
```

---

## 卸载/重新安装

### 快速卸载

```bash
./scripts/install_claude_code_router.sh
# 菜单选择：2
# 确认：y
```

### 快速重新安装

```bash
# 1. 卸载
./scripts/install_claude_code_router.sh  # 选 2
# 2. 安装
./scripts/install_claude_code_router.sh  # 选 1
# 3. 配置
source ~/.bashrc
```

---

## 多版本安装

如果需要保留多个版本：

```bash
# 版本 1.0
./scripts/install_claude_code_router.sh
# 步骤 2：输入 /home/user/ccr-1.0

# 版本 1.1
./scripts/install_claude_code_router.sh
# 步骤 2：输入 /home/user/ccr-1.1

# 切换版本（在 ~/.bashrc 中修改）
export PATH="/home/user/ccr-1.1/bin:$PATH"
source ~/.bashrc
```

---

## 系统兼容性

| OS | 版本 | 支持 |
|----|------|------|
| CentOS | 7, 8, 9 | ✅ |
| RHEL | 7, 8, 9 | ✅ |
| Ubuntu | 16.04+ | ✅ |
| Debian | 9+ | ✅ |
| Fedora | 30+ | ✅ |
| Alpine | 3.13+ | ℹ️ 需要 glibc 兼容层 |

---

## 快速测试

```bash
# 显示版本
claude-code-router --version

# 显示帮助
claude-code-router --help

# 显示配置
claude-code-router config show  # 如果支持

# 列出可用命令
claude-code-router -h
```

---

## 重要文件位置

| 文件/目录 | 描述 |
|----------|------|
| `~/.bashrc` | 环境变量配置 |
| `~/.claude_code_router_install_record` | 安装记录（路径） |
| `/tmp/claude_code_router_install_*.log` | 安装日志 |
| `~/claude-code-router/` | 默认安装目录 |
| `packages/` | 离线包存放目录 |

---

## 环境检查命令集

```bash
# 一键检查系统
echo "=== Bash ===" && bash --version && \
echo "=== Tar ===" && tar --version && \
echo "=== Unzip ===" && unzip -v | head -3 && \
echo "=== Space ===" && df -h ~ && \
echo "=== Arch ===" && uname -m
```

---

## 进阶选项

### 自定义安装路径（NAS、共享存储等）

```bash
./scripts/install_claude_code_router.sh
# 步骤 2：输入 /mnt/nas/software/ccr
```

### 系统级安装（需要 sudo）

```bash
sudo mkdir -p /opt/claude-code-router
sudo chmod 755 /opt/claude-code-router
./scripts/install_claude_code_router.sh
# 步骤 2：输入 /opt/claude-code-router
```

### 查看完整脚本日志

```bash
# 在安装时输出更详细的日志
bash -x scripts/install_claude_code_router.sh 2>&1 | tee install.log
```

---

## 获取帮助

| 资源 | 位置 |
|------|------|
| 详细指南 | [INSTALL_GUIDE.md](INSTALL_GUIDE.md) |
| 交互式演示 | [INTERACTIVE_INSTALL.md](INTERACTIVE_INSTALL.md) |
| 脚本帮助 | `./scripts/install_claude_code_router.sh --help` |
| 官方文档 | [Claude Code Router Repository](https://github.com/anthropic/claude-code-router) |

---

**最后更新**: 2026年2月  
**版本**: 1.0  
**作者**: OpenAssistantBootstrap 维护团队

---

## 常用快捷命令

```bash
# 完整安装（从克隆到验证）
cd OpenAssistantBootstrap && \
chmod +x scripts/install_claude_code_router.sh && \
cp ~/Downloads/claude-code-router-*.tar.gz packages/ && \
./scripts/install_claude_code_router.sh && \
source ~/.bashrc && \
claude-code-router --version

# 完全卸载
./scripts/install_claude_code_router.sh && \
source ~/.bashrc && \
echo "Uninstall complete"

# 诊断安装状态
echo "=== Installed ===" && \
ls -lh ~/claude-code-router/bin/ 2>/dev/null && \
echo "=== Version ===" && \
claude-code-router --version 2>/dev/null && \
echo "=== PATH ===" && \
which claude-code-router
```
