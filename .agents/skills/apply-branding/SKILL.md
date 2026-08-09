---
name: apply-branding
description: 将 IC-dev 品牌应用到 product.json 和相关资源文件，遵循 patch-based 管理
---

# IC-dev 品牌应用

当需要更新品牌信息时（名称变更、新增 product.json 字段、图标替换等），按此流程操作。

## 品牌字段映射

所有品牌信息集中在 product.json:

| 字段 | 当前值 |
|------|--------|
| nameShort | "IC-dev" |
| nameLong | "IC-dev" |
| applicationName | "icdev" |
| dataFolderName | ".icdev" |
| sharedDataFolderName | ".icdev-shared" |
| win32MutexName | "icdev" |
| urlProtocol | "icdev" |
| serverApplicationName | "icdev-server" |
| serverDataFolderName | ".icdev-server" |
| tunnelApplicationName | "icdev-tunnel" |
| linuxIconName | "icdev" |

## 执行步骤

1. 读取 @icdev/state.md 确认当前阶段
2. 修改 product.json 中的品牌字段
3. 如需替换图标:
   - Windows: resources/win32/code.ico → 新图标
   - Linux: resources/linux/code.png → 新图标
4. 更新 patches/001-product-branding.patch
5. 更新 icdev/state.md 进度
6. 验证: `npm run compile`

## 注意事项

- 不要修改 AGENTS.md（那是上游文件）
- product.json 修改后必须同时更新 patch 文件
- 如果 product.json 新增了上游字段，确保 IC-dev 的值合理
