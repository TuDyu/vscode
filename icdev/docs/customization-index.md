# IC-dev 定制点索引

> 来源: 2026-08-09 深度分析
> 完整报告: @icdev/docs/analysis-report.md

## 复杂度分级

### 🔴 高复杂度 (需深入设计)
| ID | 定制点 | 核心文件 | 说明 |
|----|--------|---------|------|
| A1 | 移除 Copilot 扩展 + goose 接入 | extensions/copilot/ (移除), extensions/goose/ (新建) | 200+ 文件受影响 |
| A2 | defaultChatAgent 替换 | product.json, 23+ 引用位置 | 认证、授权、UI 全链路 |
| A3 | 认证体系替换 | 移除 GitHub/MS OAuth → goose API Key/OAuth | |
| A4 | Inline Completions 解耦 | inlineCompletionsModel.ts | Copilot 设置硬编码 |

### 🟡 中复杂度
| ID | 定制点 | 核心文件 | 说明 |
|----|--------|---------|------|
| B1 | product.json 全量修改 | product.json | ~30 字段 |
| B2 | LM Provider 注册 | goose extension | `vscode.lm.registerLanguageModelChatProvider()` |
| B3 | COPILOT_VENDOR_ID 处理 | languageModels.ts 等 7 文件 | 保留常量，修改行为 |
| B4 | BYOK 提供商保留 | 从 Copilot 解耦为独立扩展 | |
| B5 | 打包配置 | gulpfile.vscode.ts | 品牌模板变量 |

### 🟢 低复杂度
| ID | 定制点 | 说明 |
|----|--------|------|
| C1 | 图标替换 | 直接替换资源文件 |
| C2 | 窗口标题/About | 自动读取 product.json |
| C3 | 数据目录/URL Protocol | product.json 字段 |
| C4 | Shell 脚本 | 模板变量 `@@APPNAME@@` |

## COPILOT_VENDOR_ID 硬编码位置

共 7 个文件，关键词 `'copilot'`:

1. `src/vs/workbench/contrib/chat/common/languageModels.ts:49` — 常量定义 + 4 处使用
2. `src/vs/workbench/contrib/chat/common/chatSelectedModel.ts:9,240` — isCopilotModel
3. `src/vs/workbench/contrib/chat/browser/utilityModelContribution.ts:10,41,70` — 过滤
4. `src/vs/workbench/contrib/chat/browser/hasByokModelsContribution.ts:16,110` — BYOK 检测
5. `src/vs/workbench/contrib/chat/browser/widget/input/modelPicker/modelPickerItemSections.ts:337-338` — 排序
6. `src/vs/workbench/api/common/extHostLanguageModels.ts:21` — 扩展侧引用

## defaultChatAgent 使用位置

共 23+ 处，分布在:
- product.json (定义)
- product.ts (默认值)
- abstractExtensionManagementService.ts (特殊处理)
- extensionGalleryService.ts (置顶/废弃)
- completionsEnablement.ts (补全开关)
- inlineCompletionsModel.ts (补全实例化)
- chatActions.ts (菜单/命令)
- mainThreadLanguageModelTools.ts (工具判断)
- sessionsSetUpService.ts (登录 UI)
- cloudSandboxApiService.ts (远程代理)
- configurationRegistry.ts (扩展统一)

## VS Code 开放接口 (goose 可复用)

| 接口 | 用途 |
|------|------|
| `vscode.lm.registerLanguageModelChatProvider()` | 注册 goose 为 LLM 提供商 |
| `vscode.chat.createChatParticipant()` | 注册 goose agent 参与者 |
| `IAuthenticationProvider` | goose 认证 |
| `IChatAgentRegistry.registerAgent()` | goose agent 注册 |
