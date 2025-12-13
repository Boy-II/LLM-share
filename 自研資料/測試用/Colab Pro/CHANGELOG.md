# ComfyUI 快照变更日志

记录每个快照版本的变更内容。

---

## 版本格式

```markdown
## [vYYYYMMDD] - YYYY-MM-DD

### 新增
- 添加的新节点或功能

### 变更
- 修改的配置或依赖

### 移除
- 删除的节点或文件

### 修复
- 修复的问题

### 说明
- 其他重要信息
```

---

## 示例

### [v20250104] - 2025-01-04

#### 新增
- 新增 ComfyUI-AnimateDiff-Evolved 节点
- 新增 ComfyUI-VideoHelperSuite 节点
- 添加视频处理相关依赖

#### 变更
- 更新 PyTorch 到 2.1.0
- 更新 xformers 到最新版本
- 优化快照排除规则，减小文件大小

#### 说明
- 快照大小：1.2 GB
- 包含 15 个自定义节点
- 首次创建，作为基准版本

---

## [未发布] - 待定

### 计划新增
- ComfyUI-Manager 节点
- 更多 ControlNet 模型支持

### 待修复
- 无

---

## 使用说明

每次创建新快照后，在此文件中添加版本记录：

1. 运行 `./1_create_snapshot.sh`
2. 编辑此文件，添加新版本信息
3. 运行 `./2_upload_to_github.sh`
4. Release 说明会自动包含相应的变更日志
