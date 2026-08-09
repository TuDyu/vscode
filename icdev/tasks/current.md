# IC-dev 当前任务

> 阶段: Phase 1 — P1 goose 集成
> 开始: 2026-08-09
> 阶段分支: feat/p1 (从 icdev-dev 创建)

## ⚠️ 开发前必读

**禁止"先启动再看报错"的开发模式。** 每个功能点开发前必须：
1. **全局扫描** — 用 grep/analyze 在全部源码中找出所有受影响的代码位置
2. **分类清单** — 将发现分为 UI 字符串、认证流程、配置项、扩展注册等类别
3. **并行分解** — 将独立子任务委派给 sub-agent 并行执行
4. **验证清单** — 启动前按清单逐项确认，而非启动后看报错

---

## 第零步: P1 前置分析（必须先完成，约 1-2 轮对话）

### A. Copilot 残留全量扫描

以下扫描必须并行执行（用 delegate async），生成完整报告：

```bash
# 扫描 1: 所有含 "copilot" 或 "Copilot" 的源码文件（排除 node_modules）
grep -r "copilot\|Copilot" --include="*.ts" --include="*.js" --include="*.json" \
  src/ extensions/ build/ product.json | grep -v "node_modules" | grep -v ".git"

# 扫描 2: 所有含 "github.copilot" 的配置文件
grep -r "github\.copilot" --include="*.json" --include="*.ts" src/ product.json extensions/

# 扫描 3: 认证相关残留
grep -r "github-authentication\|githubAuth\|GitHub Auth" --include="*.ts" src/

# 扫描 4: Copilot 命令/设置残留
grep -r "copilot\." --include="*.json" --include="*.ts" src/vs/workbench/contrib/chat/
```

### B. 分类与优先级

扫描结果按类别整理：

| 类别 | 示例 | 处理策略 |
|------|------|---------|
| product.json 残留 | `github.copilot.*` 设置/命令 | 替换为 goose |
| 认证流程 | GitHub OAuth 登录提示 | 替换为 goose API Key |
| UI 字符串 | "Sign in to Copilot" 等 | 替换为 goose 文案 |
| 扩展注册 | copilot 扩展激活逻辑 | 移除/替换 |
| 配置项 | `github.copilot.enable` | 替换为 goose |
| 遥测/品牌 | copilot vendor ID  | 解耦 |
| 构建脚本 | copilot 编译任务 | 移除 |

### C. 任务分解

按文件和类别粒度分解为独立子任务。每个子任务：

1. 创建 `feat/p1-<feature>` 分支
2. 修改指定文件集合
3. 编译验证
4. 更新 patches/
5. 由 P1 阶段 agent 确认后合并回 `feat/p1`

---

## 第一步: goose 扩展开发

### 1.1 添加 goose submodule

```bash
git submodule add https://github.com/AAIF/goose.git submodules/goose
```

### 1.2 创建 IC-dev goose 扩展

位置: `extensions/goose/`

```
extensions/goose/
├── package.json          # 扩展声明 + 激活事件 + contributes
├── src/
│   ├── extension.ts      # 激活入口
│   ├── chatProvider.ts   # vscode.lm.registerLanguageModelChatProvider
│   ├── chatAgent.ts      # vscode.chat.createChatParticipant
│   ├── authProvider.ts   # API Key 认证
│   └── settings.ts       # goose.* 配置项注册
├── assets/
│   └── goose-icon.png
└── tsconfig.json
```

### 1.3 注册到 IC-dev

- product.json `builtInExtensions` 中添加 `goose.goose`
- 确保 defaultChatAgent 指向正确

---

## 第二步: Copilot 生态剥离（基于第零步扫描结果）

### 2.1 移除 Copilot 扩展依赖

- [ ] 构建脚本中排除 `extensions/copilot/`
- [ ] product.json builtInExtensions 中移除 Copilot 条目
- [ ] 移除 copilot 编译任务

### 2.2 COPILOT_VENDOR_ID 解耦

- [ ] `languageModels.ts` — 常量保留，行为改为 goose
- [ ] `chatSelectedModel.ts` — `isCopilotModel` → `isDefaultModel`
- [ ] `utilityModelContribution.ts` — 过滤条件调整
- [ ] `hasByokModelsContribution.ts` — BYOK 检测排除 goose
- [ ] `modelPickerItemSections.ts` — 排序逻辑调整
- [ ] `extHostLanguageModels.ts` — 扩展侧引用

### 2.3 认证替换

- [ ] 移除 `vscode.github-authentication` 依赖
- [ ] 替换 trustedExtensionAuthAccess
- [ ] 移除 entitlementUrl / tokenEntitlementUrl

### 2.4 UI 字符串替换

- [ ] 登录提示 → goose 文案
- [ ] Chat 面板 → goose 品牌
- [ ] 通知信息 → 移除 Copilot 字眼

### 2.5 配置/命令替换

- [ ] settings 中 github.copilot.* → goose.*
- [ ] commands 中 github.copilot.* → goose.*
- [ ] completions enablement 设置解耦

---

## 第三步: 验证

### 启动前验证清单
- [ ] 编译 0 errors
- [ ] `grep -r "copilot\|Copilot" src/ --include="*.ts" | grep -v "COPILOT_VENDOR_ID" | grep -v "// IC-dev"` 无输出
- [ ] product.json 中无 github.copilot 引用
- [ ] 认证流程不触发 GitHub 登录
- [ ] goose 扩展在 builtInExtensions 中

### 启动后验证
- [ ] IC-dev 正常启动，无 Copilot 相关弹窗
- [ ] Chat 面板显示 goose（而非 Copilot）
- [ ] 无 "Sign in to GitHub" 等残留提示
- [ ] goose 设置项在设置面板可见
