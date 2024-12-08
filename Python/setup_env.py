import os
import subprocess
import sys
import winreg

def set_python_environment():
    """动态修改环境变量 PATH，添加 Python 目录"""
    python_dir = os.path.dirname(sys.executable)  # 获取 Python 的目录
    current_path = os.environ.get('PATH', '')
    if python_dir not in current_path:
        os.environ['PATH'] = f"{python_dir};{current_path}"
        print(f"Python 路径已添加到动态环境变量：{python_dir}")
    else:
        print("Python 路径已存在于动态环境变量中")

def add_to_user_path(new_path):
    """使用 setx 添加路径到用户级环境变量"""
    try:
        current_path = os.environ.get("PATH", "")
        if new_path in current_path:
            print(f"{new_path} 已存在于用户级 PATH 中")
            return
        # 调用 setx 命令添加路径
        new_path_value = f"{current_path};{new_path}"
        if len(new_path_value) > 1024:  # setx command has a limit of 1024 characters
            print(f"新 PATH 长度超过限制：{len(new_path_value)} 字符")
            return
        subprocess.run(['setx', 'PATH', new_path_value], shell=True, check=True)
        print(f"{new_path} 已成功添加到用户级 PATH")
    except subprocess.CalledProcessError as e:
        print(f"修改用户级 PATH 失败：{e}")

def add_to_system_path(new_path):
    """使用注册表添加路径到系统级环境变量"""
    key = r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    try:
        # 打开注册表的系统环境变量键
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key, 0, winreg.KEY_SET_VALUE) as reg_key:
            # 获取当前 PATH 值
            current_path, reg_type = winreg.QueryValueEx(reg_key, "Path")
            new_path_value = f"{current_path};{new_path}"
            if len(new_path_value) > 2048:  # Check if the new PATH value exceeds the maximum length
                print("新的 PATH 值长度超过了注册表允许的最大长度")
            else:
                winreg.SetValueEx(reg_key, "Path", 0, winreg.REG_EXPAND_SZ, new_path_value)
                print(f"{new_path} 已成功添加到系统级 PATH")
            # 更新 PATH 值
            new_path_value = f"{current_path};{new_path}"
            winreg.SetValueEx(reg_key, "Path", 0, winreg.REG_EXPAND_SZ, new_path_value)
            print(f"{new_path} 已成功添加到系统级 PATH")
    except PermissionError:
        print("需要管理员权限来修改系统级环境变量")
    except Exception as e:
        print(f"修改系统级 PATH 失败：{e}")

def change_pip_source():
    """更换 pip 源为清华镜像"""
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'config', 'set', 'global.index-url', 'https://pypi.tuna.tsinghua.edu.cn/simple'], check=True)
        print("pip 源设置成功：使用清华源")
    except subprocess.CalledProcessError:
        print("pip 源设置失败，请检查权限或网络连接")

def install_packages():
    """批量安装常用库"""
    packages = ['numpy', 'scipy', 'matplotlib', 'pandas', 'seaborn', 'markdown']
    for package in packages:
        try:
            subprocess.run([sys.executable, '-m', 'pip', 'install', package], check=True)
            print(f"{package} 安装成功")
        except subprocess.CalledProcessError:
            print(f"{package} 安装失败，请检查网络或包名")

if __name__ == "__main__":
    # set_python_environment()
    
    # 提供全局 PATH 修改选项
    python_dir = os.path.dirname(sys.executable)
    while True:
        choice = input("是否将 Python 目录添加到全局 PATH？\n1. 添加到用户级 PATH\n2. 添加到系统级 PATH (需要管理员权限)\n3. 跳过\n请选择 (1/2/3): ")
        if choice == '1':
            add_to_user_path(python_dir)
            break
        elif choice == '2':
            add_to_system_path(python_dir)
            break
        elif choice == '3':
            print("跳过全局 PATH 修改")
            break
        else:
            print("无效选择，请输入 1, 2 或 3")

    change_pip_source()
    install_packages()
