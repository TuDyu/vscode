# IC-dev 项目状态

> 最后更新: 2026-08-09 17:42
> 当前阶段: Phase 1 — P1 AI 集成
> 活跃分支: icdev-dev
> 上游 HEAD: 97f9937a426 | IC-dev HEAD: d8d99004ffc

## 当前进度

### P0: 品牌化 (已完成 ✅)
- [x] 配置 Git 双远程 (origin → TuDyu/vscode, upstream → microsoft/vscode)
- [x] 创建 icdev-dev 分支 + 框架文件提交推送
- [x] product.json 品牌化 (nameShort/nameLong/applicationName 等 25+ 字段)
- [x] package.json name 修改 (跳过 — name 仅用于 npm, 不影响产品名)
- [x] defaultChatAgent 初步改造 (替换为 goose 扩展 ID)
- [~] 图标资源替换 (跳过, 后续处理) (win32/ico, linux/png)
- [x] 验证编译: `gulp compile-client` → 8094 JS 文件, 0 errors
- [x] 10/10 native 模块编译成功 + IC-dev 零错误启动
- [x] Rust 1.97.1 + cargo 1.97.1

### P1: AI 集成 (待启动)
- [ ] 第零步: 前置分析 (Copilot 残留全量扫描)
- [ ] 第一步: goose 扩展开发 (extensions/goose/)
- [ ] 第二步: Copilot 生态剥离
- [ ] 第三步: 验证

> ⚠ P1 首次尝试被退回：agent 违反开发纪律（先启动再看报错、未全局扫描、未委派 sub-agent、Copilot 残留未清理）。feat/p1 分支作废，已切回 icdev-dev。当前 tasks/current.md 已重写，加入强制前置分析步骤。

### P2: 深度定制 (未开始)
- [ ] Inline Completions 解耦
- [ ] Sessions 窗口适配
- [ ] 扩展市场配置
- [ ] 打包流水线 (Windows + Linux)

## 最近决策

| 日期 | 决策 | 理由 |
|------|------|------|
| 2026-08-09 | 产品名 IC-dev | 用户指定 |
| 2026-08-09 | 深度方案 B | 中度定制 + 开源 AI 替换 |
| 2026-08-09 | patch-based 组织 | 便于跟踪上游变更 |
| 2026-08-09 | .goosehints + AGENTS.md 并存 | 职责分离：VS Code 指南 vs IC-dev 上下文 |
| 2026-08-09 | 两层工作流：阶段级(大阶段分支→用户确认→合并主线) + 功能点级(子分支→阶段 agent 自主确认→交付可体验更新) | 小任务由阶段 agent 并行开发并自主合并(鼓励 worktree+sub-agent)，大阶段完成后交付可体验更新，用户实际体验并同意后才合并回 icdev-dev |
| 2026-08-09 | 开发纪律强制：禁止"启动看报错再修" + 全局扫描 + 并行委派 + 启动前验证清单 | P1 首次尝试因违反纪律被退回，现写入 .goosehints / architect / reviewer 作为硬性约束 |

## 当前阻塞
- 无

## 已完成的里程碑
- [x] 2026-08-09: VS Code 源码架构分析完成
- [x] 2026-08-09: Copilot 生态深度分析完成
- [x] 2026-08-09: 定制实施方案制定完成
- [x] 2026-08-09: goose 框架下的长期任务架构设计完成
- [x] 2026-08-09: 环境搭建完成 (MSVC + Rust + native 模块)
