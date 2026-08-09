# IC-dev 架构分析报告 (摘要)

> 完整分析于 2026-08-09 完成
> 详情见对话记录或 icdev/docs/customization-index.md

## 工程概况

- 上游: microsoft/vscode v1.133.0, MIT 许可
- 源码: TypeScript (主) + Rust (CLI)
- 构建: esbuild + gulp + electron

## 核心架构

```
src/vs/
├── base/          通用工具和跨平台抽象 (39K+ 行)
├── platform/      平台服务 + DI 基础设施 (120+ 服务)
├── editor/        编辑器核心 (Monaco)
├── workbench/     主工作台 UI (100+ contrib 模块)
├── code/          Electron 主进程
└── sessions/      Agent Sessions 窗口
```

关键设计模式: DI, Contribution Model, 分层架构

## 品牌信息分布

所有品牌信息集中通过 `product.json` 控制:
- IProductService 接口 → 运行时读取
- 窗口标题/About/对话框自动使用 nameLong
- 构建脚本通过模板变量 @@NAME@@ 等引用

## AI/Copilot 架构

- 扩展: extensions/copilot/ (200+ 文件)
- LM Provider: 通过 vscode.lm.registerLanguageModelChatProvider() 注册
- BYOK: 9 个内置提供商 (OpenAI, Anthropic, Ollama 等)
- COPILOT_VENDOR_ID: 7 个文件硬编码 'copilot'
- defaultChatAgent: 23+ 处引用

## goose 接入方案

goose 可复用 VS Code 开放接口:
- vscode.lm.registerLanguageModelChatProvider('goose', provider)
- vscode.chat.createChatParticipant('goose', handler)
- 自定义 IAuthenticationProvider
