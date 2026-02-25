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
