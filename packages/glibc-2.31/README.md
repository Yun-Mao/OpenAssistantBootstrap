# Patch 依赖包

将 patchelf 和 glibc 2.31 的离线包放在此目录或 packages/ 根目录，
安装脚本会自动识别并在需要时安装。

安装脚本默认路径：$HOME/.patch-tools

推荐命名：

- patchelf-<version>-linux-x64.tar.gz
- glibc-2.31-linux-x64.tar.gz

要求：

- patchelf 包需包含可执行文件 patchelf
- glibc 包需包含 lib/ld-linux-x86-64.so.2
