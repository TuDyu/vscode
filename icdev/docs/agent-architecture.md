# IC-dev Agent 架构设计

> 状态: 草案
> 创建: 2026-08-09

## 核心理念

IC-dev 的 AI 能力通过 **Agent** 提供。每个 Agent 是一个独立的 CLI 程序，IC-dev 通过 VS Code 扩展与 Agent 通信。

Agent 之间互不依赖——你可以只用 goose，也可以同时用 goose + IC-goose + 其他 Agent。

## 三层架构

```
┌─────────────────────────────────────────────────┐
│  GUI 层 (extensions/icdev-agent/)               │
│  VS Code 扩展，负责：                             │
│  - Chat 面板 UI                                  │
│  - Agent 选择器                                  │
│  - 认证管理                                      │
│  - 与 Agent CLI 通信                             │
└──────────────────┬──────────────────────────────┘
                   │ 发现 & 通信
┌──────────────────┴──────────────────────────────┐
│  配置层 (icdev/agents/)                          │
│  每个 Agent 的 manifest 文件，描述：              │
│  - agent id, 名称, 图标                          │
│  - CLI 入口点                                    │
│  - 认证方式                                      │
│  - 构建信息                                      │
└──────────────────┬──────────────────────────────┘
                   │ 引用
┌──────────────────┴──────────────────────────────┐
│  源码层 (submodules/<agent-name>/)               │
│  Agent 的完整源码 (git submodule)                │
│  - goose     → goose 官方仓库                    │
│  - ic-goose  → 自定义 goose fork                 │
│  - <future>  → 其他 Agent                       │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
IC-dev/
├── submodules/                    # Agent 源码 (git submodules)
│   ├── goose/                     # → github.com/AAIF/goose.git
│   └── ic-goose/                  # → github.com/TuDyu/ic-goose.git (未来)
│
├── extensions/                    # VS Code 内置扩展
│   ├── icdev-agent/               # Agent 管理扩展
│   │   ├── package.json           #   注册 Chat Participant + LM Provider
│   │   ├── src/
│   │   │   ├── agentRegistry.ts   #   发现 & 加载 agent manifest
│   │   │   ├── agentHost.ts       #   管理 agent CLI 进程
│   │   │   └── chatProvider.ts    #   实现 vscode.lm.* 接口
│   │   └── ...
│   └── ...                        #   其他扩展 (git, markdown, etc.)
│
├── icdev/agents/                  # Agent manifest 配置
│   ├── goose.json                 #   goose 的 manifest
│   └── ic-goose.json              #   ic-goose 的 manifest (未来)
│
└── build/                         # 构建系统
    └── gulpfile.agents.ts         # Agent 选择性打包逻辑
```

## Agent Manifest 格式

`icdev/agents/goose.json`:

```jsonc
{
  "id": "goose",
  "name": "Goose",
  "description": "Open-source AI agent by AAIF",
  "version": "1.0.0",
  
  // 源码位置 (相对于项目根)
  "submodule": "submodules/goose",
  
  // CLI 入口
  "cli": {
    "build": "cargo build --release",        // 如何编译 CLI
    "binary": "target/release/goose",         // 编译产物路径
    "args": ["session"]                       // 启动参数
  },
  
  // 认证
  "auth": {
    "type": "api_key",                        // api_key | oauth | none
    "setting": "icdev.goose.apiKey",          // VS Code 设置项
    "env": "GOOSE_API_KEY"                    // 环境变量
  },
  
  // GUI 配置
  "gui": {
    "icon": "submodules/goose/assets/icon.png",
    "chatName": "Goose Chat",
    "models": ["gpt-4o", "claude-sonnet-4"]   // 支持的模型列表
  },
  
  // 打包
  "packaging": {
    "default": true,                          // 默认是否打包
    "platforms": ["win32", "linux"],          // 支持的平台
    "bundleBinary": true                      // 是否将 CLI 二进制打入安装包
  }
}
```

## Agent 发现流程

```
IC-dev 启动
  │
  ├─ icdev-agent 扩展激活
  │
  ├─ 扫描 icdev/agents/*.json
  │    ├─ goose.json     → agent "goose"
  │    └─ ic-goose.json  → agent "ic-goose" (如存在)
  │
  ├─ 对每个 agent:
  │    ├─ 检查 CLI 二进制是否存在
  │    │   ├─ 存在 → 启动 agentHost 进程
  │    │   └─ 不存在 → 标记为 "需编译" / 回退到远程 API
  │    │
  │    └─ 注册到 agentRegistry
  │
  └─ Chat 面板:
       ├─ 显示 agent 选择器
       └─ 用户选择 agent → 切换通信目标
```

## 构建系统集成

```bash
# 编译所有 agent CLI
npm run build-agents

# 打包 IC-dev + goose
npm run gulp vscode-win32-x64 -- --agents goose

# 打包 IC-dev + goose + ic-goose
npm run gulp vscode-win32-x64 -- --agents goose,ic-goose

# 仅打包基础 IC-dev (无 agent)
npm run gulp vscode-win32-x64
```

## 持久指令 (Persistent Instructions)

goose CLI 通过 `GOOSE_MOIM_MESSAGE_FILE` 环境变量实现**每轮注入的不可遗忘规则**。
IC-dev 内置 goose 不使用环境变量，改为文件自动发现：

### 需求来源
- `.goosehints` 仅在会话启动时加载一次，长对话中可能被上下文挤出
- 部分规则（如"永远不叫错产品名"）需要在每轮对话中持续生效
- 环境变量方式不适合 GUI 编辑器场景

### IC-dev 实现方案

| goose CLI | IC-dev goose 扩展 |
|-----------|------------------|
| `GOOSE_MOIM_MESSAGE_FILE` 环境变量 | 固定路径文件自动发现 |
| 需要用户手动配置 | 扩展自动加载 |
| 每轮注入 system prompt | 扩展在每次请求前注入 |

**文件位置**: `.goose/always.md`（项目根目录，由 goose 扩展自动发现）

**goose.json manifest 中的配置**:
```jsonc
{
  "persistentInstructions": ".goose/always.md",  // 可选，默认为此路径
}
```

**扩展行为**:
1. icdev-agent 扩展激活时查找 `.goose/always.md`
2. 如果存在，将内容缓存
3. 每次向 agent CLI 发送请求时，将持久指令注入到 system prompt 中
4. 文件变化时自动重新加载（watch 机制）

### `.goose/always.md` 示例
```markdown
你是 IC-dev 项目的开发助手。
- 产品名永远用 "IC-dev"，禁止使用 "Code - OSS" 或 "Visual Studio Code"
- 修改代码后更新 icdev/state.md
- 品牌修改通过 product.json + patches/ 管理
```

### 实现阶段
- [ ] Phase 2a: 在 `extensions/icdev-agent/` 中实现 `.goose/always.md` 读取
- [ ] Phase 2a: 每次 LLM 请求前注入内容
- [ ] Phase 2a: 实现文件 watch 热更新

## Agent 通信协议

```
IC-dev (Extension Host)          Agent CLI (独立进程)
       │                              │
       │  stdin: JSON-RPC request     │
       ├─────────────────────────────>│
       │                              │
       │  stdout: JSON-RPC response   │
       │<─────────────────────────────┤
       │                              │
       │  或 HTTP localhost (备用)     │
       │<────────────────────────────>│
```

## IC-goose 的定位

IC-goose 是你对 goose 的自定义 fork。它与 goose 的关系：

| 维度 | goose | IC-goose |
|------|-------|----------|
| 上游 | AAIF/goose | 基于 goose fork |
| 定制 | 无 | 自定义模型、prompt、工具 |
| GUI | 标准 goose chat | 可能有自定义 UI |
| 维护 | 由 AAIF 维护 | 由你维护，定期同步上游 |

两者都是独立的 git submodule，IC-dev 对它们一视同仁。

## 实施路线

### Phase 2a: goose 基础集成 (当前优先)
- [ ] 添加 `submodules/goose` (git submodule)
- [ ] 创建 `icdev/agents/goose.json`
- [ ] 创建 `extensions/icdev-agent/`
- [ ] 实现 agentRegistry (discover + load manifest)
- [ ] 实现 agentHost (spawn CLI process)
- [ ] 实现 chatProvider (vscode.lm + vscode.chat)
- [ ] 在 IC-dev 中可用 goose chat

### Phase 2b: 打包流水线
- [ ] 修复 native 模块编译
- [ ] gulp packaging 任务支持 --agents 参数
- [ ] Windows .exe 安装包
- [ ] Linux .deb/.AppImage

### Phase 2c: 多 Agent 支持
- [ ] Agent 选择器 UI
- [ ] IC-goose 创建 & 集成
- [ ] 第三方 agent 添加文档
