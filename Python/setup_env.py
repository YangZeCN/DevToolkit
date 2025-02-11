import os
import subprocess
import sys
import winreg

def normalize_path(path):
    """
    标准化路径：
    - os.path.normpath() 去除冗余分隔符和不必要的符号
    - os.path.normcase() 在 Windows 下将路径转换为小写，忽略大小写差异
    """
    return os.path.normcase(os.path.normpath(path))

def get_user_path():
    """从注册表获取用户级 PATH"""
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment") as key:
            return winreg.QueryValueEx(key, "Path")[0]
    except FileNotFoundError:
        return ""

def add_to_user_path(new_paths):
    """添加路径到用户级 PATH"""
    try:
        current_path = get_user_path()
        # 将当前 PATH 按分号分割，并标准化每个路径
        current_paths = [normalize_path(p) for p in current_path.split(";") if p.strip()]
        # 仅添加那些标准化后不存在于 current_paths 中的路径
        paths_to_add = [path for path in new_paths if normalize_path(path) not in current_paths]

        if not paths_to_add:
            print("所有路径已存在于用户级 PATH 中")
            return

        # 如果当前 PATH 为空，则无需加分号
        if current_path:
            new_path_value = current_path + ";" + ";".join(paths_to_add)
        else:
            new_path_value = ";".join(paths_to_add)

        if len(new_path_value) > 1024:
            print(f"新 PATH 长度超过限制：{len(new_path_value)} 字符")
            return

        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment", 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, "Path", 0, winreg.REG_EXPAND_SZ, new_path_value)
        print("以下路径已成功添加到用户级 PATH：")
        for path in paths_to_add:
            print(f"  - {path}")
    except Exception as e:
        print(f"修改用户级 PATH 失败：{e}")

def get_system_path():
    """从注册表获取系统级 PATH"""
    try:
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment") as key:
            return winreg.QueryValueEx(key, "Path")[0]
    except FileNotFoundError:
        return ""

def add_to_system_path(new_paths):
    """添加路径到系统级 PATH"""
    try:
        current_path = get_system_path()
        current_paths = [normalize_path(p) for p in current_path.split(";") if p.strip()]
        paths_to_add = [path for path in new_paths if normalize_path(path) not in current_paths]

        if not paths_to_add:
            print("所有路径已存在于系统级 PATH 中")
            return

        if current_path:
            new_path_value = current_path + ";" + ";".join(paths_to_add)
        else:
            new_path_value = ";".join(paths_to_add)

        if len(new_path_value) > 2048:
            print("新的 PATH 值长度超过了注册表允许的最大长度")
            return

        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SYSTEM\CurrentControlSet\Control\Session Manager\Environment", 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, "Path", 0, winreg.REG_EXPAND_SZ, new_path_value)
        print("以下路径已成功添加到系统级 PATH：")
        for path in paths_to_add:
            print(f"  - {path}")
    except PermissionError:
        print("需要管理员权限来修改系统级环境变量")
    except Exception as e:
        print(f"修改系统级 PATH 失败：{e}")

def set_python_environment():
    """动态修改当前进程的 PATH 环境变量"""
    python_dir = os.path.dirname(sys.executable)
    scripts_dir = os.path.join(python_dir, "Scripts")
    # 如果需要添加 launcher 目录，可在此处定义 launcher_dir
    # launcher_dir = os.path.join(os.path.dirname(python_dir), "Launcher")
    # 这里暂时只添加 python_dir 与 scripts_dir
    paths_to_add = [python_dir, scripts_dir]
    
    current_path = os.environ.get('PATH', '')
    current_paths = [normalize_path(p) for p in current_path.split(";") if p.strip()]

    # 将新的路径添加到当前 PATH 中（添加到最前面）
    for path in paths_to_add:
        if path and normalize_path(path) not in current_paths:
            current_path = f"{path};" + current_path
            # 同时更新 current_paths 列表
            current_paths.insert(0, normalize_path(path))
    os.environ['PATH'] = current_path
    print("动态 PATH 环境变量更新成功")

def change_pip_source_custom(source_url=None):
    """更换 pip 源"""
    try:
        if source_url is None:
            # 默认使用清华镜像
            source_url = 'https://pypi.tuna.tsinghua.edu.cn/simple'
        subprocess.run([sys.executable, '-m', 'pip', 'config', 'set', 'global.index-url', source_url], check=True)
        print(f"pip 源设置成功：使用 {source_url}")
    except subprocess.CalledProcessError:
        print("pip 源设置失败，请检查权限或网络连接")
        

def install_packages():
    """批量安装常用库"""
    packages = ['numpy', 'scipy', 'matplotlib', 'pandas', 'seaborn', 'markdown', 'beautifulsoup4']
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
    # 如果需要 launcher_dir，可以在此定义，但需保证该目录存在
    # launcher_dir = os.path.join(os.path.dirname(python_dir), "Launcher")
    
    # 这里暂时只使用 python_dir 和 scripts_dir
    paths_to_add = [python_dir, scripts_dir]

    while True:
        choice = input(
            "是否将 Python 目录及相关目录添加到全局 PATH？\n"
            "1. 添加到用户级 PATH\n"
            "2. 添加到系统级 PATH (需要管理员权限)\n"
            "3. 动态修改环境变量\n"
            "4. 跳过\n"
            "请选择 (1/2/3/4): "
        )
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
            print("无效选择，请输入 1, 2, 3 或 4")

    while True:
        choice = input(
            "是否更换 pip 源？\n"
            "1. 使用清华镜像\n"
            "2. 手动输入其他源\n"
            "3. 跳过\n"
            "请选择 (1/2/3): "
        )
        if choice == '1':
            change_pip_source_custom()
            break
        elif choice == '2':
            custom_source = input("请输入自定义 pip 源 URL: ")
            change_pip_source_custom(custom_source)
            break
        elif choice == '3':
            print("跳过更换 pip 源")
            break
        else:
            print("无效选择，请输入 1, 2 或 3")

    install_packages()
