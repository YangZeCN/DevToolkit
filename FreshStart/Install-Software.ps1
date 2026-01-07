<#
.SYNOPSIS
    Automated Software Installation Script for Windows
    
.DESCRIPTION
    Installs VSCode, Git, TortoiseGit, Python, and MobaXterm (optional)
    Automatically checks dependencies and configures VSCode as Git editor
    
.NOTES
    Author: Automated Setup Script
    Requires: Windows PowerShell 5.1+ or PowerShell Core
    Execution Policy: May need to run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#>

#Requires -Version 5.1

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Installation log
$script:InstallLog = @()

#region Helper Functions

function Write-InstallLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    $script:InstallLog += $logEntry
    
    switch ($Level) {
        'Success' { Write-Host $logEntry -ForegroundColor Green }
        'Warning' { Write-Host $logEntry -ForegroundColor Yellow }
        'Error'   { Write-Host $logEntry -ForegroundColor Red }
        default   { Write-Host $logEntry -ForegroundColor Cyan }
    }
}

function Test-Administrator {
    <#
    .SYNOPSIS
        Check if script is running with administrator privileges
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-SoftwareInstalled {
    <#
    .SYNOPSIS
        Check if software is already installed
    #>
    param(
        [string]$SoftwareName,
        [string[]]$CheckPaths,
        [hashtable[]]$RegistryKeys
    )
    
    # Check file paths
    if ($CheckPaths) {
        foreach ($path in $CheckPaths) {
            if (Test-Path $path) {
                Write-InstallLog "$SoftwareName is already installed at: $path" -Level Success
                return $true
            }
        }
    }
    
    # Check registry
    if ($RegistryKeys) {
        foreach ($regKey in $RegistryKeys) {
            try {
                $key = Get-ItemProperty -Path $regKey.Path -Name $regKey.Value -ErrorAction SilentlyContinue
                if ($key) {
                    Write-InstallLog "$SoftwareName is already installed (found in registry)" -Level Success
                    return $true
                }
            }
            catch {
                # Continue checking other keys
            }
        }
    }
    
    return $false
}

function Invoke-InstallerSilent {
    <#
    .SYNOPSIS
        Run an installer with specified arguments
    #>
    param(
        [string]$InstallerPath,
        [string[]]$Arguments,
        [switch]$UseMsiExec
    )
    
    if (-not (Test-Path $InstallerPath)) {
        Write-InstallLog "Installer not found: $InstallerPath" -Level Error
        return $false
    }
    
    try {
        Write-InstallLog "Running installer: $InstallerPath" -Level Info
        Write-InstallLog "Arguments: $($Arguments -join ' ')" -Level Info
        
        if ($UseMsiExec) {
            # Build MSI arguments properly
            $msiArgs = @("/i", $InstallerPath) + $Arguments
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -NoNewWindow
        }
        else {
            $process = Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
        }
        
        if ($process.ExitCode -eq 0) {
            Write-InstallLog "Installation completed successfully (Exit Code: 0)" -Level Success
            return $true
        }
        elseif ($process.ExitCode -eq 3010) {
            Write-InstallLog "Installation completed successfully (Reboot required - Exit Code: 3010)" -Level Warning
            return $true
        }
        elseif ($process.ExitCode -eq 1603) {
            Write-InstallLog "Installation failed with exit code: 1603 (Fatal error during installation)" -Level Error
            Write-InstallLog "Common causes: Insufficient permissions, previous install not cleaned up, or system requirements not met" -Level Warning
            if ($UseMsiExec) {
                Write-InstallLog "Check Windows Event Viewer > Windows Logs > Application for details" -Level Info
                Write-InstallLog "Or try running manually: msiexec /i `"$InstallerPath`" /l*v install.log" -Level Info
            }
            return $false
        }
        else {
            Write-InstallLog "Installation failed with exit code: $($process.ExitCode)" -Level Error
            if ($UseMsiExec) {
                Write-InstallLog "MSI error code: $($process.ExitCode). Check Windows Installer error codes for details." -Level Warning
            }
            return $false
        }
    }
    catch {
        Write-InstallLog "Error running installer: $_" -Level Error
        return $false
    }
}

#endregion

#region Installation Functions

function Test-VCRedist {
    <#
    .SYNOPSIS
        Check if Visual C++ Redistributable x64 2015-2022 is installed
    #>
    Write-InstallLog "Checking for Visual C++ Redistributable x64 (2015-2022)..." -Level Info
    
    # Check for VC++ 2015-2022 (version 14.x)
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64"
    )
    
    # Also check for newer versions (VC++ 2015-2022 uses version 14.x)
    $minVersion = [Version]"14.30.30704"  # Minimum version for TortoiseGit 2.18
    
    foreach ($regPath in $registryPaths) {
        try {
            if (Test-Path $regPath) {
                $vcInfo = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
                if ($vcInfo) {
                    # Check if installed
                    if ($vcInfo.Installed -eq 1) {
                        # Check version
                        if ($vcInfo.Version) {
                            $installedVersion = [Version]$vcInfo.Version
                            Write-InstallLog "Found VC++ Redistributable version: $installedVersion" -Level Info
                            
                            if ($installedVersion -ge $minVersion) {
                                Write-InstallLog "VC++ Redistributable x64 (2015-2022) is installed with sufficient version" -Level Success
                                return $true
                            }
                            else {
                                Write-InstallLog "VC++ Redistributable version $installedVersion is too old. Need $minVersion or later." -Level Warning
                            }
                        }
                        else {
                            # No version info, but it's installed - assume it's ok
                            Write-InstallLog "VC++ Redistributable x64 is installed (version unknown)" -Level Success
                            return $true
                        }
                    }
                }
            }
        }
        catch {
            # Continue to next path
        }
    }
    
    Write-InstallLog "VC++ Redistributable x64 (2015-2022) is NOT installed or version is too old" -Level Warning
    Write-InstallLog "Please download latest version from: https://aka.ms/vs/17/release/vc_redist.x64.exe" -Level Info
    return $false
}

function Install-VCRedist {
    <#
    .SYNOPSIS
        Install Visual C++ Redistributable x64 2015-2022
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing Visual C++ Redistributable x64 (2015-2022)..." -Level Info
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "VC_redist.x64.exe not found" -Level Error
        Write-InstallLog "Download LATEST version from: https://aka.ms/vs/17/release/vc_redist.x64.exe" -Level Warning
        Write-InstallLog "TortoiseGit requires the latest 2015-2022 redistributable version" -Level Warning
        return $false
    }
    
    $arguments = @("/install", "/quiet", "/norestart")
    $result = Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
    
    if ($result) {
        Write-InstallLog "Please wait for VC++ Redistributable to complete installation..." -Level Info
        Start-Sleep -Seconds 3
    }
    
    return $result
}

function Install-VSCode {
    <#
    .SYNOPSIS
        Install Visual Studio Code
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing Visual Studio Code..." -Level Info
    
    # Check if already installed
    $checkPaths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles}\Microsoft VS Code\Code.exe"
    )
    
    if (Test-SoftwareInstalled -SoftwareName "VSCode" -CheckPaths $checkPaths) {
        return $true
    }
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "VSCode installer not found" -Level Error
        Write-InstallLog "Download from: https://code.visualstudio.com/Download" -Level Info
        return $false
    }
    
    $arguments = @(
        "/VERYSILENT",
        "/NORESTART",
        "/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"
    )
    
    return Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
}

function Find-VSCodePath {
    <#
    .SYNOPSIS
        Find VSCode installation path
    #>
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles}\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

function Set-GitEditorToVSCode {
    <#
    .SYNOPSIS
        Configure VSCode as Git default editor
    #>
    $vscodePath = Find-VSCodePath
    
    if (-not $vscodePath) {
        Write-InstallLog "VSCode not found, cannot set as Git editor" -Level Warning
        return $false
    }
    
    try {
        Write-InstallLog "Setting VSCode as Git default editor..." -Level Info
        
        # Check if git is available
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue
        if (-not $gitCmd) {
            Write-InstallLog "Git command not found in PATH yet, will set editor after restart" -Level Warning
            return $false
        }
        
        & git config --global core.editor "`"$vscodePath`" --wait"
        
        Write-InstallLog "Git editor set to VSCode successfully" -Level Success
        return $true
    }
    catch {
        Write-InstallLog "Failed to set Git editor: $_" -Level Error
        return $false
    }
}

function Install-Git {
    <#
    .SYNOPSIS
        Install Git for Windows
    #>
    param(
        [string]$InstallerPath,
        [switch]$SetVSCodeAsEditor
    )
    
    Write-InstallLog "Installing Git..." -Level Info
    
    # Check if already installed
    $checkPaths = @(
        "${env:ProgramFiles}\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    )
    
    $alreadyInstalled = Test-SoftwareInstalled -SoftwareName "Git" -CheckPaths $checkPaths
    
    if ($alreadyInstalled) {
        if ($SetVSCodeAsEditor) {
            Set-GitEditorToVSCode
        }
        return $true
    }
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "Git installer not found" -Level Error
        Write-InstallLog "Download from: https://git-scm.com/download/win" -Level Info
        return $false
    }
    
    $arguments = @(
        "/VERYSILENT",
        "/NORESTART",
        "/NOCANCEL",
        "/SP-",
        "/CLOSEAPPLICATIONS",
        "/RESTARTAPPLICATIONS",
        "/COMPONENTS=icons,ext\shellhere,assoc,assoc_sh"
    )
    
    # Try to set VSCode as editor during installation
    if ($SetVSCodeAsEditor -and (Find-VSCodePath)) {
        $arguments += "/EditorOption=VisualStudioCode"
        Write-InstallLog "Setting VSCode as Git editor during installation" -Level Info
    }
    
    $result = Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
    
    # Try to set editor post-installation if not set during install
    if ($result -and $SetVSCodeAsEditor) {
        Start-Sleep -Seconds 2
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Set-GitEditorToVSCode
    }
    
    return $result
}

function Install-TortoiseGit {
    <#
    .SYNOPSIS
        Install TortoiseGit
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing TortoiseGit..." -Level Info
    
    # Check if VC Redistributable is installed
    if (-not (Test-VCRedist)) {
        Write-InstallLog "VC++ Redistributable x64 (2015-2022) is required for TortoiseGit" -Level Error
        Write-InstallLog "Installing VC++ Redistributable first..." -Level Warning
        
        # Try to find and install VC_redist
        $vcredist = Get-ChildItem -Path (Split-Path $InstallerPath) -Filter "VC_redist.x64.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($vcredist) {
            Install-VCRedist -InstallerPath $vcredist.FullName
        }
        else {
            Write-InstallLog "Please install VC++ Redistributable x64 (2015-2022) manually first" -Level Error
            Write-InstallLog "Download from: https://aka.ms/vs/17/release/vc_redist.x64.exe" -Level Info
            return $false
        }
    }
    
    # Check if already installed
    $checkPaths = @(
        "${env:ProgramFiles}\TortoiseGit\bin\TortoiseGitProc.exe"
    )
    
    if (Test-SoftwareInstalled -SoftwareName "TortoiseGit" -CheckPaths $checkPaths) {
        return $true
    }
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "TortoiseGit installer not found" -Level Error
        Write-InstallLog "Download from: https://tortoisegit.org/download/" -Level Info
        return $false
    }
    
    # TortoiseGit typically comes as .msi
    if ($InstallerPath -match '\.msi$') {
        # Create log file for troubleshooting
        $logFile = Join-Path $env:TEMP "TortoiseGit_Install_$(Get-Date -Format 'yyyyMMddHHmmss').log"
        Write-InstallLog "Installation log will be saved to: $logFile" -Level Info
        
        # Use /qn for completely silent install with logging
        $arguments = @("/qn", "/norestart", "/l*v", $logFile)
        $result = Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments -UseMsiExec
        
        # If installation failed with VC++ error, try to repair VC++ Redistributable
        if (-not $result) {
            Write-InstallLog "TortoiseGit installation failed. This may be due to VC++ Redistributable issues." -Level Warning
            Write-InstallLog "Try repairing VC++ Redistributable manually: VC_redist.x64.exe /repair" -Level Info
        }
        
        return $result
    }
    else {
        $arguments = @("/VERYSILENT", "/NORESTART")
        return Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
    }
}

function Install-Python {
    <#
    .SYNOPSIS
        Install Python to C:\Python\PythonXXX
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing Python..." -Level Info
    
    # Check if already installed
    $wasAlreadyInstalled = $false
    try {
        $pythonVersion = & python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InstallLog "Python is already installed: $pythonVersion" -Level Success
            $wasAlreadyInstalled = $true
        }
    }
    catch {
        # Python not found, proceed with installation
    }
    
    if (-not $wasAlreadyInstalled) {
        if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
            Write-InstallLog "Python installer not found" -Level Error
            Write-InstallLog "Download from: https://www.python.org/downloads/" -Level Info
            return $false
        }
        
        # Extract Python version from installer filename (e.g., python-3.14.2-amd64.exe -> 314)
        $installerName = Split-Path -Leaf $InstallerPath
        if ($installerName -match 'python-(\d+)\.(\d+)\.(\d+)') {
            $majorVersion = $matches[1]
            $minorVersion = $matches[2]
            $pythonVersionShort = "$majorVersion$minorVersion"
            $installDir = "C:\Python\Python$pythonVersionShort"
            Write-InstallLog "Python will be installed to: $installDir" -Level Info
        }
        else {
            # Fallback if version can't be parsed
            $installDir = "C:\Python\Python3"
            Write-InstallLog "Python will be installed to: $installDir (default)" -Level Warning
        }
        
        $arguments = @(
            "/quiet",
            "InstallAllUsers=1",
            "PrependPath=1",                    # Add Python to PATH
            "Include_test=0",                   # Skip test suite
            "Include_pip=1",                    # Include pip
            "Include_launcher=1",               # Include py launcher
            "AssociateFiles=1",                 # Associate .py files
            "CompileAll=1",                     # Precompile standard library
            "SimpleInstall=0",                  # Full installation
            "TargetDir=$installDir"             # Custom install directory
        )
        
        # Note: Python 3.6+ installer automatically handles long path support on Windows 10+
        # The system must have long path support enabled in Windows settings
        Write-InstallLog "Installing with PATH enabled and full features..." -Level Info
        
        $result = Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
        
        if (-not $result) {
            return $false
        }
        
        # Refresh PATH to include newly installed Python
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-InstallLog "Waiting for Python installation to complete..." -Level Info
        Start-Sleep -Seconds 3
    }
    
    # Run setup_env.py after Python installation
    Invoke-PythonSetupScript
    
    return $true
}

function Invoke-PythonSetupScript {
    <#
    .SYNOPSIS
        Run setup_env.py to configure Python environment and install packages
    #>
    Write-InstallLog "Running Python environment setup script..." -Level Info
    
    # Determine script directory
    $scriptDir = if ($PSScriptRoot) {
        $PSScriptRoot
    }
    elseif ($MyInvocation.MyCommand.Path) {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    else {
        Get-Location
    }
    
    $setupScriptPath = Join-Path $scriptDir "setup_env.py"
    
    if (-not (Test-Path $setupScriptPath)) {
        Write-InstallLog "setup_env.py not found at: $setupScriptPath" -Level Warning
        Write-InstallLog "Skipping Python environment setup" -Level Warning
        return $false
    }
    
    # Find Python executable
    $pythonExe = $null
    $pythonPaths = @(
        "C:\Python\Python314\python.exe",
        "C:\Python\Python313\python.exe",
        "C:\Python\Python312\python.exe",
        "${env:ProgramFiles}\Python\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
    )
    
    # Try to find python in common locations
    foreach ($path in $pythonPaths) {
        if (Test-Path $path) {
            $pythonExe = $path
            break
        }
    }
    
    # Try to find python from PATH
    if (-not $pythonExe) {
        try {
            $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
            if ($pythonCmd) {
                $pythonExe = $pythonCmd.Source
            }
        }
        catch {
            Write-InstallLog "Python executable not found" -Level Warning
            return $false
        }
    }
    
    if (-not $pythonExe) {
        Write-InstallLog "Python executable not found" -Level Warning
        Write-InstallLog "Please run setup_env.py manually after restarting your terminal" -Level Info
        return $false
    }
    
    Write-InstallLog "Found Python at: $pythonExe" -Level Success
    Write-InstallLog "Launching setup_env.py for environment configuration..." -Level Info
    
    try {
        # Run setup_env.py interactively
        & $pythonExe $setupScriptPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-InstallLog "Python environment setup completed successfully" -Level Success
            return $true
        }
        else {
            Write-InstallLog "Python environment setup exited with code: $LASTEXITCODE" -Level Warning
            return $false
        }
    }
    catch {
        Write-InstallLog "Error running setup_env.py: $_" -Level Error
        return $false
    }
}

function Install-MobaXterm {
    <#
    .SYNOPSIS
        Install MobaXterm (optional)
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing MobaXterm (optional)..." -Level Info
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "MobaXterm installer not found, skipping (optional)" -Level Info
        return $true
    }
    
    # Check if it's a ZIP file - extract it first
    if ($InstallerPath -match '\.(zip|7z)$') {
        Write-InstallLog "MobaXterm ZIP archive detected, extracting..." -Level Info
        
        try {
            # Create temp extraction directory
            $extractPath = Join-Path $env:TEMP "MobaXterm_Extract_$(Get-Date -Format 'yyyyMMddHHmmss')"
            New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
            
            # Extract ZIP file
            Expand-Archive -Path $InstallerPath -DestinationPath $extractPath -Force
            Write-InstallLog "Extracted to: $extractPath" -Level Success
            
            # Find MSI or EXE installer inside
            $msiInstaller = Get-ChildItem -Path $extractPath -Filter "*.msi" -Recurse | Select-Object -First 1
            $exeInstaller = Get-ChildItem -Path $extractPath -Filter "*.exe" -Recurse | Select-Object -First 1
            
            if ($msiInstaller) {
                Write-InstallLog "Found MSI installer: $($msiInstaller.Name)" -Level Success
                $arguments = @("/quiet", "/norestart")
                $result = Invoke-InstallerSilent -InstallerPath $msiInstaller.FullName -Arguments $arguments -UseMsiExec
                
                # Cleanup temp directory
                try { Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue } catch { }
                return $result
            }
            elseif ($exeInstaller) {
                # Check if it's a portable executable
                if ($exeInstaller.Name -match 'Portable') {
                    Write-InstallLog "Found portable MobaXterm: $($exeInstaller.Name)" -Level Success
                    Write-InstallLog "Portable version - no installation needed" -Level Info
                    Write-InstallLog "Run manually from: $($exeInstaller.FullName)" -Level Info
                    return $true
                }
                else {
                    Write-InstallLog "Found EXE installer: $($exeInstaller.Name)" -Level Success
                    $arguments = @("/VERYSILENT", "/NORESTART")
                    $result = Invoke-InstallerSilent -InstallerPath $exeInstaller.FullName -Arguments $arguments
                    
                    # Cleanup temp directory
                    try { Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue } catch { }
                    return $result
                }
            }
            else {
                Write-InstallLog "No installer found inside ZIP archive" -Level Warning
                Write-InstallLog "Archive may contain portable version only" -Level Info
                # Keep extracted files for manual use
                Write-InstallLog "Files extracted to: $extractPath" -Level Info
                return $true
            }
        }
        catch {
            Write-InstallLog "Failed to extract ZIP: $_" -Level Error
            return $false
        }
    }
    # Check if it's MSI installer
    elseif ($InstallerPath -match '\.msi$') {
        $arguments = @("/quiet", "/norestart")
        return Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments -UseMsiExec
    }
    # Check if it's executable
    elseif ($InstallerPath -match '\.exe$') {
        # Some versions might be portable executables
        if ($InstallerPath -match 'Portable') {
            Write-InstallLog "MobaXterm portable executable detected" -Level Info
            Write-InstallLog "No installation needed: $InstallerPath" -Level Info
            return $true
        }
        else {
            $arguments = @("/VERYSILENT", "/NORESTART")
            return Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
        }
    }
    else {
        Write-InstallLog "Unknown MobaXterm installer format" -Level Warning
        return $true
    }
}

function Install-Everything {
    <#
    .SYNOPSIS
        Install Everything - Fast file search utility
    #>
    param([string]$InstallerPath)
    
    Write-InstallLog "Installing Everything..." -Level Info
    
    # Check if already installed
    $checkPaths = @(
        "${env:ProgramFiles}\Everything\Everything.exe",
        "${env:ProgramFiles(x86)}\Everything\Everything.exe"
    )
    
    if (Test-SoftwareInstalled -SoftwareName "Everything" -CheckPaths $checkPaths) {
        return $true
    }
    
    if (-not $InstallerPath -or -not (Test-Path $InstallerPath)) {
        Write-InstallLog "Everything installer not found" -Level Error
        Write-InstallLog "Download from: https://www.voidtools.com/downloads/" -Level Info
        return $false
    }
    
    # Everything installer uses /S for silent installation (NSIS installer)
    $arguments = @(
        "/S"  # Silent install
    )
    
    return Invoke-InstallerSilent -InstallerPath $InstallerPath -Arguments $arguments
}

#endregion

#region Main Installation Process

function Start-SoftwareInstallation {
    <#
    .SYNOPSIS
        Main installation orchestration function
    #>
    param([hashtable]$InstallerConfig)
    
    Write-InstallLog "=" * 70 -Level Info
    Write-InstallLog "Starting Automated Software Installation" -Level Info
    Write-InstallLog "=" * 70 -Level Info
    
    # Check admin privileges
    if (-not (Test-Administrator)) {
        Write-InstallLog "WARNING: Not running as administrator" -Level Warning
        Write-InstallLog "Some installations may fail without admin privileges" -Level Warning
        
        $response = Read-Host "Continue anyway? (y/n)"
        if ($response -ne 'y') {
            Write-InstallLog "Installation cancelled by user" -Level Warning
            return
        }
    }
    
    # Step 1: Install VC Redistributable if needed (for TortoiseGit)
    if ($InstallerConfig.ContainsKey('vcredist')) {
        if (-not (Test-VCRedist)) {
            Install-VCRedist -InstallerPath $InstallerConfig['vcredist']
        }
    }
    
    # Step 2: Install VSCode (first priority)
    if ($InstallerConfig.ContainsKey('vscode')) {
        Install-VSCode -InstallerPath $InstallerConfig['vscode']
    }
    
    # Step 3: Install Git (with VSCode as editor)
    if ($InstallerConfig.ContainsKey('git')) {
        Install-Git -InstallerPath $InstallerConfig['git'] -SetVSCodeAsEditor
    }
    
    # Step 4: Install TortoiseGit
    if ($InstallerConfig.ContainsKey('tortoisegit')) {
        Install-TortoiseGit -InstallerPath $InstallerConfig['tortoisegit']
    }
    
    # Step 5: Install Python
    if ($InstallerConfig.ContainsKey('python')) {
        Install-Python -InstallerPath $InstallerConfig['python']
    }
    
    # Step 6: Install Everything (fast file search)
    if ($InstallerConfig.ContainsKey('everything')) {
        Install-Everything -InstallerPath $InstallerConfig['everything']
    }
    
    # Step 7: Install MobaXterm (optional)
    if ($InstallerConfig.ContainsKey('mobaxterm')) {
        Install-MobaXterm -InstallerPath $InstallerConfig['mobaxterm']
    }
    
    Write-InstallLog "=" * 70 -Level Info
    Write-InstallLog "Installation Process Completed" -Level Success
    Write-InstallLog "=" * 70 -Level Info
}

#endregion

#region Main Script Entry Point

function Main {
    Write-Host "`n" -NoNewline
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "  Automated Software Installation Script" -ForegroundColor Cyan
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "`n"
    
    # Get script directory - handle different execution methods
    if ($PSScriptRoot) {
        $scriptDir = $PSScriptRoot
    }
    elseif ($MyInvocation.MyCommand.Path) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    else {
        $scriptDir = Get-Location
    }
    
    Write-Host "Script directory: $scriptDir`n" -ForegroundColor Gray
    $installerConfig = @{}
    
    Write-Host "Please provide paths to installer files." -ForegroundColor Yellow
    Write-Host "Press Enter to auto-detect, type 'skip' to skip, or provide full path.`n" -ForegroundColor Yellow
    
    # VC Redistributable
    $vcredistPath = Read-Host "VC_redist.x64.exe path (Enter/skip/path)"
    if ($vcredistPath -eq 'skip' -or $vcredistPath -eq 's') {
        Write-Host "Skipped: VC_redist" -ForegroundColor Yellow
    }
    elseif ($vcredistPath -and (Test-Path $vcredistPath)) {
        $installerConfig['vcredist'] = $vcredistPath
    }
    elseif (-not $vcredistPath -and (Test-Path "$scriptDir\VC_redist.x64.exe")) {
        Write-Host "Found: $scriptDir\VC_redist.x64.exe" -ForegroundColor Green
        $confirm = Read-Host "Install VC_redist? (y/n)"
        if ($confirm -eq 'y') {
            $installerConfig['vcredist'] = "$scriptDir\VC_redist.x64.exe"
        }
    }
    
    # VSCode
    $vscodePath = Read-Host "VSCode installer path (Enter/skip/path)"
    if ($vscodePath -eq 'skip' -or $vscodePath -eq 's') {
        Write-Host "Skipped: VSCode" -ForegroundColor Yellow
    }
    elseif ($vscodePath -and (Test-Path $vscodePath)) {
        $installerConfig['vscode'] = $vscodePath
    }
    elseif (-not $vscodePath) {
        # Try to find VSCode installer with wildcard matching
        $vscodeInstaller = Get-ChildItem -Path $scriptDir -Filter "VSCodeUserSetup-x64*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($vscodeInstaller) {
            Write-Host "Found: $($vscodeInstaller.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install VSCode? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['vscode'] = $vscodeInstaller.FullName
            }
        }
    }
    
    # Git
    $gitPath = Read-Host "Git installer path (Enter/skip/path)"
    if ($gitPath -eq 'skip' -or $gitPath -eq 's') {
        Write-Host "Skipped: Git" -ForegroundColor Yellow
    }
    elseif ($gitPath -and (Test-Path $gitPath)) {
        $installerConfig['git'] = $gitPath
    }
    elseif (-not $gitPath) {
        # Try to find Git installer with wildcard matching
        $gitInstaller = Get-ChildItem -Path $scriptDir -Filter "Git-*-64*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($gitInstaller) {
            Write-Host "Found: $($gitInstaller.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install Git? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['git'] = $gitInstaller.FullName
            }
        }
    }
    
    # TortoiseGit
    $tortoisegitPath = Read-Host "TortoiseGit installer path (Enter/skip/path)"
    if ($tortoisegitPath -eq 'skip' -or $tortoisegitPath -eq 's') {
        Write-Host "Skipped: TortoiseGit" -ForegroundColor Yellow
    }
    elseif ($tortoisegitPath -and (Test-Path $tortoisegitPath)) {
        $installerConfig['tortoisegit'] = $tortoisegitPath
    }
    elseif (-not $tortoisegitPath) {
        # Try to find TortoiseGit installer with wildcard matching
        $tortoiseInstaller = Get-ChildItem -Path $scriptDir -Filter "TortoiseGit-*-64*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($tortoiseInstaller) {
            Write-Host "Found: $($tortoiseInstaller.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install TortoiseGit? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['tortoisegit'] = $tortoiseInstaller.FullName
            }
        }
    }
    
    # Python
    $pythonPath = Read-Host "Python installer path (Enter/skip/path)"
    if ($pythonPath -eq 'skip' -or $pythonPath -eq 's') {
        Write-Host "Skipped: Python" -ForegroundColor Yellow
    }
    elseif ($pythonPath -and (Test-Path $pythonPath)) {
        $installerConfig['python'] = $pythonPath
    }
    elseif (-not $pythonPath) {
        # Try to find any Python installer in the directory
        $pythonInstaller = Get-ChildItem -Path $scriptDir -Filter "python*amd64.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pythonInstaller) {
            Write-Host "Found: $($pythonInstaller.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install Python? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['python'] = $pythonInstaller.FullName
            }
        }
    }
    
    # Everything
    $everythingPath = Read-Host "Everything installer path (Enter/skip/path)"
    if ($everythingPath -eq 'skip' -or $everythingPath -eq 's') {
        Write-Host "Skipped: Everything" -ForegroundColor Yellow
    }
    elseif ($everythingPath -and (Test-Path $everythingPath)) {
        $installerConfig['everything'] = $everythingPath
    }
    elseif (-not $everythingPath) {
        # Try to find Everything installer in the directory
        $everythingInstaller = Get-ChildItem -Path $scriptDir -Filter "Everything*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($everythingInstaller) {
            Write-Host "Found: $($everythingInstaller.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install Everything? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['everything'] = $everythingInstaller.FullName
            }
        }
    }
    
    # MobaXterm (optional)
    $mobaxterm = Read-Host "MobaXterm installer path (Enter/skip/path)"
    if ($mobaxterm -eq 'skip' -or $mobaxterm -eq 's') {
        Write-Host "Skipped: MobaXterm" -ForegroundColor Yellow
    }
    elseif ($mobaxterm -and (Test-Path $mobaxterm)) {
        $installerConfig['mobaxterm'] = $mobaxterm
    }
    elseif (-not $mobaxterm) {
        # Try to find MobaXterm ZIP or installer in the directory
        $mobaZip = Get-ChildItem -Path $scriptDir -Filter "MobaXterm*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
        $mobaMsi = Get-ChildItem -Path $scriptDir -Filter "MobaXterm*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
        $mobaExe = Get-ChildItem -Path $scriptDir -Filter "MobaXterm*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        
        if ($mobaZip -or $mobaMsi -or $mobaExe) {
            $foundFile = if ($mobaZip) { $mobaZip } elseif ($mobaMsi) { $mobaMsi } else { $mobaExe }
            Write-Host "Found: $($foundFile.FullName)" -ForegroundColor Green
            $confirm = Read-Host "Install MobaXterm? (y/n)"
            if ($confirm -eq 'y') {
                $installerConfig['mobaxterm'] = $foundFile.FullName
            }
        }
    }
    
    if ($installerConfig.Count -eq 0) {
        Write-Host "`nNo installers found. Please provide at least one installer path." -ForegroundColor Red
        return
    }
    
    Write-Host "`n" -NoNewline
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "The following software will be installed:" -ForegroundColor Cyan
    foreach ($key in $installerConfig.Keys) {
        Write-Host "  - $($key.ToUpper())" -ForegroundColor Green
    }
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "`n"
    
    $response = Read-Host "Proceed with installation? (y/n)"
    if ($response -ne 'y') {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        return
    }
    
    # Start installation
    Start-SoftwareInstallation -InstallerConfig $installerConfig
    
    Write-Host "`nInstallation process finished." -ForegroundColor Green
    Write-Host "Please restart your computer if prompted." -ForegroundColor Yellow
    Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
    Read-Host
}

# Run the main function
Main

#endregion
