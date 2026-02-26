# Claude Code Router 脚本完整使用指南

## 脚本概览

本项目提供两个互相配合的脚本来完成 Claude Code Router 的打包和安装：

| 脚本 | 功能 | 使用场景 |
|------|------|--------|
| `pack_claude_code_router.sh` | 从 npm 官方源下载并打包 | 在有网络的机器上，生成离线包供离线环境使用 |
| `install_claude_code_router.sh` | 安装 Claude Code Router | 在离线或任何需要安装的机器上，交互式安装 |

## 工作流程

### 场景 1：完整离线部署（推荐）

#### 步骤 1: 在有网络的机器上打包

```bash
# 进入项目目录
cd OpenAssistantBootstrap

# 给脚本赋予执行权限
chmod +x scripts/pack_claude_code_router.sh

# 运行打包脚本
./scripts/pack_claude_code_router.sh
```

**交互流程：**

1. **环境检查** - 检测 npm 工具
2. **执行下载** - 从 npm 官方源下载最新版本
3. **保存文件** - 自动保存到 `packages/` 目录

**输出示例：**
```
[SUCCESS] 包已保存: ./packages/musistudio-claude-code-router-1.0.40.tgz (2.5M)
[INFO] MD5: a1b2c3d4e5f6...
[INFO] 内容预览:
      package/
      package/package.json
      package/bin/claude-code-router
      ...
```

#### 步骤 2: 将离线包转移到目标机器

```bash
# 方式 1：使用 U 盘或移动硬盘
cp packages/musistudio-claude-code-router-*.tgz /mnt/usb/

# 方式 2：使用 scp
scp packages/musistudio-claude-code-router-*.tgz user@offline-host:/home/user/

# 方式 3：手动下载
# 从 npm 官方源: https://registry.npmjs.org/@musistudio/claude-code-router
```

#### 步骤 3: 在离线机器上安装

```bash
# 进入项目目录
cd OpenAssistantBootstrap

# 给脚本赋予执行权限
chmod +x scripts/install_claude_code_router.sh

# 运行安装脚本
./scripts/install_claude_code_router.sh
```

**交互流程：**

1. **选择操作** 菜单：
   ```
   1. 安装 Claude Code Router
   2. 卸载 Claude Code Router
   0. 退出
   ```
   选择 `1` 进行安装

2. **检测现有安装** - 如果已安装，显示版本

3. **选择离线包** - 自动在 `packages/` 目录查找 `.tgz` 文件，或手动指定路径

4. **确认安装信息** - 显示离线包路径和安装方式，最后确认

5. **npm install -g** - 执行全局安装

6. **验证安装** - 运行 `ccr --version` 验证

7. **完成** - 显示使用提示

#### 步骤 4: 验证安装

```bash
# 应用环境变量配置
source ~/.bashrc

# 验证安装
claude-code-router --version
claude-code-router --help
```

---

### 场景 2：在线直接安装（快速）

如果目标机器有网络，可直接安装而不需要打包：

```bash
# 直接从 npm 官方源安装
npm install -g @musistudio/claude-code-router

# 或使用脚本安装
./scripts/install_claude_code_router.sh
```

---

## 打包脚本详细说明（pack_claude_code_router.sh)

### 打包脚本的工作原理

打包脚本使用 `npm pack` 从 npm 官方源下载 Claude Code Router 的最新版本：

```
npm pack @musistudio/claude-code-router
↓
packages/musistudio-claude-code-router-<version>.tgz
```

### 打包脚本的环境要求

| 工具 | 最小版本 | 必需？ |
|------|---------|-------|
| bash | 4.0+ | ✅ |
| tar | 任意 | ✅ |
| grep, sed | 任意 | ✅ |
| npm | 8.0.0+ | ✅ |

### 打包脚本的输出

打包脚本将离线包保存到：
```
./packages/
└── musistudio-claude-code-router-<version>.tgz
```

---

## 安装脚本详细说明（install_claude_code_router.sh）

### 主菜单选项

```
1. 安装 Claude Code Router         - 完整的交互式安装流程
2. 卸载 Claude Code Router         - 通过 npm uninstall -g 移除
0. 退出
```

### 安装流程（选项 1）

#### 步骤 1: 检查环境要求

验证 Node.js 和 npm 已安装且版本满足要求。

#### 步骤 2: 检测现有安装

通过 `npm list -g @musistudio/claude-code-router` 检查是否已安装。

#### 步骤 3: 选择离线包

脚本自动在 `packages/` 目录查找 `musistudio-claude-code-router-*.tgz` 文件，
用户也可手动输入路径。

#### 步骤 4: 确认安装信息

显示离线包路径和安装命令，最后确认。

#### 步骤 5: 执行 npm 安装

```bash
npm install -g "<path/to/musistudio-claude-code-router-*.tgz>"
```

#### 步骤 6: 验证安装

运行 `ccr --version` 确认安装成功。

### 卸载流程（选项 2）

```bash
npm uninstall -g @musistudio/claude-code-router
```

---

## 故障排除

### 打包脚本问题

#### 问题 1: "npm 未安装"

**原因：** npm 不在 PATH 中

**解决方案：**
```bash
# 检查 npm
which npm
npm --version

# 如果未安装，请先安装 npm
# 访问 https://nodejs.org/ 下载安装
```

#### 问题 2: "网络连接失败"

**原因：** 无法连接到 npm 官方源

**解决方案：**
1. 检查网络连接
2. 检查 npm 镜像配置：`npm config get registry`
3. 使用代理（如果需要）：`npm config set proxy http://proxy:port`

#### 问题 3: "磁盘空间不足"

**原因：** 临时目录空间不足

**解决方案：**
```bash
# 检查磁盘空间
df -h /tmp

# 清理临时目录
rm -rf /tmp/ccr_pack_*
rm -rf /tmp/pack_claude_code_router_*
```

### 安装脚本问题

#### 问题 1: "找不到压缩包"

**原因：** `packages/` 目录下没有有效的 Claude Code Router 包

**解决方案：**
1. 确保压缩包已放入 `packages/` 目录
2. 检查文件名是否匹配（见上文模式列表）
3. 手动指定完整路径

```bash
# 检查 packages 目录内容
ls -la packages/

# 手动指定路径时输入类似
/path/to/packages/musistudio-claude-code-router-1.0.40.tgz
```

#### 问题 2: "权限拒绝"

**原因：** 目标路径权限问题或目录被占用

**解决方案：**
```bash
# 检查目标路径权限
ls -ld ~/claude-code-router

# 如果需要，删除旧目录
rm -rf ~/claude-code-router

# 重新运行安装脚本
./scripts/install_claude_code_router.sh
```

#### 问题 3: "验证失败"

**原因：** 安装目录的 bin 子目录缺少必要文件

**解决方案：**
1. 检查压缩包是否完整
2. 验证压缩包结构
3. 重新获取压缩包

```bash
# 列出压缩包内容
tar -tzf packages/musistudio-claude-code-router-*.tgz | head -20

# 检查是否包含 bin/claude-code-router
tar -tzf packages/musistudio-claude-code-router-*.tgz | grep "bin/claude-code-router"
```

#### 问题 4: "版本信息无法获取"

**原因：** Claude Code Router 可执行文件无法运行

**解决方案：**
```bash
# 手动运行可执行文件
~/claude-code-router/bin/claude-code-router --version

# 如果报告权限不足或库缺失
chmod +x ~/claude-code-router/bin/claude-code-router
ldd ~/claude-code-router/bin/claude-code-router
```

---

## 最佳实践

### 1. 打包建议

✅ **推荐做法：**
- 使用 **npm tarball** 方式获取官方版本（快速、可靠）
- 定期更新离线包（获取安全补丁和新功能）
- 在有网络的机器上保存多个版本备用

❌ **避免：**
- 手工编辑压缩包内容（可能破坏结构）
- 混合不同版本的文件
- 删除 package.json 或可执行文件

### 2. 安装建议

✅ **推荐做法：**
- 始终使用脚本的默认路径（便于管理）
- 安装前备份旧版本
- 完成安装后立即验证版本号
- 在配置较低的环境测试打包

❌ **避免：**
- 将安装路径设置在系统目录
- 手工修改 ~/.bashrc（使用脚本自动配置）
- 同时运行多个安装实例

### 3. 团队协作

对于团队部署：

```bash
# 1. 在中心机器打包一次
./scripts/pack_claude_code_router.sh

# 2. 生成md5校验和列表
md5sum packages/musistudio-claude-code-router-*.tgz > checksum.txt

# 3. 分发压缩包和脚本给其他团队成员
# 4. 每个成员在自己的机器上安装
./scripts/install_claude_code_router.sh
```

---

## 常见命令速查

```bash
# 快速打包
./scripts/pack_claude_code_router.sh

# 快速安装（使用所有默认值）
./scripts/install_claude_code_router.sh
# 全部选择 1 → 直接回车 → y

# 查看已安装版本
source ~/.bashrc
claude-code-router --version

# 卸载
./scripts/install_claude_code_router.sh
# 选择 2

# 查看打包文件
ls -lh packages/

# 验证压缩包
md5sum packages/*.tgz
tar -tzf packages/*.tgz | head -20
```

---

## 获取帮助

```bash
# 查看脚本帮助
./scripts/pack_claude_code_router.sh --help
./scripts/install_claude_code_router.sh --help

# 查看详细文档
cat docs/claude_code_router/INSTALL_GUIDE.md
cat docs/claude_code_router/INTERACTIVE_INSTALL.md
cat docs/claude_code_router/QUICK_REFERENCE.md

# 查看日志
cat /tmp/pack_claude_code_router_*.log
cat /tmp/claude_code_router_install_*.log
```

---

## 总结

| 任务 | 脚本 | 命令 |
|------|------|------|
| 生成离线包 | pack_claude_code_router.sh | `./scripts/pack_claude_code_router.sh` |
| 安装工具 | install_claude_code_router.sh | `./scripts/install_claude_code_router.sh` |
| 卸载工具 | install_claude_code_router.sh | `./scripts/install_claude_code_router.sh` → 选择 2 |
| 更新配置 | install_claude_code_router.sh | `./scripts/install_claude_code_router.sh` → 选择 3 |
| 查看帮助 | 任意 | `./scripts/<script_name>.sh --help` |

---

**最后更新：2026 年 2 月**
