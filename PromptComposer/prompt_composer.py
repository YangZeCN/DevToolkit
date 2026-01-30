#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
桌面端结构化提示词生成工具
适用于 AI 对话场景的提示词模板管理
"""

import os
import re
import glob
from tkinter import Tk, Frame, Label, Entry, Text, Button, messagebox, simpledialog, Scrollbar
from tkinter.ttk import Combobox, PanedWindow
from tkinter import BOTH, LEFT, RIGHT, TOP, BOTTOM, X, Y, VERTICAL, HORIZONTAL, END, DISABLED, NORMAL


class PromptComposer:
    """提示词生成器主类"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("PromptComposer")
        self.root.geometry("1000x700")
        
        # 模板目录
        self.templates_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "templates")
        self._ensure_templates_folder()
        
        # 字段名中英文映射
        self.field_names = {
            "Role": "角色",
            "Context": "背景",
            "Task": "任务",
            "Examples": "示例",
            "Constraints": "约束",
            "User Input": "用户输入"
        }
        
        # 占位符文本
        self.placeholders = {
            "Role": "例如：资深 Python 架构师、专业翻译专家、技术文档撰写者...",
            "Context": "任务发生的背景信息...",
            "Task": "明确需要完成的核心目标...",
            "Examples": "提供 Few-Shot 样本，如 <问>:<答>...",
            "Constraints": "格式限制、风格要求、否定词...",
            "User Input": "在此粘贴需要处理的原始数据/代码/文本..."
        }
        
        # 输入框引用
        self.inputs = {}
        # 占位符状态标记
        self.placeholder_active = {}
        
        self._create_widgets()
        self._load_templates()
        
    def _ensure_templates_folder(self):
        """确保模板文件夹存在，并生成 demo.md"""
        try:
            if not os.path.exists(self.templates_dir):
                os.makedirs(self.templates_dir)
                print(f"✓ 已创建模板文件夹: {self.templates_dir}")
            
            # 检查是否需要生成 demo.md
            demo_file = os.path.join(self.templates_dir, "demo.md")
            if not os.path.exists(demo_file):
                self._generate_demo_template()
        except Exception as e:
            messagebox.showerror("错误", f"初始化模板文件夹失败：{e}")
    
    def _generate_demo_template(self):
        """生成示例模板：代码审查助手"""
        demo_content = """# Role
你是一位资深的代码审查专家，拥有 10+ 年的软件工程经验，精通多种编程语言和最佳实践。

# Context
在软件开发过程中，代码审查是保证代码质量的关键环节。需要识别潜在的 bug、安全隐患、性能问题和代码规范问题。

# Task
请对提供的代码进行全面审查，识别以下问题：
1. 逻辑错误和潜在 bug
2. 安全漏洞（如注入攻击、未验证输入等）
3. 性能瓶颈（如不必要的循环、低效算法）
4. 代码规范问题（命名、注释、结构）
5. 可维护性和可扩展性建议

# Examples
示例 1:
<问题代码>
```python
def get_user(id):
    query = "SELECT * FROM users WHERE id = " + id
    return db.execute(query)
```
<审查意见>
❌ SQL 注入风险：直接拼接用户输入到 SQL 语句
✅ 建议：使用参数化查询 `db.execute("SELECT * FROM users WHERE id = ?", (id,))`

示例 2:
<问题代码>
```python
for i in range(len(items)):
    for j in range(len(items)):
        if items[i] == items[j] and i != j:
            print("重复")
```
<审查意见>
❌ 性能问题：O(n²) 时间复杂度
✅ 建议：使用 set 去重 `if len(items) != len(set(items)): print("重复")`

# Constraints
- 输出格式：以优先级分类（高/中/低）的问题清单
- 每个问题必须包含：问题描述 + 具体代码行 + 修复建议
- 使用 Markdown 格式，便于阅读
- 如果代码没有明显问题，也要给出积极反馈

# User Input
<user_input>
```python
def process_data(data):
    result = []
    for item in data:
        result.append(item * 2)
    return result
```
</user_input>
"""
        try:
            demo_file = os.path.join(self.templates_dir, "demo.md")
            with open(demo_file, "w", encoding="utf-8") as f:
                f.write(demo_content)
            print(f"✓ 已生成示例模板: demo.md")
        except Exception as e:
            messagebox.showerror("错误", f"生成示例模板失败：{e}")
    
    def _create_widgets(self):
        """创建所有 UI 组件"""
        # 顶部工具栏
        self._create_toolbar()
        
        # 左右分栏
        paned = PanedWindow(self.root, orient=HORIZONTAL)
        paned.pack(fill=BOTH, expand=True, padx=5, pady=5)
        
        # 左侧输入区
        left_frame = Frame(paned)
        paned.add(left_frame, weight=1)
        self._create_input_area(left_frame)
        
        # 右侧预览区
        right_frame = Frame(paned)
        paned.add(right_frame, weight=1)
        self._create_preview_area(right_frame)
    
    def _create_toolbar(self):
        """创建顶部工具栏"""
        toolbar = Frame(self.root, bg="#f0f0f0")
        toolbar.pack(side=TOP, fill=X, padx=5, pady=(15, 10))
        
        # 模板选择
        Label(toolbar, text="模板选择:", bg="#f0f0f0", font=("微软雅黑", 10)).pack(side=LEFT, padx=5)
        self.template_combo = Combobox(toolbar, state="readonly", font=("微软雅黑", 9), width=40)
        self.template_combo.pack(side=LEFT, padx=5)
        self.template_combo.bind("<<ComboboxSelected>>", self._on_template_selected)
        
        # 保存按钮
        Button(toolbar, text="💾 保存为模板", command=self._save_template, 
               font=("微软雅黑", 9), cursor="hand2").pack(side=LEFT, padx=5)
    
    def _create_input_area(self, parent):
        """创建左侧输入区"""
        canvas_frame = Frame(parent)
        canvas_frame.pack(fill=BOTH, expand=True)
        
        # Role (多行，高度 3)
        self._create_entry_input(canvas_frame, "Role", is_multiline=True, height=3)
        
        # Context, Task, Examples, Constraints (多行，固定高度)
        for field in ["Context", "Task", "Examples", "Constraints"]:
            self._create_entry_input(canvas_frame, field, is_multiline=True, height=4)
        
        # User Input (大文本框，占据剩余空间)
        self._create_entry_input(canvas_frame, "User Input", is_multiline=True, expand=True)
    
    def _create_entry_input(self, parent, field_name, is_multiline=False, height=1, expand=False):
        """创建单个输入框"""
        frame = Frame(parent)
        if expand:
            frame.pack(fill=BOTH, expand=True, pady=5)
        else:
            frame.pack(fill=X, pady=5)
        
        # 标签
        display_name = self.field_names.get(field_name, field_name)
        Label(frame, text=f"{display_name}:", font=("微软雅黑", 10, "bold")).pack(anchor="w")
        
        if is_multiline:
            # 创建文本框和滚动条的容器
            text_frame = Frame(frame)
            text_frame.pack(fill=BOTH, expand=expand)
            
            # 滚动条
            scrollbar = Scrollbar(text_frame)
            scrollbar.pack(side=RIGHT, fill=Y)
            
            # 多行文本框
            widget = Text(text_frame, font=("Consolas", 10), wrap="char", 
                         height=height if not expand else 10, yscrollcommand=scrollbar.set)
            widget.pack(side=LEFT, fill=BOTH, expand=True)
            scrollbar.config(command=widget.yview)
        else:
            # 单行输入框
            widget = Entry(frame, font=("微软雅黑", 10))
            widget.pack(fill=X)
        
        # 存储引用
        self.inputs[field_name] = widget
        self.placeholder_active[field_name] = False
        
        # 绑定事件
        widget.bind("<FocusIn>", lambda e: self._on_focus_in(field_name))
        widget.bind("<FocusOut>", lambda e: self._on_focus_out(field_name))
        
        # 初始化占位符
        self._show_placeholder(field_name)
    
    def _create_preview_area(self, parent):
        """创建右侧预览区"""
        # 标题和按钮在同一行
        header_frame = Frame(parent)
        header_frame.pack(fill=X, pady=(0, 5))
        
        Label(header_frame, text="提示词预览:", font=("微软雅黑", 10, "bold")).pack(side=LEFT)
        
        # 按钮容器（靠右，留出滚动条宽度）
        button_frame = Frame(header_frame)
        button_frame.pack(side=RIGHT, padx=(0, 15))
        
        # 清空按钮
        Button(button_frame, text="🗑️ 清空内容", command=self._clear_all, 
               font=("微软雅黑", 9), cursor="hand2").pack(side=LEFT, padx=5)
        
        # 复制按钮
        Button(button_frame, text="📋 复制到剪贴板", command=self._copy_to_clipboard,
               font=("微软雅黑", 9), cursor="hand2").pack(side=LEFT, padx=5)
        
        # 创建文本框和滚动条的容器
        text_frame = Frame(parent)
        text_frame.pack(fill=BOTH, expand=True)
        
        # 滚动条
        scrollbar = Scrollbar(text_frame)
        scrollbar.pack(side=RIGHT, fill=Y)
        
        # 预览文本框
        self.preview_text = Text(text_frame, font=("Consolas", 10), wrap="char", 
                                state=DISABLED, bg="#f9f9f9", yscrollcommand=scrollbar.set)
        self.preview_text.pack(side=LEFT, fill=BOTH, expand=True)
        scrollbar.config(command=self.preview_text.yview)
    
    def _show_placeholder(self, field_name):
        """显示占位符"""
        widget = self.inputs[field_name]
        placeholder = self.placeholders[field_name]
        
        widget.delete("1.0", END)
        widget.insert("1.0", placeholder)
        widget.config(fg="gray")
        
        self.placeholder_active[field_name] = True
    
    def _hide_placeholder(self, field_name):
        """隐藏占位符"""
        widget = self.inputs[field_name]
        
        if self.placeholder_active[field_name]:
            widget.delete("1.0", END)
            widget.config(fg="black")
            self.placeholder_active[field_name] = False
    
    def _on_focus_in(self, field_name):
        """输入框获得焦点"""
        self._hide_placeholder(field_name)
    
    def _on_focus_out(self, field_name):
        """输入框失去焦点"""
        widget = self.inputs[field_name]
        
        # 检查内容是否为空
        if isinstance(widget, Entry):
            content = widget.get().strip()
        else:
            content = widget.get("1.0", END).strip()
        
        
        # 更新预览
        self.update_preview()
    
    def _get_field_value(self, field_name):
        """获取输入框的实际内容（排除占位符）"""
        if self.placeholder_active.get(field_name, False):
            return ""
        
        widget = self.inputs[field_name]
        if isinstance(widget, Entry):
            return widget.get().strip()
        else:
            return widget.get("1.0", END).strip()
    
    def update_preview(self):
        """更新预览区域"""
        sections = []
        
        for field_name in ["Role", "Context", "Task", "Examples", "Constraints", "User Input"]:
            content = self._get_field_value(field_name)
            
            if content:
                display_name = self.field_names.get(field_name, field_name)
                if field_name == "User Input":
                    # User Input 需要特殊处理，包裹 XML 标签
                    sections.append(f"# {display_name}\n<user_input>\n{content}\n</user_input>")
                else:
                    sections.append(f"# {display_name}\n{content}")
        
        # 拼接所有非空部分
        preview_content = "\n\n".join(sections)
        
        # 更新预览文本框
        self.preview_text.config(state=NORMAL)
        self.preview_text.delete("1.0", END)
        self.preview_text.insert("1.0", preview_content)
        self.preview_text.config(state=DISABLED)
    
    def _copy_to_clipboard(self):
        """复制到剪贴板"""
        try:
            content = self.preview_text.get("1.0", END).strip()
            if not content:
                messagebox.showwarning("提示", "预览区域为空，无内容可复制")
                return
            
            self.root.clipboard_clear()
            self.root.clipboard_append(content)
            messagebox.showinfo("成功", "已复制到剪贴板！")
        except Exception as e:
            messagebox.showerror("错误", f"复制失败：{e}")
    
    def _load_templates(self):
        """加载所有模板"""
        try:
            # 扫描模板文件
            template_files = glob.glob(os.path.join(self.templates_dir, "*.md"))
            template_names = [os.path.splitext(os.path.basename(f))[0] for f in template_files]
            
            # 按字母排序
            template_names.sort()
            
            # 添加"清空/默认"选项
            options = ["[ 清空/默认 ]"] + template_names
            self.template_combo["values"] = options
            
            # 默认选择第一个模板（如果有）
            if len(template_names) > 0:
                self.template_combo.current(1)  # 选择第一个实际模板（跳过"清空"）
                self._load_template(template_names[0])
            else:
                self.template_combo.current(0)
        except Exception as e:
            messagebox.showerror("错误", f"加载模板列表失败：{e}")
    
    def _on_template_selected(self, event):
        """模板选择事件"""
        selected = self.template_combo.get()
        
        if selected == "[ 清空/默认 ]":
            self._clear_all()
        else:
            self._load_template(selected)
    
    def _load_template(self, template_name):
        """加载指定模板"""
        try:
            template_path = os.path.join(self.templates_dir, f"{template_name}.md")
            
            with open(template_path, "r", encoding="utf-8") as f:
                content = f.read()
            
            # 使用正则表达式解析 Markdown
            # 匹配格式：# 标题\n内容（直到下一个 # 或文件结束）
            pattern = r'^# (.+?)\n(.*?)(?=^# |\Z)'
            matches = re.findall(pattern, content, re.MULTILINE | re.DOTALL)
            
            # 清空所有输入框
            self._clear_all_fields()
            
            # 填充内容
            for title, text in matches:
                title = title.strip()
                text = text.strip()
                
                # 中文标题转换为英文字段名
                chinese_to_field = {v: k for k, v in self.field_names.items()}
                field_name = chinese_to_field.get(title, title)
                
                # 处理用户输入的特殊情况（移除 <user_input> 标签）
                if field_name == "User Input" or title == "用户输入":
                    text = re.sub(r'^<user_input>\s*|\s*</user_input>$', '', text, flags=re.MULTILINE).strip()
                
                # 填充到对应输入框
                if field_name in self.inputs:
                    widget = self.inputs[field_name]
                    self.placeholder_active[field_name] = False
                    
                    widget.delete("1.0", END)
                    widget.insert("1.0", text)
                    widget.config(fg="black")
            
            # 更新预览
            self.update_preview()
            
        except FileNotFoundError:
            messagebox.showerror("错误", f"模板文件不存在：{template_name}.md")
        except Exception as e:
            messagebox.showerror("错误", f"加载模板失败：{e}")
    
    def _save_template(self):
        """保存当前内容为模板"""
        # 弹出对话框获取模板名称
        name = simpledialog.askstring("保存模板", "请输入模板名称：", parent=self.root)
        
        if not name:
            return
        
        # 过滤非法字符
        name = re.sub(r'[\\/:*?"<>|]', '_', name)
        
        # 生成文件内容
        sections = []
        for field_name in ["Role", "Context", "Task", "Examples", "Constraints", "User Input"]:
            content = self._get_field_value(field_name)
            
            if content:
                display_name = self.field_names.get(field_name, field_name)
                if field_name == "User Input":
                    sections.append(f"# {display_name}\n<user_input>\n{content}\n</user_input>")
                else:
                    sections.append(f"# {display_name}\n{content}")
        
        template_content = "\n\n".join(sections)
        
        if not template_content.strip():
            messagebox.showwarning("提示", "当前内容为空，无法保存模板")
            return
        
        try:
            # 保存文件
            template_path = os.path.join(self.templates_dir, f"{name}.md")
            with open(template_path, "w", encoding="utf-8") as f:
                f.write(template_content)
            
            messagebox.showinfo("成功", f"模板已保存：{name}.md")
            
            # 刷新模板列表
            self._load_templates()
            
            # 自动选中新保存的模板
            template_names = list(self.template_combo["values"])
            if name in template_names:
                self.template_combo.current(template_names.index(name))
        
        except Exception as e:
            messagebox.showerror("错误", f"保存模板失败：{e}")
    
    def _clear_all(self):
        """清空所有内容"""
        self._clear_all_fields()
        self.update_preview()
    
    def _clear_all_fields(self):
        """清空所有输入框并恢复占位符"""
        for field_name in self.inputs:
            widget = self.inputs[field_name]
            
            if isinstance(widget, Entry):
                widget.delete(0, END)
            else:
                widget.delete("1.0", END)
            
            # 恢复占位符
            self._show_placeholder(field_name)


def main():
    """主函数"""
    root = Tk()
    app = PromptComposer(root)
    root.mainloop()


if __name__ == "__main__":
    main()
