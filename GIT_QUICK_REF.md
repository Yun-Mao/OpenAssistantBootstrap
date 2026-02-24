# 🚀 Git工作流快速参考

## 一句话总结
```bash
# 开始 → 开发 → 提交 → 审核 → 合并 → 清理
./git-workflow.sh start feat/name
git commit -m "feat: ..."
./git-workflow.sh submit "Description"
# [PR审核合并]
./git-workflow.sh finalize
```

## 常用命令

### 创建feature分支
```bash
./scripts/git-workflow.sh start feat/your-feature-name
```

### 提交代码到远端
```bash
./scripts/git-workflow.sh submit "Your feature description"
```

### 合并后清理
```bash
./scripts/git-workflow.sh finalize
```

## 提交消息格式

### 功能添加
```bash
git commit -m "feat: add new feature

- Feature detail 1
- Feature detail 2"
```

### Bug修复
```bash
git commit -m "fix: resolve issue description

- What was wrong
- How it's fixed"
```

### 文档更新
```bash
git commit -m "docs: update documentation"
```

### 其他
```bash
git commit -m "chore: maintain project"
git commit -m "refactor: improve code structure"
```

## 快速查询

| 需求 | 命令 |
|------|------|
| 创建feature分支 | `./git-workflow.sh start feat/name` |
| 推送到远端 | `./git-workflow.sh submit "desc"` |
| PR合并后清理 | `./git-workflow.sh finalize` |
| 查看帮助 | `./git-workflow.sh --help` |
| 查看完整文档 | `cat WORKFLOW.md` |

## 下次告诉我

只需说：
- "提交XXX功能" → 我自动执行start、开发指导、submit
- "git start feat/xxx" → 创建分支
- "git submit" → 推送到远端
- "git finalize" → 清理

无需重复解释整个流程！✨
