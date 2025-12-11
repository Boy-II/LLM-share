# LLM 免费资源分享

本仓库收集整理了 LLM 相关的免费资源，帮助开发者和研究者更好地使用大语言模型。

## AI 对话助手

### Claude.ai
- **网址**: https://claude.ai
- **免费额度**:
  - 每天免费使用 Claude 模型（有使用次数限制）
  - 支持 Claude 4.5 Sonnet 等最新模型
  - 无需信用卡即可使用
- **特点**:
  - 支持超长上下文（200K tokens）
  - 支持文件上传和分析
  - 支持 Artifacts 交互式内容生成

### Google AI Studio (Gemini)
- **网址**: https://aistudio.google.com
- **免费额度**:
  - 每天免费使用 Gemini 模型
  - Gemini 2.5 Flash: 每分钟 15 次请求
  - Gemini 2.5 Pro: 每分钟 2 次请求
  - 完全免费，无需信用卡
- **特点**:
  - 支持超长上下文（最高 2M tokens）
  - 支持多模态输入（文本、图片、视频、音频）
  - 提供 API 和网页界面

### Pollinations.ai
- **网址**: https://pollinations.ai
- **免费额度**:
  - 完全免费，无限制使用
  - 支持 GPT-4、GPT-3.5 等多个模型
  - 提供免费 API 访问
  - 无需注册或 API key
- **特点**:
  - 支持文本生成（GPT 系列）
  - 支持图像生成（多种模型）
  - RESTful API 接口
  - 开源友好，适合开发者集成

### OpenRouter
- **网址**: https://openrouter.ai/
- **免费额度**:
  - 新用户注册赠送免费额度
  - 部分模型提供免费访问
  - 支持多个主流 LLM（GPT、Claude、Gemini、Llama 等）
  - 统一 API 接口，兼容 OpenAI 格式
- **特点**:
  - 模型聚合平台，一个 API 访问多个模型
  - 支持 50+ 种 AI 模型
  - 自动路由到最优模型
  - 透明的价格对比
  - 支持流式输出
  - 适合开发者快速切换和测试不同模型
- **适合场景**:
  - 多模型对比测试
  - API 开发和集成
  - 模型性价比优化
  - 快速原型开发

### NVIDIA AI (build.nvidia.com)
- **网址**: https://build.nvidia.com/
- **免费额度**:
  - 每个模型提供免费 API 积分
  - 支持 NVIDIA 优化的多个开源模型
  - 无需信用卡即可开始使用
  - 每月更新免费额度
- **特点**:
  - NVIDIA 官方优化的 AI 模型推理服务
  - 支持 Llama、Mistral、Gemma 等主流开源模型
  - GPU 加速推理，速度快
  - 提供 API Playground 在线测试
  - 兼容 OpenAI API 格式
  - NVIDIA NIM 微服务架构
- **适合场景**:
  - 高性能 LLM 推理
  - 开源模型测试和部署
  - GPU 加速应用开发
  - 企业级 AI 应用原型

## 模型资源

### Hugging Face
- **网址**: https://huggingface.co/models
- **说明**: 最大的开源模型托管平台，提供海量预训练模型
- **免费内容**:
  - 免费访问和下载数万个开源模型
  - 免费模型推理 API（有速率限制）
  - 免费的 Spaces 部署（CPU）
  - 免费的 Dataset 存储

## 开发平台 SaaS 免费层

### Hugging Face Spaces
- **网址**: https://huggingface.co/spaces
- **说明**: 免费托管和部署机器学习应用和工具
- **免费额度**:
  - **CPU Basic**: 2 vCPU, 16 GB RAM, 50 GB 存储（永久免费）
  - **持久化存储**: 免费提供持久化存储空间
  - **可部署应用**:
    - Gradio / Streamlit 机器学习应用
    - n8n 工作流自动化工具
    - Jupyter Notebook
    - Docker 容器应用
    - 静态网站
  - **特性**:
    - 自动休眠机制（闲置后休眠，访问时自动唤醒）
    - 支持私有 Spaces
    - 免费 HTTPS 域名
    - Git 版本控制

### Hugging Face Inference API
- **网址**: https://huggingface.co/inference-api
- **免费额度**:
  - 每天有限次数的 API 调用
  - 支持大部分开源模型
  - 无需信用卡即可使用

### Hugging Face Pro (可选付费)
- **免费试用**: 可以免费试用 GPU Spaces
- **升级选项**:
  - GPU T4 Small: 适合运行中小型模型
  - GPU A10G: 适合运行大型模型推理

### Claw.Cloud
- **网址**: https://run.claw.cloud/
- **免费额度**:
  - GitHub 账号持有 180 天后，每月可获得 $5 美金额度
  - 可用于 Claude API 调用
  - 基于 GitHub 账号认证
- **特点**:
  - 免费获取 Claude API 访问
  - 无需信用卡
  - 通过 GitHub 账号验证
- **适合场景**: Claude API 开发测试、个人项目

### GitHub 学生开发者包
- **网址**: https://education.github.com/
- **免费福利**:
  - **GitHub Copilot**: 学生免费使用
  - **GitHub Codespaces**: 每月 120 小时免费
  - **数十种开发工具**: 免费或折扣访问
- **申请条件**: 需要学生身份验证

## 内网穿透 / Tunnel 服务

### Ngrok
- **网址**: https://ngrok.com
- **免费额度**:
  - 1 个在线隧道
  - 每分钟 40 次连接
  - 随机生成的域名
  - HTTP/TCP 隧道支持
- **适合场景**: 本地开发调试、Webhook 测试、临时公网访问

### Cloudflare Tunnel
- **网址**: https://www.cloudflare.com/products/tunnel/
- **免费额度**:
  - 完全免费，无限制使用
  - 支持多个隧道
  - 可使用自定义域名（需要域名托管在 Cloudflare）
  - 内置 DDoS 保护
- **适合场景**: 长期服务暴露、自托管应用、安全的内网穿透

## 云服务免费层

### Oracle Cloud
- **网址**: https://www.oracle.com/cloud/free/
- **免费额度**:
  - 永久免费的 VM 实例（Ampere A1 Compute）
    - 4 个 ARM CPU 核心
    - 24 GB 内存
  - 永久免费的 AMD VM
    - 2 个 AMD CPU
    - 1 GB 内存
  - 200 GB 块存储
  - 10 GB 对象存储
- **适合场景**: 部署小型模型推理服务、API 服务器

### AWS 免费层
- **网址**: https://aws.amazon.com/free/
- **免费额度**:
  - **EC2**: t2.micro/t3.micro 实例，每月 750 小时（仅首年）
    - 1 vCPU
    - 1 GB 内存
  - **S3**: 5 GB 标准存储（首年）
  - **Lambda**: 每月 100 万次免费请求（永久）
  - **DynamoDB**: 25 GB 存储（永久）
  - **CloudFront**: 每月 50 GB 数据传出（首年）
- **注意事项**:
  - 需要信用卡验证
  - 大部分免费额度仅限首 12 个月
  - 超出免费额度会自动计费
  - 流量费用需要特别注意
- **适合场景**: 学习 AWS 服务、短期项目测试、轻量级 Serverless 应用

### Google Cloud Platform (GCP)
- **网址**: https://cloud.google.com/free
- **免费额度**:
  - **Compute Engine**: e2-micro 实例（每月 1 个实例，永久免费）
    - 0.25-0.5 vCPU（突发）
    - 1 GB 内存
    - 30 GB 标准持久化磁盘
  - **Cloud Storage**: 5 GB 区域存储（永久）
  - **Cloud Functions**: 每月 200 万次调用（永久）
  - **Vertex AI**:
    - 3 个月内总共 $300 试用额度
    - Gemini API 免费额度
    - AutoML 训练时间
  - **新用户试用**: 首次注册提供 $300 额度（3 个月有效）
- **注意事项**:
  - 需要信用卡验证
  - $300 试用额度仅限首次注册后 3 个月内使用
  - 部分服务永久免费（限特定区域）
- **适合场景**: AI/ML 模型训练、轻量级应用部署

### Google Colab
- **网址**: https://colab.research.google.com
- **免费额度**:
  - 免费 GPU 使用（T4）
  - 免费 TPU 访问（有限）
  - 12 小时最长运行时间
  - 12 GB RAM（标准版）
  - 免费云端 Jupyter Notebook
- **Colab Pro（付费可选）**:
  - 更长的运行时间
  - 更好的 GPU（A100/V100）
  - 更多 RAM（最高 52 GB）
- **特点**:
  - 完全基于浏览器，无需配置
  - 与 Google Drive 集成
  - 支持 GPU/TPU 加速
  - 预装常用 ML 库
- **适合场景**: 机器学习实验、模型训练、数据分析、学习 AI/ML

## 反向代理工具

### gcli2api - Gemini CLI 反代理
- **项目地址**: https://github.com/su-kaka/gcli2api
- **说明**: 将 Gemini CLI 转换为 API 服务的轮询工具
- **特点**:
  - 通过 CLI 轮询方式访问 Gemini
  - 绕过 API 调用限制
  - 可自建 API 服务
- **适合场景**: 需要频繁调用 Gemini API 但受限于配额的场景

### clewdr - Claude 低负载反代理
- **项目地址**: https://github.com/Boy-II/clewdr
- **说明**: 基于 Rust 的低负载 Claude 反向代理轮询工具
- **特点**:
  - Rust 实现，性能优异，资源占用低
  - 支持轮询多个 Claude 账号
  - 降低单账号负载，提高可用性
  - 自动负载均衡
- **适合场景**: 需要高频访问 Claude API，或需要分散请求负载

## 开源工作流平台

### n8n
- **项目地址**: https://github.com/n8n-io/n8n
- **网址**: https://n8n.io
- **说明**: 开源的工作流自动化工具（专注于推理和推送）
- **特点**:
  - 完全开源，可自托管
  - 官方维护 400+ 种服务集成（GitHub、Slack、数据库等）
  - 成熟的凭证管理系统（适配各种服务的认证方式）
  - 强大的 Webhook 支持和 API 调用能力
  - 可视化工作流编辑器
  - 支持 AI 推理节点（OpenAI、Anthropic 等）
  - 可部署在 HF Spaces 免费使用
  - 企业级支持和文档
- **适合场景**:
  - AI 推理结果处理和推送
  - Webhook 处理和事件驱动自动化
  - API 集成和数据同步
  - 自动化业务流程
  - 第三方服务编排

### Dify
- **项目地址**: https://github.com/langgenius/dify
- **网址**: https://dify.ai
- **说明**: 开源的 LLM 应用开发平台
- **特点**:
  - 可视化 AI 应用构建
  - 支持多种 LLM（GPT、Claude、Gemini 等）
  - 内置 RAG 引擎和知识库管理
  - Agent 和工作流编排
  - 提供免费云服务和自托管选项
- **适合场景**:
  - 快速构建 AI 聊天机器人
  - RAG 应用开发
  - AI Agent 开发
  - 企业知识库问答

### ComfyUI
- **项目地址**: https://github.com/comfyanonymous/ComfyUI
- **说明**: 节点式 AI 工作流平台（类似 n8n，专注于通过推理生产内容）
- **特点**:
  - 可视化节点工作流编辑器
  - 完全开源，可自托管
  - 丰富的社区自定义节点（专注 AI 领域）
  - 支持自定义节点开发（Python）
  - 支持多种 AI 模型和服务：
    - 扩散模型（Stable Diffusion、Flux、Qwen 视频生成等）
    - LLM 模型（用于提示词反推和优化，支持 GGUF 格式）
    - TTS 语音合成
    - API Call 节点（可接入任意外部服务）
  - 支持模型训练工作流（LoRA、微调等）
  - 拖拽式流程设计，无需编程
  - 极其活跃的 AI 社区生态
- **适合场景**:
  - 图像/视频内容生产自动化
  - 提示词工程（反推和优化）
  - 模型训练和微调（LoRA、DreamBooth 等）
  - 多模态内容生成工作流
  - TTS/语音内容制作
  - 批量内容生产管线

## 开源 TTS 语音合成

### CosyVoice2
- **项目地址**: https://github.com/FunAudioLLM/CosyVoice
- **说明**: 阿里巴巴通义实验室开源的多语言 TTS 模型
- **特点**:
  - 支持中英文等多语言
  - 零样本语音克隆
  - 跨语言语音合成
  - 情感和韵律控制
  - 高质量自然语音生成
- **适合场景**:
  - 语音克隆
  - 多语言配音
  - 有声书制作
  - AI 虚拟主播

### GPT-SoVITS
- **项目地址**: https://github.com/RVC-Boss/GPT-SoVITS
- **说明**: 强大的少样本语音转换和 TTS 模型
- **特点**:
  - 仅需 5 秒音频即可训练
  - 支持中英日韩等多语言
  - 零样本/少样本语音克隆
  - WebUI 界面，易于使用
  - 支持实时推理
- **适合场景**:
  - 快速语音克隆
  - 个性化 TTS
  - 游戏角色配音
  - 视频配音制作

### Index-TTS
- **项目地址**: https://github.com/index-tts/index-tts
- **说明**: 高性能的端到端 TTS 系统
- **特点**:
  - 高质量语音合成
  - 支持多语言
  - 快速推理速度
  - 易于训练和部署
  - 开源且活跃维护
- **适合场景**:
  - 语音合成研究
  - TTS 应用开发
  - 自定义语音模型训练
  - 实时语音生成

## 开源优化工具/库

### Flash Attention
- **项目地址**: https://github.com/Dao-AILab/flash-attention
- **说明**: 快速且内存高效的注意力机制实现
- **特点**:
  - 显著加速 Transformer 模型训练和推理
  - 减少内存占用（相比标准 Attention 可节省 10-20x 内存）
  - 支持 PyTorch 和 Triton
  - 被广泛应用于 LLaMA、GPT 等大模型训练
- **适合场景**:
  - 训练或微调大语言模型
  - 优化模型推理性能
  - 研究注意力机制优化

### Sage Attention
- **项目地址**: https://github.com/thu-ml/SageAttention
- **说明**: 高效的稀疏注意力实现
- **特点**:
  - 通过稀疏化提升注意力计算效率
  - 支持超长序列处理
  - 保持模型精度的同时提升速度
  - 适用于各类 Transformer 架构
- **适合场景**:
  - 处理超长文本序列
  - 优化长上下文模型性能
  - 降低计算资源消耗

## 贡献

欢迎提交 PR 添加更多免费资源！

## 许可

MIT License
