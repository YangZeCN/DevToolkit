import os
import subprocess
import sys
import winreg


def set_python_environment():
    """动态修改环境变量 PATH，添加 Python 目录及其相关目录"""
    python_dir = os.path.dirname(sys.executable)  # 获取 Python 的目录
    scripts_dir = os.path.join(python_dir, "Scripts")  # Python 的 Scripts 目录
    launcher_dir = os.path.join(os.path.dirname(python_dir), "Launcher")  # 上一级的 Launcher 目录

    current_path = os.environ.get('PATH', '')

    # 添加路径到动态 PATH 环境变量
    for path in [python_dir, scripts_dir, launcher_dir]:
        if path and path not in current_path:
            current_path = f"{path};{current_path}"
    os.environ['PATH'] = current_path
    print("动态 PATH 环境变量更新成功")


def add_to_user_path(new_paths):
    """使用 setx 添加多个路径到用户级环境变量"""
    try:
        current_path = os.environ.get("PATH", "")
        paths_to_add = [path for path in new_paths if path not in current_path]

        if not paths_to_add:
            print("所有路径已存在于用户级 PATH 中")
            return

        new_path_value = f"{current_path};" + ";".join(paths_to_add)
        if len(new_path_value) > 1024:
            print(f"新 PATH 长度超过限制：{len(new_path_value)} 字符")
            return
        subprocess.run(['setx', 'PATH', new_path_value], shell=True, check=True)
        print("以下路径已成功添加到用户级 PATH：")
        for path in paths_to_add:
            print(f"  - {path}")
    except subprocess.CalledProcessError as e:
        print(f"修改用户级 PATH 失败：{e}")


def add_to_system_path(new_paths):
    """使用注册表添加多个路径到系统级环境变量"""
    key = r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    try:
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key, 0, winreg.KEY_SET_VALUE) as reg_key:
            current_path, reg_type = winreg.QueryValueEx(reg_key, "Path")
            paths_to_add = [path for path in new_paths if path not in current_path]

            if not paths_to_add:
                print("所有路径已存在于系统级 PATH 中")
                return

            new_path_value = f"{current_path};" + ";".join(paths_to_add)
            if len(new_path_value) > 2048:
                print("新的 PATH 值长度超过了注册表允许的最大长度")
                return

            winreg.SetValueEx(reg_key, "Path", 0, winreg.REG_EXPAND_SZ, new_path_value)
            print("以下路径已成功添加到系统级 PATH：")
            for path in paths_to_add:
                print(f"  - {path}")
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
    for i, package in enumerate(packages, start=1):
        print(f"[{i}/{len(packages)}] 正在安装 {package}...")
        try:
            subprocess.run([sys.executable, '-m', 'pip', 'install', package], check=True)
            print(f"{package} 安装成功")
        except subprocess.CalledProcessError:
            print(f"{package} 安装失败，请检查网络或包名")


if __name__ == "__main__":
    python_dir = os.path.dirname(sys.executable)
    scripts_dir = os.path.join(python_dir, "Scripts")
    launcher_dir = os.path.join(os.path.dirname(python_dir), "Launcher")

    paths_to_add = [python_dir, scripts_dir, launcher_dir]

    while True:
        choice = input("是否将 Python 目录及相关目录添加到全局 PATH？\n1. 添加到用户级 PATH\n2. 添加到系统级 PATH (需要管理员权限)\n3. 动态修改环境变量\n4. 跳过\n请选择 (1/2/3/4): ")
        if choice == '1':
            add_to_user_path(paths_to_add)
            break
        elif choice == '2':
            add_to_system_path(paths_to_add)
            break
        elif choice == '3':
            set_python_environment()
            break
        elif choice == '4':
            print("跳过全局 PATH 修改")
            break
        else:
            print("无效选择，请输入 1, 2 ,3 或 4")

    change_pip_source()
    install_packages()
