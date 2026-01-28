# FreshStart — Windows 开发环境一键安装与配置

FreshStart 是一个基于 PowerShell 的自动化安装脚本集合，帮助在全新或受限的 Windows 机器上，快速、可重复地安装与配置常用开发工具（VSCode、Git、TortoiseGit、Python 等），并自动完成 Python 环境准备（更换镜像源、安装常用依赖）。

适合个人快速开机即用、企业内网部署、培训/课堂初始化等场景。

---

## 快速开始（新手友好）

最简单的使用方式请直接阅读：[FreshStart/QUICK_START.md](QUICK_START.md)

- 列出了需要提前下载的安装包
- 支持双击批处理或右键用 PowerShell 运行
- 提供验证命令与常见问题排查

---

## 核心能力

- 安装顺序优化与依赖检查（VC++ → VSCode → Git → TortoiseGit → Python → 环境配置 → Everything → MobaXterm）
- 自动将 VSCode 设置为 Git 默认编辑器
- Python 自定义安装到 C:\Python\Python314 并加入 System PATH
- 自动运行 Python 环境脚本，配置 pip 源并安装常用包
- 已安装检测、静默安装、颜色化日志、退出码处理与重启提示
- 交互式与半自动（同目录检测安装包）双模式

更多细节请见：[FreshStart/README_POWERSHELL.md](README_POWERSHELL.md)

---

## 文件说明

- Install-Software.ps1：主安装脚本（推荐入口）
- Install-Software.bat：便捷入口（双击调用 PowerShell 脚本）
- Check-Python.ps1：安装后 Python 诊断与长路径能力检查
- setup_env.py：Python 环境配置（切换 pip 源、批量安装依赖、可选 PATH 配置）
- QUICK_START.md：最简上手指南
- README_POWERSHELL.md：完整的 PowerShell 版说明书

---

## 一般使用流程

1) 准备安装包（见 Quick Start 清单）并与脚本放置在同一目录。
2) 右键“Install-Software.ps1”→“Run with PowerShell”（或双击批处理）。
3) 按提示选择安装项与可选配置，等待完成。
4) 如提示需要，重启电脑。
5) 打开全新 PowerShell 窗口，运行快速验证：

```powershell
code --version
git --version
python --version
```

需要更详细的 Python 验证，运行：

```powershell
./Check-Python.ps1
```

---

## 安装结果（期望状态）

- VSCode 安装完成并加入 PATH，右键菜单集成
- Git 安装完成且已将 VSCode 设为默认编辑器
- TortoiseGit 安装完成并集成到资源管理器
- Python 安装到 C:\Python\Python314，已加入 System PATH
- 自动执行 setup_env.py：
  - 可选切换 pip 源（默认提供清华镜像）
  - 安装常用包：numpy、scipy、matplotlib、pandas、seaborn、markdown、beautifulsoup4
- Everything 与（可选）MobaXterm 安装完成

---

## 权限与策略

- 建议以“管理员权限”运行以获得最佳体验（系统级 PATH、部分软件的系统级安装）。
- 如遇执行策略限制，执行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

或绕过单次执行：

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File "./Install-Software.ps1"
```

---

## 常见问题与排查

- 运行受限/权限不足、VC++ 依赖检查、Git 编辑器未生效、PATH 未刷新等问题，详见：

  - [FreshStart/QUICK_START.md](QUICK_START.md#troubleshooting)
  - [FreshStart/README_POWERSHELL.md](README_POWERSHELL.md#troubleshooting)

---

## 适用/不适用场景

- 适用：内网/半离线环境、重复初始化多个 Windows 开发机、批量培训环境
- 不适用：需要高度自定义的企业级软件分发（建议改造脚本或对接现有分发体系）
