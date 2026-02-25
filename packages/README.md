# packages/

在这个目录中放置离线安装包，安装脚本会自动识别。

## Node.js

支持的格式：
- `node-v16.20.0-linux-x64.tar.gz`
- `node-v16.20.0-linux-x64.tar.xz`
- `node-v16.20.0-linux-x64.zip`

下载链接：
- 官方：https://nodejs.org/dist/
- 国内镜像：https://mirrors.aliyun.com/nodejs-release/

## Claude Code

由 `scripts/fetch_claude_code.sh` 自动生成，命名规则：

```
claude-code-<VERSION>-<PLATFORM>.tar.gz

示例:
  claude-code-v2.1.56-linux-x64.tar.gz
  claude-code-v2.1.56-linux-arm64.tar.gz
```

在有网络的机器上运行以下命令获取：

```bash
chmod +x scripts/fetch_claude_code.sh
./scripts/fetch_claude_code.sh
```

## Claude Code Patch 依赖（可选）

某些 CentOS 7 / 低版本 glibc 环境需要 patch Claude Code 才能运行。
当安装脚本检测到需要 patch 时，会自动尝试安装以下离线包：

- patchelf
- glibc 2.31

请将离线包放入 packages/ 目录，脚本会自动识别：

```
patchelf-<version>-linux-x64.tar.gz
glibc-2.31-linux-x64.tar.gz
```

离线包需要包含以下结构（示例）：

- patchelf 包中包含可执行文件 `patchelf`
- glibc 包中包含 `lib/ld-linux-x86-64.so.2`
