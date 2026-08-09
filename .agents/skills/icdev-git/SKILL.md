---
name: icdev-git
description: IC-dev 项目的 Git 分支管理、上游同步、patches 维护的标准流程
---

# IC-dev Git 工作流

## 分支架构

```
upstream → https://github.com/microsoft/vscode.git   (只拉取)
origin   → 用户的 GitHub fork                          (推送 icdev-dev)

main        ← 干净跟踪 upstream，不包含任何 IC-dev 修改
icdev-dev   ← IC-dev 所有定制 + 框架文件 + patches/
```

## 预检 (每次操作前确认)

```bash
git remote -v           # 必须有 upstream → microsoft/vscode
git branch              # 确认当前分支
```

---

## 工作流 1: 日常开发

```bash
# 1. 切换到开发分支
git checkout icdev-dev

# 2. 修改文件...

# 3. 提交
git add <files>
git commit -m "IC-dev: <描述>"

# 4. 更新 state.md
#    - 标记完成的任务
#    - 追加决策记录

# 5. 更新 patches (如果修改了上游文件)
git diff main -- <modified-file> > patches/NNN-description.patch

# 6. 推送
git push origin icdev-dev
```

---

## 工作流 2: 同步上游

```bash
# 1. 拉取上游最新
git checkout main
git pull upstream main

# 2. 合并到 icdev-dev
git checkout icdev-dev
git merge main

# 3. 解决冲突 (如有)
#    - product.json: 保留 IC-dev 品牌值，合并上游新增字段
#    - languageModels.ts: 保留 goose 修改，合并上游接口变更
#    - 其他文件: 逐个审查

# 4. 重新生成所有 patches
mkdir -p patches
git diff main -- product.json > patches/001-product.patch
# ... 对每个受影响的文件重复

# 5. 验证编译
npm run compile

# 6. 更新 state.md
#    - 记录合并的上游 commit range
#    - 记录冲突解决决策

# 7. 提交合并
git add .
git commit -m "IC-dev: merge upstream $(git rev-parse --short main)"

# 8. 推送
git push origin icdev-dev
```

---

## 工作流 3: 生成 Patches

```bash
# 查看 icdev-dev 相对于 main 的所有变更
git diff main --stat

# 为单个文件生成 patch
git diff main -- product.json > patches/001-product.patch

# 批量生成: 先列出变更文件，然后逐个生成
git diff main --name-only | while read f; do
  echo "$f"
done

# 验证 patches 能干净应用 (在 main 上测试)
git checkout main
git apply --check patches/001-product.patch  # 只检查，不应用
git checkout icdev-dev
```

---

## 工作流 0: 分支-确认-合并 (阶段性开发主流程)

> 项目阶段性开发统一采用"分支-确认-合并"形式，禁止直接在 icdev-dev 上开发功能代码。

```bash
# 1. 分支: 从 icdev-dev 创建任务分支 (命名: feat/<阶段>-<任务描述>)
git checkout icdev-dev
git pull origin icdev-dev
git checkout -b feat/p1-vendor-id-decouple     # 示例

# 2. 开发: 在分支上完成任务
#    - 修改 src/, extensions/, product.json, build/ 等
#    - 自测: 编译 + 功能验证

# 3. 提交 (在分支上)
git add <files>
git commit -m "IC-dev: <描述>"

# 4. 确认: 将分支工作交给用户确认，等待明确批准
#    - 可以推送分支供 review: git push origin feat/xxx
#    - 未经用户确认不得合并

# 5. 合并: 用户确认后合并回 icdev-dev
git checkout icdev-dev
git merge feat/xxx
git push origin icdev-dev

# 6. 清理: 删除已合并的分支
git branch -d feat/xxx
git push origin --delete feat/xxx   # 如已推送
```

### 规则
- 框架文件 (.goosehints, icdev/, .agents/, recipes/) 的修改可直接提交在 icdev-dev
- 代码定制 (src/, extensions/, product.json, build/) 必须走分支-确认-合并
- 合并后如修改了上游文件，重新生成 patches/
- 每次变更后更新 icdev/state.md

---

## 工作流 4: 初始设置 (仅一次)

```bash
# 添加上游远程
git remote add upstream https://github.com/microsoft/vscode.git

# 创建 icdev-dev 分支
git checkout -b icdev-dev

# 提交框架文件
git add .goosehints .goose/ icdev/ .agents/ recipes/ AGENTS.md
git commit -m "IC-dev: project framework and documentation"

# 推送
git push -u origin icdev-dev

# 切回 main
git checkout main
```

---

## 常见问题

### Q: 合并上游时 product.json 冲突
A: product.json 是集中的品牌配置，冲突是预期的。
   - 保留 IC-dev 的品牌值 (nameShort, nameLong, etc.)
   - 接受上游新增的字段
   - 审查上游修改的现有字段，决定是否采纳

### Q: patches 应用失败
A: patches 是记录，不是主要修改机制。
   - 直接修改在 icdev-dev 上的文件是 source of truth
   - patches 文件只是方便 review 的 diff 输出
   - 如果 patches 和实际文件不一致，以实际文件为准，重新生成 patches

### Q: 不小心在 main 上做了修改
A: `git stash` → `git checkout icdev-dev` → `git stash pop` → 正常提交
