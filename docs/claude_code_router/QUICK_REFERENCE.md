# Claude Code Router 快速参考卡

## 3 分钟快速开始

```bash
# 1. 进入项目目录
cd OpenAssistantBootstrap

# 2. 赋予脚本权限
chmod +x scripts/install_claude_code_router.sh

# 3. 将离线包放入 packages 目录
cp /path/to/musistudio-claude-code-router-*.tgz packages/

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

**自动执行**: `npm uninstall -g @musistudio/claude-code-router`

### 显示帮助

```bash
./scripts/install_claude_code_router.sh --help
```

---

## 安装前检查清单

- [ ] 系统：Linux (CentOS 7, Ubuntu, Debian 等)
- [ ] 权限：普通用户（无需 root）
- [ ] Node.js: v16.0.0+
- [ ] npm: 8.0.0+
- [ ] 磁盘：≥ 50MB 自由空间
- [ ] 离线包：`musistudio-claude-code-router-*.tgz` (npm 打包格式)

命令验证：
```bash
node --version
npm --version
```

## 离线包信息

### 文件名格式

npm 打包格式：
```
musistudio-claude-code-router-<版本>.tgz
```

### 示例文件名

- `musistudio-claude-code-router-1.0.40.tgz`

### 文件验证

```bash
# 查看包内容（不解压）
tar -tzf musistudio-claude-code-router-*.tgz | head -20

# 检查文件大小
ls -lh musistudio-claude-code-router-*.tgz
```

---

## npm 全局安装说明

npm 全局安装会自动处理 PATH：
- 可执行文件链接到 npm 的全局 bin 目录
- 安装成功后无需手动配置 PATH
- 可用 `npm bin -g` 查看全局 bin 目录位置

---

## 常见问题快速解决

### 找不到离线包

```bash
# 检查 packages 目录
ls -la packages/

# 手动复制文件
cp /path/to/musistudio-claude-code-router-*.tgz packages/

# 或在提示时输入完整路径
/home/user/Downloads/musistudio-claude-code-router-1.0.40.tgz
```

### 权限错误

```bash
# 修复脚本权限
chmod +x scripts/install_claude_code_router.sh
```

### 命令未找到

```bash
# 查看 npm 全局 bin 目录
npm bin -g

# 确认 ccr 是否已安装
npm list -g @musistudio/claude-code-router

# 如需将 npm global bin 加入 PATH
echo 'export PATH="$(npm bin -g):$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 安装失败

```bash
# 检查 npm 包是否完整
tar -tzf packages/musistudio-claude-code-router-*.tgz | head -20

# 重新下载离线包
./scripts/pack_claude_code_router.sh
```

---

## 安装前后对比

### 安装前

```bash
$ which ccr
# (无输出或找不到)

$ npm list -g @musistudio/claude-code-router
# (empty)
```

### 安装后

```bash
$ which ccr
/home/user/.npm-global/bin/ccr

$ ccr --version
1.0.40
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

使用 npm 管理版本：

```bash
# 安装指定版本
npm install -g @musistudio/claude-code-router@1.0.40

# 查看当前版本
npm list -g @musistudio/claude-code-router

# 升级到最新版
npm install -g @musistudio/claude-code-router@latest
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
ccr --version

# 显示帮助
ccr --help
```

---

## 重要文件位置

| 文件/目录 | 描述 |
|----------|------|
| `/tmp/claude_code_router_install_*.log` | 安装日志 |
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
| 官方文档 | [Claude Code Router Repository](https://github.com/musistudio/claude-code-router) |

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
cp ~/Downloads/musistudio-claude-code-router-*.tgz packages/ && \
./scripts/install_claude_code_router.sh && \
ccr --version

# 完全卸载
./scripts/install_claude_code_router.sh && \
source ~/.bashrc && \
echo "Uninstall complete"

# 诊断安装状态
echo "=== npm list ===" && \
npm list -g @musistudio/claude-code-router && \
echo "=== Version ===" && \
ccr --version 2>/dev/null && \
echo "=== PATH ===" && \
which ccr
```
