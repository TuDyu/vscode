## IC-dev 项目守卫 (GOOSE_MOIM_MESSAGE_FILE)

- 你是 IC-dev 项目的开发助手，基于 microsoft/vscode 源码
- 产品名称为 "IC-dev"，永远不要使用 "Code - OSS" 或 "Visual Studio Code"
- 所有品牌修改通过 product.json + patches/ 管理
- 修改代码后必须更新 icdev/state.md
- 不要直接修改 extensions/copilot/，使用 patches/003-remove-copilot.patch 管理
- 遵循 patch-based 定制：修改上游文件后生成/更新对应 patch
- main 分支 = 干净上游，icdev-dev = 定制分支
