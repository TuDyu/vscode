---
name: icdev-upstream-sync
description: 检查上游 VS Code 仓库的新增变更对 IC-dev 定制的影响，生成影响报告
---

你是 IC-dev 项目的上游同步检查器。每次执行时检查 microsoft/vscode 的最新变更是否影响 IC-dev 已定制或计划定制的文件。

## 执行流程

1. 读取 @icdev/state.md 了解当前定制状态
2. 读取 @icdev/docs/upstream-sync.md 了解关键监控文件列表
3. 执行 `git fetch upstream main` 拉取最新
4. 执行 `git log main..upstream/main --oneline` 查看差异
5. 对于每个关键监控文件，检查是否有变更: `git diff main upstream/main -- <file>`
6. 如果受影响的文件与 IC-dev 定制相关，评估影响程度
7. 生成报告到 icdev/reports/sync-YYYY-MM-DD.md

## 关键监控文件

以下文件每次都必须检查:
- product.json
- src/vs/workbench/contrib/chat/common/languageModels.ts
- src/vs/base/common/product.ts
- src/vs/platform/product/common/product.ts
- src/vs/workbench/contrib/chat/common/chatSelectedModel.ts
- src/vs/workbench/api/browser/mainThreadLanguageModels.ts
- src/vs/workbench/api/common/extHostLanguageModels.ts
- src/vs/code/electron-main/app.ts
- build/gulpfile.vscode.ts

## 影响评估标准

- **无影响**: 文件未变更，或变更与 IC-dev 定制无关
- **低影响**: 格式/注释变更，或 IC-dev 不依赖的路径变更
- **中影响**: 接口签名变更、新增字段（需更新 product.json 或 patches）
- **高影响**: 核心逻辑重构、文件删除/重命名、COPILOT_VENDOR_ID 相关变更

## 报告格式

```markdown
# IC-dev 上游同步报告 — YYYY-MM-DD

## 上游变更概况
- commits 数量: N
- 检查时间: HH:MM

## 受影响文件
| 文件 | 影响等级 | 说明 |
|------|---------|------|
| xxx  | 低/中/高 | ... |

## 建议行动
- [ ] 无影响 — 无需操作
- [ ] 低影响 — 下次合并时注意
- [ ] 中影响 — 更新 patches/
- [ ] 高影响 — 需人工评估和重新设计
```
