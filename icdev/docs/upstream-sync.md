# IC-dev 上游同步策略

## 核心原则

- main 分支保持干净，仅跟踪上游 microsoft/vscode
- icdev-dev 分支承载所有定制
- 所有对上游文件的修改通过 patches/ 目录管理
- 框架文件 (.goosehints, icdev/, .agents/, recipes/) 直接提交

## Git 远程配置

```bash
# 上游 (微软官方)
git remote add upstream https://github.com/microsoft/vscode.git

# 推送目标 (IC-dev 仓库)
# origin 已指向 TuDyu/vscode，可以直接使用或重命名
```

## 合并上游流程

```bash
# 1. 拉取上游最新
git checkout main
git pull upstream main

# 2. 合并到 icdev-dev
git checkout icdev-dev
git merge main

# 3. 解决冲突 + 重新应用 patches
git am patches/*.patch

# 4. 验证编译
npm run compile

# 5. 推送
git push origin icdev-dev
```

## 关键监控文件

以下是受 IC-dev 定制影响的文件，每次上游合并时必须重点检查：

| 文件 | 影响 | 检查频率 |
|------|------|---------|
| `product.json` | 品牌配置（新增字段） | 每次合并 |
| `src/vs/workbench/contrib/chat/common/languageModels.ts` | COPILOT_VENDOR_ID、LM Provider 接口 | 每次合并 |
| `src/vs/base/common/product.ts` | IProductConfiguration 接口 | 每次合并 |
| `src/vs/platform/product/common/product.ts` | productService 默认值 | 每次合并 |
| `src/vs/workbench/contrib/chat/common/chatSelectedModel.ts` | isCopilotModel 逻辑 | 每次合并 |
| `src/vs/workbench/api/browser/mainThreadLanguageModels.ts` | LM Provider 注册 | 每次合并 |
| `src/vs/workbench/api/common/extHostLanguageModels.ts` | 扩展侧 LM API | 每次合并 |
| `src/vs/code/electron-main/app.ts` | 主进程入口 | 每月 |
| `src/vs/workbench/browser/parts/titlebar/windowTitle.ts` | 窗口标题 | 每季度 |
| `src/vs/workbench/electron-browser/desktop.main.ts` | 桌面主入口 | 每季度 |
| `build/gulpfile.vscode.ts` | 打包配置 | 每次发布 |
| `extensions/copilot/` | Copilot 扩展（将被移除） | N/A |
| `resources/win32/code.ico` | Windows 图标 | 每季度 |
| `resources/linux/code.png` | Linux 图标 | 每季度 |

## Sync Recipe

上游同步检查通过 `recipes/icdev-sync-check.yaml` 自动执行。
建议每周一运行一次，或在每次上游合并前手动触发。
