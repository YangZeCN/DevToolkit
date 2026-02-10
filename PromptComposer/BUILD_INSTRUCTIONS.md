# PromptComposer 打包与发布指南

## 📦 打包说明

### 环境要求
- Python 3.8+
- PyInstaller 6.0+

### 快速打包

```bash
# 1. 进入项目目录
cd PromptComposer

# 2. 安装打包工具（如未安装）
pip install pyinstaller

# 3. 执行打包命令
pyinstaller prompt_composer.spec --clean
```

### 输出位置
- 可执行文件：`dist/PromptComposer.exe`
- 打包日志：`build/prompt_composer/`
- 警告信息：`build/prompt_composer/warn-prompt_composer.txt`

## 🔧 关键技术方案

### 1. 用户数据持久化

**问题**：PyInstaller 单文件模式下，所有资源文件被解压到临时目录（如 `AppData\Local\Temp\_MEI323402\`），程序退出后自动清理，导致用户保存的模板丢失。

**解决方案**：根据运行环境动态选择模板目录
- **开发环境**（`python prompt_composer.py`）：使用脚本所在目录的 `templates/` 文件夹
- **打包环境**（`PromptComposer.exe`）：使用 exe 文件所在目录的 `templates/` 文件夹

```python
if getattr(sys, 'frozen', False):
    # 打包后的 exe 环境：使用 exe 文件所在目录
    exe_dir = os.path.dirname(sys.executable)
    self.templates_dir = os.path.join(exe_dir, "templates")
else:
    # 开发环境
    self.templates_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates")
```

### 2. 用户数据位置

用户的模板保存在 exe 同目录下：
```
你的目录/
├── PromptComposer.exe
└── templates/
    ├── demo.md          # 内置示例
    ├── 模板1.md         # 用户保存的模板
    └── 模板2.md
```

用户可以通过以下方式访问：
1. **在程序中**：保存或加载模板时自动使用此目录
2. **手动访问**：直接打开 exe 所在文件夹的 `templates` 子文件夹
3. **快速打开**：在 PowerShell 中运行 `explorer (Split-Path (Get-Command .\PromptComposer.exe).Source)\templates`

### 3. 打包配置文件（prompt_composer.spec）

关键配置说明：

```python
a = Analysis(
    ['prompt_composer.py'],
    datas=[('templates', 'templates')],  # 将初始模板打包进 exe
    # ...
)

exe = EXE(
    # ...
    name='PromptComposer',
    console=False,  # 不显示控制台窗口（GUI 应用）
    upx=True,       # 启用 UPX 压缩减小文件体积
    # ...
)
```

**注意**：`datas` 中的 `templates` 仅用于初始模板（如 demo.md），用户保存的模板存储在 AppData 目录。

## 🚀 发布流程

### 1. 测试开发版本
```bash
python prompt_composer.py
```

### 2. 打包测试
```bash
pyinstaller prompt_composer.spec --clean
dist/PromptComposer.exe  # 启动测试
```

### 3. 验证用户数据持久化
- 启动程序
- 保存一个测试模板
- 关闭程序
- 再次启动程序
- 确认模板仍然存在

### 4. 创建压缩包（可选）
```powershell
# PowerShell
Compress-Archive -Path "dist\PromptComposer.exe" -DestinationPath "PromptComposer-v1.0.1-Windows-x64.zip"
```

### 5. 提交代码
```bash
git add .
git commit -m "fix: 修复 exe 模板持久化问题，使用 AppData 存储"
git tag -a v1.0.1 -m "Release v1.0.1: 修复模板持久化问题"
git push origin main
git push origin v1.0.1
```

### 6. 创建 GitHub Release
1. 访问 https://github.com/<username>/DevToolkit/releases/new
2. 选择标签：`v1.0.1`
3. 填写标题和说明
4. 上传 `PromptComposer.exe` 或压缩包
5. 发布

## 🐛 常见问题

### Q1: 为什么打包后文件这么大（11 MB）？
A: 单文件打包包含了完整的 Python 解释器和所有依赖库（包括 Tkinter 和 Tcl/Tk）。

**可选优化方案**：
- 使用目录打包模式（去掉 `--onefile`）：文件更小但需要多个文件
- 启用 UPX 压缩（已启用）
- 使用虚拟环境减少不必要的依赖

### Q2: 如何卸载或重置程序？
A: 删除以下内容：
1. 可执行文件：`PromptComposer.exe`
2. 用户数据：exe 同目录下的 `templates/` 文件夹

### Q3: 如何备份模板？
A: 复制 exe 同目录下的 templates 文件夹：
```powershell
# 备份（假设 exe 在 D:\Tools\PromptComposer\）
Copy-Item "D:\Tools\PromptComposer\templates" -Destination "D:\Backup\PromptComposer_templates" -Recurse

# 恢复
Copy-Item "D:\Backup\PromptComposer_templates\*" -Destination "D:\Tools\PromptComposer\templates" -Recurse -Force
```

### Q4: 如何在多台电脑间同步模板？
A: 可选方案：
1. **手动同步**：复制 exe 同目录下的 `templates\` 文件夹
2. **云盘同步**：将 exe 和 templates 文件夹放在 OneDrive、Dropbox 等云盘目录中
3. **Git 同步**：将模板文件夹初始化为 Git 仓库
4. **便携使用**：将整个文件夹（exe + templates）放在 U 盘中随身携带

### Q5: 打包时出现警告怎么办？
A: 查看 `build/prompt_composer/warn-prompt_composer.txt` 文件。常见警告：
- **缺少隐藏导入**：通常不影响运行，如有问题在 `.spec` 中添加 `hiddenimports`
- **模块未找到**：检查依赖是否正确安装

## 📝 版本记录

### v1.0.1 (2026-02-10)
- 🐛 修复：exe 打包后模板持久化问题
- ✨ 改进：使用 AppData 目录存储用户数据
- 📝 文档：添加详细的打包与发布指南

### v1.0.0 (2026-02-10)
- 🎉 首次发布
- ✨ 支持结构化提示词编辑
- ✨ 模板管理系统
- ✨ 实时预览与复制

## 📚 参考资料

- [PyInstaller 官方文档](https://pyinstaller.org/)
- [单文件打包最佳实践](https://pyinstaller.org/en/stable/operating-mode.html#bundling-to-one-file)
- [处理数据文件](https://pyinstaller.org/en/stable/spec-files.html#adding-data-files)
