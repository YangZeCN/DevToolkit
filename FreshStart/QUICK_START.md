# Quick Start Guide

## The Easiest Way to Install Everything

### Step 1: Download Installers

Download these files and place them in the same folder as the scripts:

- [ ] **VC_redist.x64.exe** - https://aka.ms/vs/17/release/vc_redist.x64.exe
- [ ] **VSCodeUserSetup-x64.exe** - https://code.visualstudio.com/Download
- [ ] **Git-x64.exe** - https://git-scm.com/download/win
- [ ] **TortoiseGit-x64.msi** - https://tortoisegit.org/download/
- [ ] **python-3.12.x-amd64.exe** - https://www.python.org/downloads/
- [ ] **MobaXterm-Installer.msi** (optional) - https://mobaxterm.mobatek.net/download.html

### Step 2: Run the Installation

**Option A: Double-click the batch file** (Easiest!)
```
1. Double-click "Install-Software.bat"
2. Follow the prompts
3. Wait for completion
```

**Option B: Right-click PowerShell script**
```
1. Right-click "Install-Software.ps1"
2. Select "Run with PowerShell"
3. Follow the prompts
```

**Option C: PowerShell command line**
```powershell
cd "\\sh-adg-zeyang\software\Setup"
.\Install-Software.ps1
```

### Step 3: Wait for Installation

The script will:
- ✅ Check if software is already installed
- ✅ Install VC++ Redistributable (if needed)
- ✅ Install VSCode
- ✅ Install Git (with VSCode as editor)
- ✅ Install TortoiseGit
- ✅ Install Python to **C:\Python\Python314**
- ✅ Run **setup_env.py** to configure Python environment and install packages
- ✅ Install MobaXterm (optional)

### Step 4: Restart Computer

Restart your computer to complete the installation.

### Step 5: Verify Installation

**Quick Check:**
```powershell
code --version
git --version
python --version
```

**Detailed Python Check:**
```powershell
.\Check-Python.ps1
```
This verifies Python installation path, PATH configuration, and long path support.

## That's It! 🎉

All your development tools are now installed and configured!

---

## Troubleshooting

### "Scripts are disabled" Error

Run this in PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Not running as administrator" Warning

Right-click and select "Run as administrator"

### Need Help?

Read the full documentation:
- **README_POWERSHELL.md** - Complete guide
- **COMPARISON.md** - Python vs PowerShell comparison

---

## What You Get

After installation:
- ✅ **VSCode** - Modern code editor
- ✅ **Git** - Version control (with VSCode as default editor)
- ✅ **TortoiseGit** - Windows Explorer Git integration
- ✅ **Python** - Installed to C:\Python\Python314 (added to System PATH)
- ✅ **Python Packages** - numpy, scipy, matplotlib, pandas, seaborn, markdown, beautifulsoup4
- ✅ **MobaXterm** - SSH/Terminal client (optional)

All configured and ready to use! 🚀

**Note:** Run `Check-Python.ps1` to verify Python configuration and enable long path support if needed.
