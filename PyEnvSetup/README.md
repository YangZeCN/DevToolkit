# PyEnvSetup — Python 环境配置工具

PyEnvSetup 是一个专为 Windows 系统设计的 Python 环境自动化配置工具，帮助快速完成 Python 安装后的环境准备工作。

## 文件说明

### setup_env.py

这是核心配置脚本，用于自动配置 Python 开发环境，包括 PATH 管理、pip 源切换和常用库安装。

## 功能特性

### 1. PATH 环境变量管理
脚本可以将 Python 及其相关目录添加到系统 PATH 中，提供三种配置方式：

- **用户级 PATH**：仅对当前用户生效，无需管理员权限
- **系统级 PATH**：对所有用户生效，需要管理员权限
- **临时 PATH**：仅在当前进程中生效，脚本结束后失效

自动添加的目录包括：
- Python 安装目录（如 `C:\Python3X\`）
- Scripts 目录（如 `C:\Python3X\Scripts\`），包含 pip 等工具

**智能特性**：
- 自动检测路径是否已存在，避免重复添加
- 路径标准化处理，忽略大小写差异
- 检查 PATH 长度限制，避免超出系统限制

### 2. pip 源配置
支持更换 pip 安装源以提升国内下载速度：

- 默认提供清华大学镜像源（`https://pypi.tuna.tsinghua.edu.cn/simple`）
- 支持自定义其他镜像源
- 可选择跳过此步骤

### 3. 常用库批量安装
自动安装常用的 Python 科学计算和数据处理库：

- `numpy` - 数值计算
- `scipy` - 科学计算
- `matplotlib` - 数据可视化
- `pandas` - 数据分析
- `seaborn` - 统计数据可视化
- `markdown` - Markdown 处理
- `beautifulsoup4` - HTML/XML 解析

安装过程中显示进度信息，并对每个包单独进行错误处理。

## 使用方法

### 运行脚本

```bash
python setup_env.py
```

### 交互流程

1. **PATH 配置选择**
   ```
   是否将 Python 目录及相关目录添加到全局 PATH？
   1. 添加到用户级 PATH
   2. 添加到系统级 PATH (需要管理员权限)
   3. 临时修改（仅当前进程）
   4. 跳过
   ```

2. **pip 源配置选择**
   ```
   是否更换 pip 源？
   1. 使用清华镜像
   2. 手动输入其他源
   3. 跳过
   ```

3. **自动安装常用库**
   脚本将自动按顺序安装预设的常用库。

## 注意事项

- **管理员权限**：选择系统级 PATH 修改时需要以管理员身份运行脚本
- **PATH 长度限制**：用户级 PATH 限制为 1024 字符，系统级为 2048 字符
- **网络连接**：更换 pip 源和安装包需要网络连接
- **Python 版本**：脚本使用 `sys.executable` 自动检测当前 Python 解释器路径

## 技术细节

### 核心函数

- `normalize_path(path)` - 路径标准化处理
- `get_user_path()` / `get_system_path()` - 从注册表读取 PATH
- `add_to_user_path(paths)` / `add_to_system_path(paths)` - 添加路径到 PATH
- `set_python_environment()` - 临时修改当前进程 PATH
- `change_pip_source_custom(url)` - 配置 pip 源
- `install_packages()` - 批量安装 Python 包

### 依赖库

- `os` - 操作系统接口
- `subprocess` - 子进程管理
- `sys` - 系统相关参数
- `winreg` - Windows 注册表访问

## 适用场景

- 新系统安装 Python 后的初始化配置
- 开发环境快速搭建
- 批量部署 Python 环境
- 教学演示环境准备

## 相关文件

- `notes.md` - 其他相关笔记
