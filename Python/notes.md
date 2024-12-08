### **Python 环境变量相关问题汇总**

#### **1. 需要添加的路径**

在 Windows 上安装 Python 后，通常需要将以下两个路径添加到环境变量 `PATH` 中，以便能够从命令行调用 Python 和相关工具（如 `pip`）：

1. **Python 安装目录：**
   - 该路径包含了 `python.exe`，是运行 Python 脚本的核心。
   - 示例路径：`C:\Python39\`（假设你安装了 Python 3.9）。

2. **Python 的 `Scripts` 目录：**
   - 该目录包含了 `pip.exe` 和其他工具（如 `easy_install.exe`、虚拟环境工具等）。
   - 示例路径：`C:\Python39\Scripts\`。

---

#### **2. 环境变量配置**

- 将这两个路径添加到环境变量 `PATH` 中，使得你能够在命令行中直接运行 `python` 和 `pip`，无需指定完整路径。

##### **步骤**：
1. 打开 **“环境变量”** 设置窗口：
   - 在 Windows 中，按下 `Win + S`，搜索 **“环境变量”**，然后选择 **“编辑系统环境变量”**。
   - 点击 **“环境变量”** 按钮。

2. 编辑 **`PATH` 变量**：
   - 在 **系统变量** 或 **用户变量** 中找到 `Path`，点击 **编辑**。
   - 点击 **新建**，分别添加 `C:\Python39\` 和 `C:\Python39\Scripts\`。

3. 保存设置并关闭。

---

#### **3. User Variable 与 System Variable 的区别**

1. **User Variable（用户级变量）**：
   - 仅对当前用户有效，其他用户无法访问。
   - 适用于个人计算机或开发环境。

2. **System Variable（系统级变量）**：
   - 对所有系统用户都有效。
   - 适用于所有用户需要使用的程序，通常需要管理员权限。

---

#### **4. Python Launcher（`py.exe`）的路径**

- **Python Launcher**（通常位于 `C:\Windows\` 或 `C:\Python39\`）是用于管理不同版本 Python 的工具。通过 `py` 命令可以选择运行特定版本的 Python，而无需显式指定版本号（如 `python3.8`）。
- `Python Launcher` 路径被添加到环境变量后，你可以使用 `py` 命令来切换 Python 版本，但它本身不包含 `pip` 等工具，因此仍然需要将 `Scripts` 目录添加到 `PATH` 中。

---

#### **5. 是否仅添加 `C:\Python39\` 路径即可？**

- **答案**：是的，你只需要将 **Python 安装目录（`C:\Python39\`）** 添加到 `PATH` 中即可，**不需要单独添加 `C:\Python39\Scripts\`**，因为 `Scripts` 目录是 Python 安装目录的子目录，系统会自动识别并搜索到它。
- 此处存疑，有些文档中说`PATH`不会检索子文件夹，且Python自己的安装方式会把`\Scripts`也添加到环境变量中，需要进一步验证。
- 单独询问ChatGPT，它也回答说`在 Windows 中，设置环境变量后，不会自动检索其子文件夹。如果需要访问子文件夹中的文件或程序，你需要手动将这些子文件夹添加到环境变量中。`

---

#### **6. 检查是否配置成功**

1. **查看 `PATH` 环境变量**：
   - 打开命令提示符，运行 `echo %PATH%`，检查 `C:\Python39\` 和 `C:\Python39\Scripts\` 是否已包含在输出中。

2. **验证 `python` 和 `pip` 命令**：
   - 在命令提示符中运行：
     ```cmd
     python --version
     pip --version
     ```
   - 如果返回 Python 和 pip 的版本号，说明配置成功。

---

### **总结**

为了能够在 Windows 上从命令行调用 Python 和相关工具（如 `pip`），你需要将以下路径添加到 `PATH` 环境变量中：

- **Python 安装目录（如 `C:\Python39\`）**
- **Python `Scripts` 目录（如 `C:\Python39\Scripts\`）**

如果你只添加了 Python 安装目录（`C:\Python39\`），也能自动找到 `pip` 等工具，因为 `Scripts` 目录是安装目录的子目录。

此外，**User Variable 和 System Variable** 使你可以选择是否为当前用户或所有用户设置环境变量，通常添加到 **User Variable** 就足够了。