# IC-dev 当前任务

> 阶段: Phase 1 — P0 品牌化
> 开始: 2026-08-09

## 第一步: Git 环境设置

```bash
# 添加上游远程
git remote add upstream https://github.com/microsoft/vscode.git

# 创建 icdev-dev 分支 (基于当前 main)
git checkout -b icdev-dev

# 将框架文件提交到 icdev-dev
git add .goosehints icdev/ .agents/ recipes/
git commit -m "IC-dev: initialize project framework and documentation"
```

## 第二步: P0.1 product.json 品牌化

修改 product.json 以下字段:
- nameShort: "IC-dev"
- nameLong: "IC-dev"
- applicationName: "icdev"
- dataFolderName: ".icdev"
- urlProtocol: "icdev"
- win32MutexName: "icdev"
- win32DirName: "IC-dev"
- win32NameVersion: "IC-dev"
- win32RegValueName: "ICdev"
- serverApplicationName: "icdev-server"
- serverDataFolderName: ".icdev-server"
- tunnelApplicationName: "icdev-tunnel"
- linuxIconName: "icdev"
- reportIssueUrl: (更新为 IC-dev 仓库)

## 第三步: P0.2 defaultChatAgent 改造

修改 product.json 的 defaultChatAgent:
- extensionId → goose 扩展 ID
- chatExtensionId → goose 扩展 ID
- provider → goose provider 配置
- 移除 Copilot 专属 URL 字段

## 第四步: P0.3 验证

```bash
npm run compile
```
