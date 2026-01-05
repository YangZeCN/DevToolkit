# Automated Software Installation Script (PowerShell)

**No Python Required!** This PowerShell script runs natively on any Windows system.

## Why PowerShell Instead of Python?

✅ **Pre-installed** on all Windows systems (Windows 7+)  
✅ **No dependencies** needed  
✅ **Native Windows integration** for registry, admin checks, etc.  
✅ **No chicken-and-egg problem** - can install Python without needing Python  
✅ **Same performance** - installers are the bottleneck, not the script language  

## Features

- ✅ **Zero dependencies** - runs on any Windows system out of the box
- ✅ **Automated installation** of VSCode, Git, TortoiseGit, Python, and MobaXterm
- ✅ **VSCode as Git editor** - automatically configures during installation
- ✅ **Smart dependency checking** - installs VC++ Redistributable if needed
- ✅ **Python custom installation** - installs to C:\Python\Python314 with automatic PATH configuration
- ✅ **Python environment setup** - automatically runs setup_env.py to configure pip source and install packages
- ✅ **Python verification script** - Check-Python.ps1 validates installation and PATH settings
- ✅ **Already-installed detection** - skips software that's already present
- ✅ **Silent installation** - minimal user interaction
- ✅ **Comprehensive logging** - tracks all operations with color-coded output
- ✅ **Exit code handling** - properly handles success, errors, and reboot requirements

## Installation Order

1. **VC++ Redistributable x64** (if needed for TortoiseGit)
2. **VSCode** (installed first)
3. **Git** (with VSCode configured as default editor)
4. **TortoiseGit** (requires VC++ Redistributable)
5. **Python** (installed to C:\Python\Python314, added to System PATH)
6. **setup_env.py** (automatically runs after Python to configure environment and install packages)
7. **MobaXterm** (optional)

## Quick Start

### Method 1: Right-Click Run (Easiest)

1. Right-click `Install-Software.ps1`
2. Select **"Run with PowerShell"**
3. If prompted about execution policy, choose **"Y"** (Yes)
4. Follow the prompts

### Method 2: PowerShell Window

```powershell
# Navigate to the script directory
cd "\\sh-adg-zeyang\software\Setup"

# Run the script
.\Install-Software.ps1
```

### Method 3: Run as Administrator (Recommended)

1. Right-click **PowerShell** → **Run as Administrator**
2. Navigate to script directory and run:
```powershell
cd "\\sh-adg-zeyang\software\Setup"
.\Install-Software.ps1
```

## Required Installer Files

Download and place these in the same directory as the script:

| Software | Filename | Download Link |
|----------|----------|---------------|
| VC++ Redistributable | `VC_redist.x64.exe` | https://aka.ms/vs/17/release/vc_redist.x64.exe |
| VSCode | `VSCodeUserSetup-x64.exe` | https://code.visualstudio.com/Download |
| Git | `Git-x64.exe` | https://git-scm.com/download/win |
| TortoiseGit | `TortoiseGit-x64.msi` | https://tortoisegit.org/download/ |
| Python | `python-3.x.x-amd64.exe` | https://www.python.org/downloads/ |
| MobaXterm (optional) | `MobaXterm-Installer.msi` | https://mobaxterm.mobatek.net/download.html |

## Execution Policy

If you get an execution policy error, run one of these:

```powershell
# Option 1: For current user only (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: Bypass for this one script only
PowerShell.exe -ExecutionPolicy Bypass -File ".\Install-Software.ps1"
```

## Usage Examples

### Interactive Mode (Default)

The script will prompt you for each installer path:

```
Please provide paths to installer files.
Press Enter to skip an installer if not available.

VC_redist.x64.exe path (or Enter to skip): 
VSCode installer path (e.g., VSCodeUserSetup-x64.exe): C:\Downloads\VSCodeUserSetup-x64.exe
Git installer path (e.g., Git-x64.exe): 
...
```

### Auto-Detection Mode

Place installers in the same directory with standard names:
- `VC_redist.x64.exe`
- `VSCodeUserSetup-x64.exe`
- `Git-x64.exe`
- `TortoiseGit-x64.msi`
- `python-*-amd64.exe` (any Python 3.x version)
- `MobaXterm-Installer.msi`

The script will automatically detect and use them!

## What Gets Installed

### VSCode
- ✅ Silent installation
- ✅ Added to PATH
- ✅ Context menu integration (right-click → "Open with Code")
- ✅ File associations for common code files

### Git
- ✅ Silent installation with Git Bash
- ✅ Shell integration
- ✅ **VSCode automatically set as default editor**
- ✅ Added to PATH

### TortoiseGit
- ✅ Checks for VC++ Redistributable first
- ✅ Installs VC++ if missing
- ✅ Windows Explorer integration
- ✅ Context menu for Git operations

### Python
- ✅ Installed to **C:\Python\Python314** (custom location)
- ✅ System-wide installation (InstallAllUsers=1)
- ✅ Automatically added to **System PATH**
- ✅ pip included and configured
- ✅ py launcher included for version management
- ✅ File associations (.py files) configured
- ✅ Test suite excluded (faster install)
- ✅ **Automatic environment setup** via setup_env.py:
  - Configure pip source (Tsinghua mirror or custom)
  - Install common packages: numpy, scipy, matplotlib, pandas, seaborn, markdown, beautifulsoup4
  - Optional PATH configuration (user/system/dynamic)

### MobaXterm (Optional)
- ✅ SSH/terminal client
- ✅ Supports both installer and portable versions
- ✅ Skipped if not provided

## Features Explained

### Smart Detection
Checks if software is already installed by:
- Verifying common installation paths
- Checking Windows registry keys
- Running version check commands (Git, Python)

### VSCode as Git Editor
The script sets VSCode as Git's default editor by:
1. **During Git installation**: Uses `/EditorOption=VisualStudioCode` parameter
2. **Post-installation**: Runs `git config --global core.editor "code --wait"`

You can verify with:
```powershell
git config --global core.editor
```

### VC++ Redistributable Check
Before installing TortoiseGit:
1. Checks registry for VC++ Redistributable x64
2. If missing, automatically installs it
3. Only proceeds with TortoiseGit if VC++ is available

### Exit Code Handling
- **0**: Success
- **3010**: Success (reboot required)
- **Other**: Error (logged with details)

## Troubleshooting

### "Cannot be loaded because running scripts is disabled"

**Solution**: Set execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or run with bypass:
```powershell
PowerShell.exe -ExecutionPolicy Bypass -File ".\Install-Software.ps1"
```

### "Not running as administrator" warning

**Solution**: Right-click PowerShell → Run as Administrator

Some installations work fine without admin rights, but system-wide installations require it.

### VC++ Redistributable check fails

**Solution**: 
1. Download manually: https://aka.ms/vs/17/release/vc_redist.x64.exe
2. Run it before TortoiseGit installation
3. Or provide path when prompted

### VSCode not set as Git editor

**Manual fix**:
```powershell
git config --global core.editor "code --wait"
```

Or with full path:
```powershell
$codePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
git config --global core.editor "`"$codePath`" --wait"
```

### Installation fails with "Access Denied"

**Solution**: 
- Run PowerShell as Administrator
- Check antivirus isn't blocking installers
- Verify installer files aren't corrupted

### Git command not found after installation

**Solution**: Refresh your PATH or restart PowerShell:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
```

Or simply close and reopen PowerShell/Command Prompt.

## Post-Installation

After installation completes:

### 1. Restart Computer (if needed)
Some installations may require a restart to fully complete.

### 2. Verify Installations

Open a **new** PowerShell window and run:
```powershell
code --version
git --version
python --version
```

**Detailed Python Verification:**
```powershell
.\Check-Python.ps1
```

This script checks:
- ✅ Python version and installation path (C:\Python\Python314)
- ✅ Python in System/User PATH
- ✅ Long path support (>260 chars)
- ✅ pip version and installed packages
- ✅ Site packages directory

**Enable Long Path Support (if needed):**
```powershell
# Run as Administrator
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -PropertyType DWORD -Force
# Reboot required for full effect
```

### 3. Configure Git (First Time)

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4. Verify VSCode as Git Editor

```powershell
git config --global core.editor
# Should output: "C:\Users\...\Code.exe" --wait
```

### 5. Test Git Editor

```powershell
git config --global --edit
```
This should open in VSCode!

## Advanced Usage

### Python Environment Setup (setup_env.py)

After Python installation, the script automatically runs `setup_env.py` which prompts you to:

**1. PATH Configuration:**
- Add to User PATH (current user only)
- Add to System PATH (all users, requires admin)
- Dynamic modification (current session only)
- Skip (if Python installer already added to PATH)

**2. pip Source Configuration:**
- Use Tsinghua mirror (https://pypi.tuna.tsinghua.edu.cn/simple)
- Enter custom pip source URL
- Skip (keep default PyPI)

**3. Package Installation:**
Automatically installs:
- numpy, scipy, matplotlib
- pandas, seaborn
- markdown, beautifulsoup4

**Manual Execution:**
```powershell
python setup_env.py
```

### Unattended Installation

Create a configuration file or modify the script to skip prompts:

```powershell
# Example: Hardcode paths at the top of the script
$installerConfig = @{
    'vcredist' = 'C:\Installers\VC_redist.x64.exe'
    'vscode' = 'C:\Installers\VSCodeUserSetup-x64.exe'
    'git' = 'C:\Installers\Git-x64.exe'
    'tortoisegit' = 'C:\Installers\TortoiseGit-x64.msi'
    'python' = 'C:\Installers\python-3.14.2-amd64.exe'
}

Start-SoftwareInstallation -InstallerConfig $installerConfig
```

### Install Only Specific Software

Comment out unwanted installations in the `Start-SoftwareInstallation` function:

```powershell
# Step 2: Install VSCode (first priority)
if ($InstallerConfig.ContainsKey('vscode')) {
    Install-VSCode -InstallerPath $InstallerConfig['vscode']
}

# Step 5: Install Python
# if ($InstallerConfig.ContainsKey('python')) {
#     Install-Python -InstallerPath $InstallerConfig['python']
# }
```

### Custom Installation Paths

Most installers use default paths, but you can modify installer arguments in the respective functions if needed.

## Logging

All operations are logged with color-coded output:
- 🔵 **Cyan**: Info messages
- 🟢 **Green**: Success messages
- 🟡 **Yellow**: Warning messages
- 🔴 **Red**: Error messages

Logs are also stored in the `$script:InstallLog` array for review.

## Script Structure

```
Install-Software.ps1
├── Helper Functions
│   ├── Write-InstallLog       # Logging with colors
│   ├── Test-Administrator     # Check admin rights
│   ├── Test-SoftwareInstalled # Check if already installed
│   └── Invoke-InstallerSilent # Run installers silently
│
├── Installation Functions
│   ├── Test-VCRedist          # Check VC++ Redistributable
│   ├── Install-VCRedist       # Install VC++ Redistributable
│   ├── Install-VSCode         # Install VSCode
│   ├── Install-Git            # Install Git
│   ├── Find-VSCodePath        # Find VSCode installation
│   ├── Set-GitEditorToVSCode  # Configure Git editor
│   ├── Install-TortoiseGit    # Install TortoiseGit
│   ├── Install-Python         # Install Python to C:\Python\Python314
│   ├── Invoke-PythonSetupScript # Run setup_env.py after Python install
│   └── Install-MobaXterm      # Install MobaXterm
│
├── Orchestration
│   └── Start-SoftwareInstallation # Main installation flow
│
└── Entry Point
    └── Main                   # User interaction & script start
```

## Comparison: PowerShell vs Python

| Feature | PowerShell | Python |
|---------|------------|--------|
| **Pre-installed on Windows** | ✅ Yes | ❌ No |
| **Can install Python** | ✅ Yes | ❌ No (chicken-egg) |
| **Windows Integration** | ✅ Native | ⚠️ Requires modules |
| **Registry Access** | ✅ Built-in | ⚠️ Requires winreg |
| **Admin Check** | ✅ Built-in | ⚠️ Requires ctypes |
| **Performance** | ✅ Fast | ✅ Fast (same) |
| **Code Readability** | ✅ Good | ✅ Good |
| **Maintenance** | ✅ Easy | ✅ Easy |

**Winner for this use case: PowerShell** ✅

## System Requirements

- Windows 7 or later
- PowerShell 5.1 or later (pre-installed on Windows 10/11)
- Administrator privileges (recommended)
- Internet connection (for downloading installers)

## Security Notes

- Always download installers from official sources
- Verify installer checksums when possible
- Review the script before running
- Run from a trusted location
- The script does not download files automatically (for security)

## Support & Troubleshooting

If you encounter issues:
1. Check the color-coded log output
2. Verify all installer files are 64-bit versions
3. Ensure you have administrator privileges
4. Try running installers manually to see specific errors
5. Check Windows Event Viewer for installation logs
6. Verify your antivirus isn't blocking installations

## License

This script is provided as-is for automating software installation on Windows systems.

---

**Made with PowerShell** 💙
**No Python Required** ✅
