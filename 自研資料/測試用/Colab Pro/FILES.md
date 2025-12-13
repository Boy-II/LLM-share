# 📁 项目文件说明

本文档说明项目中每个文件的用途。

---

## 📄 核心文件

### `config.yaml`
**用途**：项目配置文件  
**说明**：包含 ComfyUI 路径、GitHub 设置、快照选项等所有配置  
**修改**：首次使用前必须修改

### `README.md`
**用途**：完整项目文档  
**说明**：详细的使用说明、配置指南、常见问题等  
**修改**：不需要修改

### `QUICKSTART.md`
**用途**：快速入门指南  
**说明**：5分钟快速开始的简明教程  
**修改**：不需要修改

### `CHANGELOG.md`
**用途**：版本变更记录  
**说明**：记录每个快照版本的变更内容  
**修改**：每次创建新快照后更新

---

## 🔧 脚本文件

### `init.sh` ⭐ 新用户从这里开始
**用途**：一键初始化向导  
**说明**：交互式配置工具，帮助新用户快速设置  
**使用**：`./init.sh`

### `0_check_environment.sh`
**用途**：环境检查工具  
**说明**：检查所需工具和配置是否正确  
**使用**：`./0_check_environment.sh`

### `1_create_snapshot.sh` ⭐ 核心脚本
**用途**：创建快照  
**说明**：
- 导出依赖清单
- 创建节点清单
- 打包 ComfyUI 环境
- 生成元数据和变更日志  
**使用**：`./1_create_snapshot.sh`  
**输出**：`snapshots/comfyui_snapshot_YYYYMMDD_HHMMSS.tar.gz`

### `2_upload_to_github.sh` ⭐ 核心脚本
**用途**：上传到 GitHub Release  
**说明**：
- 创建 GitHub Release
- 上传快照文件
- 生成下载链接  
**使用**：`./2_upload_to_github.sh`  
**前提**：需要先运行 `1_create_snapshot.sh`

---

## 📓 Colab 文件

### `3_colab_quick_start.ipynb` ⭐ Colab 使用
**用途**：Google Colab 启动笔记本  
**说明**：在 Colab 中快速部署和启动 ComfyUI  
**使用**：
1. 上传到 Google Colab
2. 修改第一个单元格的 `SNAPSHOT_URL`
3. 运行所有单元格

**功能**：
- 自动挂载 Google Drive
- 下载并解压快照
- 安装依赖
- 启动 ComfyUI
- 创建公网访问链接

---

## 📂 目录结构

### `snapshots/`
**用途**：存储快照文件  
**说明**：
- 包含所有历史快照
- `comfyui_snapshot_latest.tar.gz` 指向最新快照
- `CHANGELOG_YYYYMMDD.md` 为每个快照的变更说明
- `release_info_YYYYMMDD.txt` 为 GitHub Release 信息

### `logs/`
**用途**：存储日志文件  
**说明**：
- 每次快照创建都会生成日志
- 格式：`snapshot_YYYYMMDD_HHMMSS.log`
- 用于排查问题

---

## 🔒 配置文件

### `.gitignore`
**用途**：Git 忽略规则  
**说明**：
- 排除快照文件（太大）
- 排除日志文件
- 排除敏感信息

---

## 📊 使用流程图

```
第一次使用：
init.sh
  ↓
0_check_environment.sh (可选)
  ↓
1_create_snapshot.sh
  ↓
2_upload_to_github.sh
  ↓
在 Colab 中使用 3_colab_quick_start.ipynb

后续更新：
1_create_snapshot.sh
  ↓
2_upload_to_github.sh
  ↓
在 Colab 中更新（重新运行笔记本或设置 FORCE_DOWNLOAD=True）
```

---

## 🎯 文件优先级

### 必读文件（新用户）
1. **README.md** - 了解项目
2. **QUICKSTART.md** - 快速开始
3. **本文件** - 理解文件结构

### 必用脚本（新用户）
1. **init.sh** - 初始化配置
2. **0_check_environment.sh** - 检查环境
3. **1_create_snapshot.sh** - 创建快照
4. **2_upload_to_github.sh** - 上传快照

### 必用文件（Colab）
1. **3_colab_quick_start.ipynb** - 在 Colab 中使用

### 可选文件
- **CHANGELOG.md** - 如果需要记录版本变更
- **config.yaml** - 高级配置调整

---

## 🔄 文件更新频率

| 文件 | 更新频率 | 说明 |
|------|---------|------|
| config.yaml | 首次/需要时 | 配置变更时修改 |
| CHANGELOG.md | 每次快照 | 记录变更 |
| snapshots/* | 每次快照 | 自动生成 |
| logs/* | 每次快照 | 自动生成 |
| 其他文档 | 很少 | 除非项目更新 |

---

## 💡 快速参考

### 我想...

**首次使用项目**
→ 运行 `./init.sh`

**检查环境是否正确**
→ 运行 `./0_check_environment.sh`

**创建快照**
→ 运行 `./1_create_snapshot.sh`

**上传到 GitHub**
→ 运行 `./2_upload_to_github.sh`

**在 Colab 中使用**
→ 打开 `3_colab_quick_start.ipynb`

**查看如何使用**
→ 阅读 `QUICKSTART.md`

**深入了解项目**
→ 阅读 `README.md`

**记录版本变更**
→ 编辑 `CHANGELOG.md`

**修改配置**
→ 编辑 `config.yaml`

**查看历史快照**
→ 查看 `snapshots/` 目录

**排查问题**
→ 查看 `logs/` 目录

---

## 📞 需要帮助？

1. 先查看 `README.md` 的常见问题部分
2. 查看日志文件：`logs/snapshot_*.log`
3. 运行 `./0_check_environment.sh` 检查配置

---

**最后更新：** 2025-01-04
