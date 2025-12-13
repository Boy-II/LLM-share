# 快速入门指南

## 🎯 目标

使用本地 ComfyUI 环境快照，在 Google Colab Pro 上实现快速部署。

---

## 📝 前置准备

### 1. 本地环境
- ✅ 完整配置的 ComfyUI（含所有自定义节点）
- ✅ Git（用于追踪节点信息）
- ✅ Python 3.8+

### 2. 云端准备
- ✅ Google Colab Pro 账号（$10/月）
- ✅ Google Drive 账号（至少 10GB 空间）
- ✅ GitHub 账号（用于存储快照）

### 3. 工具安装
```bash
# 安装 GitHub CLI（用于上传）
brew install gh

# 登录 GitHub
gh auth login
```

---

## 🚀 完整流程（5 分钟）

### 第一步：配置环境（1 分钟）

```bash
# 1. 打开项目目录
cd "/Volumes/M200/project/Colab Pro"

# 2. 编辑配置文件
nano config.yaml

# 3. 修改以下内容：
#    - comfyui_path: 你的 ComfyUI 路径
#    - github.username: 你的 GitHub 用户名
#    - github.repo: 仓库名称（例如：comfyui-snapshot）
```

**config.yaml 示例：**
```yaml
comfyui_path: "/Users/yourname/ComfyUI"

github:
  username: "your-github-username"
  repo: "comfyui-snapshot"
```

### 第二步：创建快照（2 分钟）

```bash
./1_create_snapshot.sh
```

**输出：**
- 快照文件：`snapshots/comfyui_snapshot_YYYYMMDD_HHMMSS.tar.gz`
- 依赖清单：已集成在快照中
- 节点清单：已集成在快照中

### 第三步：上传到 GitHub（1 分钟）

```bash
./2_upload_to_github.sh
```

**这会：**
1. 在 GitHub 创建仓库（如果不存在）
2. 创建 Release
3. 上传快照文件
4. 输出下载 URL

**复制输出的下载 URL！**

### 第四步：在 Colab 中使用（1 分钟）

1. 打开 `3_colab_quick_start.ipynb`
2. 上传到 Google Colab
3. 修改第一个代码单元格中的 `SNAPSHOT_URL` 为你的下载 URL
4. 点击 `Runtime` → `Run all`
5. 等待启动完成（首次 3-5 分钟，后续 <1 分钟）

---

## 💡 使用技巧

### 模型管理

**方式一：手动上传到 Drive**
1. 打开 Google Drive
2. 进入 `MyDrive/ComfyUI/models/checkpoints/`
3. 上传模型文件

**方式二：在 Colab 中下载**
```python
# 在 Colab 的代码单元格中
!wget https://huggingface.co/xxx/model.safetensors \
    -O /content/drive/MyDrive/ComfyUI/models/checkpoints/model.safetensors
```

### 更新流程

**本地更新后：**
```bash
# 1. 重新创建快照
./1_create_snapshot.sh

# 2. 上传新版本
./2_upload_to_github.sh

# 3. 在 Colab 中：
#    - 删除旧环境（运行笔记本中的"清理"单元格）
#    - 或设置 FORCE_DOWNLOAD = True
#    - 重新运行笔记本
```

### 节点更新

**在 Colab 中单独更新某个节点：**
```python
%cd /content/drive/MyDrive/ComfyUI/custom_nodes/节点名称
!git pull
!pip install -r requirements.txt
```

---

## 🐛 常见问题

### Q1: 快照太大（>2GB）

**问题：** GitHub Release 限制 2GB

**解决：**
```bash
# 方案 1: 检查是否排除了所有不必要的文件
# 编辑 config.yaml 的 exclude 列表

# 方案 2: 使用 Hugging Face（无大小限制）
# 设置 config.yaml:
huggingface:
  enabled: true
  username: "your-hf-username"
  repo: "comfyui-snapshot"
```

### Q2: Colab 依赖安装失败

**问题：** CUDA 版本不匹配

**解决：**
```python
# 在 Colab 中检查 CUDA 版本
!nvcc --version

# 安装匹配的 PyTorch
# CUDA 11.8:
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1:
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### Q3: 启动很慢

**原因：** 每次都重新安装依赖

**解决：**
- 确保 ComfyUI 在 Google Drive 中（不是 /content/）
- 不要删除 Drive 中的环境
- 后续启动会跳过下载和大部分安装

### Q4: 无法访问 Cloudflare URL

**问题：** 防火墙或网络限制

**解决：**
```bash
# 方案 1: 使用 Colab 的内置端口转发
# 在笔记本中添加：
from google.colab import output
output.serve_kernel_port_as_window(8188)

# 方案 2: 使用 Ngrok
!pip install pyngrok
from pyngrok import ngrok
public_url = ngrok.connect(8188)
print(f"访问: {public_url}")
```

---

## 📊 性能对比

| 操作 | 每次重装 | 使用快照 | 节省时间 |
|------|---------|---------|---------|
| 首次部署 | 15 分钟 | 3-5 分钟 | **10 分钟** |
| 后续启动 | 15 分钟 | <1 分钟 | **14 分钟** |
| 更新环境 | 15 分钟 | 3-5 分钟 | **10 分钟** |

---

## 🎓 进阶技巧

### 自动化备份

创建定时脚本：
```bash
# 创建 cron 任务（每周日备份）
crontab -e

# 添加：
0 0 * * 0 cd "/Volumes/M200/project/Colab Pro" && ./1_create_snapshot.sh && ./2_upload_to_github.sh
```

### 多版本管理

```bash
# 创建带标签的版本
DATE=$(date +%Y%m%d)
./1_create_snapshot.sh
./2_upload_to_github.sh

# 在 config.yaml 中可以添加版本注释
```

### 团队协作

1. 将快照仓库设为公开或添加协作者
2. 团队成员使用相同的快照 URL
3. 确保所有人使用相同的模型配置

---

## 🔗 相关链接

- **ComfyUI 官方**: https://github.com/comfyanonymous/ComfyUI
- **GitHub CLI**: https://cli.github.com/
- **Google Colab**: https://colab.research.google.com/
- **Hugging Face**: https://huggingface.co/

---

## 📞 获取帮助

遇到问题？

1. 查看日志文件：`logs/snapshot_YYYYMMDD_HHMMSS.log`
2. 检查 GitHub Issues
3. 查看常见问题部分

---

**最后更新：** $(date)
