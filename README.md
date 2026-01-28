# DevToolkit — 开发者日常工具箱

[![AI Generated](https://img.shields.io/badge/Generated%20by-AI-blue?style=flat-square&logo=openai)](https://github.com/features/copilot)
[![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?style=flat-square&logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=flat-square&logo=powershell)](https://docs.microsoft.com/powershell/)
[![Python](https://img.shields.io/badge/Python-3.12%2B-3776AB?style=flat-square&logo=python)](https://www.python.org/)

一个专注于 Windows 开发环境的自动化工具集，收录日常可重复使用的脚本与配置工具。所有工具均基于 **AI 辅助生成**，经过实际场景验证，旨在提升工作效率、减少重复劳动。

---

## 项目背景

在日常开发与环境配置中，我们经常需要：
- 在新机器上重复安装相同的开发工具（VSCode、Git、Python 等）
- 配置 Python 环境（换源、装包、设置 PATH）
- 处理各种权限、依赖与兼容性问题

这些任务虽然简单但繁琐，容易出错且浪费时间。借助 AI（如 GitHub Copilot、ChatGPT 等），我将这些高频操作整理成可复用的脚本工具集，形成本仓库。

---

## 项目索引

### 📦 工具列表

| 工具名称 | 类型 | 适用场景 | 核心功能 | 文档 |
|---------|------|---------|---------|------|
| **[FreshStart](FreshStart/)** | PowerShell 脚本 | Windows 全新机器/重装系统后快速部署开发环境 | 自动化安装 VSCode、Git、TortoiseGit、Python、Everything 等开发工具，并完成初始配置 | [README](FreshStart/README.md) · [快速开始](FreshStart/QUICK_START.md) |
| **[PyEnvSetup](PyEnvSetup/)** | Python 脚本 | Python 安装后的环境配置与优化 | PATH 管理（用户级/系统级/临时）、pip 源切换（国内镜像）、常用库批量安装 | [README](PyEnvSetup/README.md) |

---

## 快速导航

### 🚀 我想要...

- **快速配置新 Windows 开发机** → [FreshStart 快速开始](FreshStart/QUICK_START.md)
- **仅配置 Python 环境** → [PyEnvSetup 工具说明](PyEnvSetup/README.md)
- **了解 PowerShell 自动化细节** → [FreshStart 完整指南](FreshStart/README_POWERSHELL.md)
- **查看安装后的验证方法** → [Check-Python 脚本](FreshStart/Check-Python.ps1)

---

## 功能亮点

### FreshStart — 开发环境自动安装

- ✅ **零依赖**：基于 Windows 自带的 PowerShell 5.1+，无需预装 Python
- ✅ **智能检测**：自动判断软件是否已安装，避免重复
- ✅ **依赖管理**：按正确顺序安装（如先装 VC++ 再装 TortoiseGit）
- ✅ **一键配置**：自动将 VSCode 设为 Git 编辑器，Python 加入 PATH
- ✅ **环境准备**：安装后自动运行 Python 环境配置脚本
- ✅ **友好交互**：支持双击批处理或右键运行，彩色日志输出

**支持的软件**：VSCode、Git、TortoiseGit、Python 3.12+、Everything、MobaXterm

### PyEnvSetup — Python 环境配置助手

- ✅ **PATH 管理**：三种方式（用户级/系统级/临时）灵活添加 Python 路径
- ✅ **智能去重**：路径标准化，避免重复添加与大小写问题
- ✅ **镜像源切换**：默认清华镜像，支持自定义，提升国内下载速度
- ✅ **批量装包**：自动安装 numpy、pandas、matplotlib 等科学计算栈
- ✅ **进度反馈**：逐个包显示安装进度与结果

---

## 使用示例

### 场景 1：全新 Windows 机器配置开发环境

```powershell
# 1. 下载所需安装包（VSCode、Git、Python 等）放到同一目录
# 2. 右键 Install-Software.ps1 → "Run with PowerShell"
# 3. 按提示选择安装选项，等待完成
# 4. 重启后验证

code --version
git --version
python --version
```

详见：[FreshStart 快速开始](FreshStart/QUICK_START.md)

### 场景 2：仅配置 Python 环境

```powershell
# Python 已安装，需要配置 PATH 和换源
python setup_env.py

# 交互式选择：
# 1. 是否添加到 PATH（用户级/系统级/临时）
# 2. 是否更换 pip 源（清华镜像/自定义/跳过）
# 3. 自动安装常用包（numpy、pandas 等）
```

详见：[PyEnvSetup 工具说明](PyEnvSetup/README.md)

---

## AI 生成说明

本仓库的所有脚本与文档均基于 **AI 辅助生成**（如 GitHub Copilot、ChatGPT、Claude 等），通过以下流程创建：

1. **需求描述**：向 AI 描述实际使用场景与期望功能
2. **代码生成**：AI 生成初始代码框架与逻辑
3. **迭代优化**：根据实际测试反馈，与 AI 协作调整细节
4. **文档完善**：由 AI 生成结构化文档与使用说明

### 为什么选择 AI 辅助开发？

- ⚡ **快速原型**：从想法到可运行代码，时间大幅缩短
- 📚 **最佳实践**：AI 基于大量代码库训练，能提供符合规范的写法
- 🔄 **迭代效率**：通过对话快速调整功能，无需手动查文档
- 🧪 **测试覆盖**：AI 能帮助生成边界情况处理与错误检查

**注意**：AI 生成的代码需经过人工审查与实际测试，本仓库已在真实环境验证。

---

## 系统要求

- **操作系统**：Windows 7 / 10 / 11（推荐 10 及以上）
- **PowerShell**：5.1+ （Windows 10/11 自带）
- **权限**：建议以管理员身份运行（系统级安装与 PATH 配置）
- **网络**：需要访问外网下载安装包（或提前下载到本地）

---

## 目录结构

```
DevToolkit/
├── README.md                    # 项目总览（本文件）
├── FreshStart/                  # Windows 开发环境自动安装
│   ├── README.md                # FreshStart 说明
│   ├── QUICK_START.md           # 快速开始指南
│   ├── README_POWERSHELL.md     # 完整的 PowerShell 技术文档
│   ├── Install-Software.ps1     # 主安装脚本
│   ├── Install-Software.bat     # 批处理入口
│   ├── Check-Python.ps1         # Python 安装验证脚本
│   └── setup_env.py             # Python 环境配置脚本
└── PyEnvSetup/                  # Python 环境配置工具
    ├── README.md                # PyEnvSetup 工具说明
    ├── setup_env.py             # 独立的 Python 环境配置脚本
    └── notes.md                 # 相关笔记
```

---

## 贡献指南

欢迎提交 Issue 或 Pull Request！

### 提交新工具

如果你有类似的可复用脚本，欢迎添加到本仓库：

1. 在根目录创建新文件夹（如 `Git/`、`Docker/` 等）
2. 添加 README.md 说明功能与使用方法
3. 更新本文件的"项目索引"表格
4. 提交 PR 并说明使用场景

### 改进建议

- 功能增强或 Bug 修复
- 文档完善与翻译
- 兼容性测试反馈
- AI 生成过程优化建议

---

## 许可证

本项目采用 [MIT 许可证](LICENSE)，详见 [LICENSE](LICENSE) 文件。

---

## 致谢

- **AI 助手**：GitHub Copilot、ChatGPT、Claude 等，提供代码生成与优化建议
- **开源社区**：PowerShell、Python 等语言与工具的开发者
- **实际用户**：所有使用本工具并提供反馈的朋友

---

**快速链接**：[FreshStart 快速开始](FreshStart/QUICK_START.md) · [PyEnvSetup 工具](PyEnvSetup/README.md) · [问题反馈](../../issues)

---

*Last Updated: 2026-01-28 | Generated with ❤️ and AI*
