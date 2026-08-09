# IC-dev 环境搭建说明

## 前提
- Node.js 24.18.0 (已安装)
- Git Bash 可用
- 264GB 磁盘空间

## 首次搭建

```bash
# 1. 安装依赖 (跳过 native 模块编译)
npm install --ignore-scripts

# 2. 安装 build 依赖
cd build && npm install --ignore-scripts && cd ..

# 3. 复制 esbuild 到 root
cp -r build/node_modules/esbuild node_modules/esbuild

# 4. 运行 postinstall
npm run postinstall

# 5. 安装 Electron
npm install electron@42.8.0 --no-save

# 6. 设置 Electron 启动目录
mkdir -p .build/electron
cp -r node_modules/electron/dist/* .build/electron/
echo "42.8.0" > .build/electron/version

# 7. Stub native 模块 (无 MSVC C++ 编译环境)
# 见 scripts/stub_native_modules.sh

# 8. 编译
npx gulp compile-client

# 9. 运行
VSCODE_SKIP_PRELAUNCH=1 ./scripts/code.bat
```

## 日常开发

```bash
# 编译
npx gulp compile-client

# 运行
VSCODE_SKIP_PRELAUNCH=1 ./scripts/code.bat

# 完整编译 + 扩展
npm run compile  # 需要 Copilot 依赖也安装
```

## 已知问题

| 问题 | 影响 | 原因 |
|------|------|------|
| sqlite3 存储报错 | 无持久存储 | native 模块未编译 |
| 部分 native 功能缺失 | 无 registry/kerberos/watchdog | native 模块 stub |
| npm run compile 失败 | 仅 compile-client 可用 | Copilot 扩展 esbuild 依赖 |

## 后续改善
- [ ] 安装 VS C++ BuildTools workload 以编译 native 模块
- [ ] 或从 VS Code OSS 发布版提取预编译 .node 文件
