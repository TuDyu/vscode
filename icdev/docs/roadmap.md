# IC-dev 实施路线图

> 来源: 2026-08-09 方案设计

```
Week 1-2  │ P0: 品牌与基础
          │ ├─ Git 双远程 + icdev-dev 分支
          │ ├─ product.json 全量修改 (25+ 字段)
          │ ├─ package.json 修改
          │ ├─ 图标资源替换 (win32/ico, linux/png)
          │ ├─ defaultChatAgent 初步改造
          │ └─ 验证编译 (npm run compile)
          │
Week 3-5  │ P1: AI 集成
          │ ├─ goose 扩展开发 (LM Provider + Chat Participant)
          │ ├─ goose 认证方案 (API Key)
          │ ├─ 移除 Copilot 扩展依赖
          │ ├─ COPILOT_VENDOR_ID 解耦 (7 文件)
          │ └─ 验证 Chat + Agent 功能
          │
Week 6-8  │ P2: 深度定制
          │ ├─ Inline Completions 解耦
          │ ├─ Sessions 窗口适配
          │ ├─ 扩展市场配置
          │ ├─ 打包流水线 (Windows + Linux)
          │ └─ 完整集成测试
          │
Week 9+   │ 持续维护
          │ ├─ recipes/icdev-sync-check 每周检查
          │ ├─ 月度上游合并
          │ ├─ goose 功能增强
          │ └─ 迭代反馈
```

## 关键决策记录

| 决策 | 选择 | 原因 |
|------|------|------|
| goose 认证 | Phase 1 API Key → Phase 2 OAuth | 原型阶段简化 |
| COPILOT_VENDOR_ID | 保留常量，修改行为 | 避免全局替换风险 |
| BYOK 提供商 | 保留并解耦为独立扩展 | 保留 OpenAI/Anthropic 等灵活性 |
| 上游跟踪 | patch 文件 + goose recipe | 可自动化、可审计 |
| 扩展市场 | 暂用 Open VSX | 开源兼容 |
