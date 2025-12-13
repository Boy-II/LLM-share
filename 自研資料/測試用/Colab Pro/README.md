# ComfyUI 快照部署方案

## 📋 项目概述

本项目提供完整的 ComfyUI 环境快照制作和 Google Colab Pro 快速部署方案。

### 核心优势
- ⚡ **快速启动**：首次 3-5 分钟，后续 <1 分钟
- 💾 **环境一致**：本机和云端使用相同的节点和依赖
- 🔄 **易于更新**：本机更新后重新打包即可
- 💰 **成本优化**：充分利用 Colab Pro 的 A100/V100

---

## 🚀 快速开始

### 步骤 1：在本机创建快照

```bash
cd "/Volumes/M200/project/Colab Pro"
./1_create_snapshot.sh
```

### 步骤 2：上传到 GitHub Release

```bash
./2_upload_to_github.sh
```

### 步骤 3：在 Colab 中使用

1. 打开 `3_colab_quick_start.ipynb`
2. 上传到 Google Colab
3. 运行所有单元格
4. 等待自动启动

---

## 📁 项目结构

```
Colab Pro/
├── README.md                    # 本文档
├── config.yaml                  # 配置文件
├── 1_create_snapshot.sh         # 快照制作脚本
├── 2_upload_to_github.sh        # GitHub 上传脚本
├── 3_colab_quick_start.ipynb    # Colab 启动笔记本
├── snapshots/                   # 快照存储目录
│   └── comfyui_snapshot_YYYYMMDD.tar.gz
└── logs/                        # 日志目录
```

---

## ⚙️ 配置说明

编辑 `config.yaml` 文件：

```yaml
# ComfyUI 路径（你的本机 ComfyUI 目录）
comfyui_path: "/path/to/your/ComfyUI"

# GitHub 仓库信息
github:
  username: "your-username"
  repo: "comfyui-snapshot"
  
# 快照配置
snapshot:
  exclude:
    - models/*          # 排除模型文件（太大）
    - output/*          # 排除输出
    - input/*           # 排除输入
    - .git              # 排除 git 历史
    - __pycache__       # 排除缓存
    - "*.pyc"
    - .DS_Store
```

---

## 🔧 详细步骤

### 1. 准备本机 ComfyUI 环境

确保你的本机 ComfyUI 已完整配置：
- ✅ 所有自定义节点已安装
- ✅ 所有依赖已安装
- ✅ 测试正常运行

### 2. 修改配置文件

```bash
# 编辑配置
nano config.yaml

# 修改 comfyui_path 为你的实际路径
comfyui_path: "/Users/yourname/ComfyUI"

# 修改 GitHub 信息
github:
  username: "your-github-username"
  repo: "comfyui-snapshot"
```

### 3. 创建快照

```bash
./1_create_snapshot.sh
```

**这个脚本会：**
1. 读取配置文件
2. 导出完整的依赖清单（requirements_complete.txt）
3. 创建自定义节点清单（custom_nodes_manifest.json）
4. 打包整个 ComfyUI（排除模型等大文件）
5. 保存到 `snapshots/` 目录

**输出文件：**
- `comfyui_snapshot_YYYYMMDD_HHMMSS.tar.gz`
- `comfyui_snapshot_latest.tar.gz` (符号链接)

### 4. 上传到 GitHub Release

首先创建 GitHub 仓库：
```bash
# 1. 在 GitHub 创建新仓库：comfyui-snapshot
# 2. 获取 Personal Access Token (Settings -> Developer settings -> Personal access tokens)
```

然后运行上传脚本：
```bash
./2_upload_to_github.sh
```

**这个脚本会：**
1. 验证 GitHub 凭据
2. 创建新的 Release（版本号基于日期）
3. 上传快照文件
4. 输出下载 URL

### 5. 在 Colab 中部署

打开 `3_colab_quick_start.ipynb`：

**首次运行：**
- 下载快照（3-5 分钟）
- 解压到 Google Drive
- 安装 PyTorch（匹配 Colab CUDA）
- 启动 ComfyUI

**后续运行：**
- 跳过下载（已在 Drive 中）
- 只安装 PyTorch（<1 分钟）
- 立即启动

---

## 🔄 更新流程

当你在本机更新了节点或依赖：

```bash
# 1. 创建新快照
./1_create_snapshot.sh

# 2. 上传新版本
./2_upload_to_github.sh

# 3. 在 Colab 中：
# 删除旧环境（可选）
# 重新运行笔记本，会自动下载最新版本
```

---

## 💡 最佳实践

### 快照管理
- 📅 定期创建快照（每周或每次大更新）
- 🏷️ 使用有意义的版本标签
- 📝 记录每个快照的变更内容

### 模型管理
- 🌐 模型文件不包含在快照中
- 💾 直接上传到 Google Drive 的 models 目录
- 🔗 或在 Colab 中从 Hugging Face 下载

### Drive 使用
```
Google Drive/
└── ComfyUI/
    ├── (快照内容)
    ├── models/            # 手动上传或下载
    │   ├── checkpoints/
    │   ├── loras/
    │   └── animatediff_models/
    ├── input/             # 输入文件
    └── output/            # 输出文件（自动保存）
```

---

## 🐛 常见问题

### Q1: 快照文件太大（>2GB）
**A:** GitHub Release 限制 2GB，可以：
- 使用 Hugging Face（无限制）
- 分割压缩包
- 进一步排除不必要的文件

### Q2: Colab 启动时依赖错误
**A:** 可能是 CUDA 版本不匹配：
```python
# 在 Colab 中检查
!nvcc --version
!python -c "import torch; print(torch.version.cuda)"

# 安装匹配的 PyTorch
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### Q3: 自定义节点不工作
**A:** 检查节点的依赖：
```python
# 在 Colab 中
%cd /content/drive/MyDrive/ComfyUI/custom_nodes/节点名称
!pip install -r requirements.txt
```

### Q4: 想要更新单个节点
**A:** 
```python
# 在 Colab 中
%cd /content/drive/MyDrive/ComfyUI/custom_nodes/节点名称
!git pull
!pip install -r requirements.txt
```

---

## 📊 性能对比

| 方案 | 首次启动 | 后续启动 | 维护难度 |
|------|---------|---------|---------|
| 每次重装 | 10-15分钟 | 10-15分钟 | ⭐ |
| pip 缓存 | 5-8分钟 | 3-5分钟 | ⭐⭐ |
| **快照方案** | **3-5分钟** | **<1分钟** | **⭐⭐⭐** |
| Docker 镜像 | <30秒 | <30秒 | ⭐⭐⭐⭐ |

---

## 📝 版本历史

查看 `CHANGELOG.md` 了解每个快照版本的详细变更。

---

## 🆘 支持

遇到问题？
1. 检查日志文件：`logs/`
2. 查看常见问题部分
3. 提交 Issue 到 GitHub 仓库

---

## 📄 许可证

本项目脚本使用 MIT 许可证。
ComfyUI 本身遵循其原始许可证。
