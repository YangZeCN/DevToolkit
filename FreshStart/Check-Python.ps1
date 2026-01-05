<#
.SYNOPSIS
    Python Installation Verification Script
    
.DESCRIPTION
    Checks Python installation, PATH configuration, and long path support
#>

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Python Installation Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Python Version
Write-Host "1. Python Version:" -ForegroundColor Yellow
try {
    python --version
} catch {
    Write-Host "✗ Python not found" -ForegroundColor Red
}

# 2. Python Executable Path
Write-Host "`n2. Python Executable Path:" -ForegroundColor Yellow
try {
    python -c "import sys; print(sys.executable)"
} catch {
    Write-Host "✗ Cannot determine Python path" -ForegroundColor Red
}

# 3. Python Installation Directory
Write-Host "`n3. Python Installation Directory:" -ForegroundColor Yellow
try {
    python -c "import sys; import os; print(os.path.dirname(sys.executable))"
} catch {
    Write-Host "✗ Cannot determine installation directory" -ForegroundColor Red
}

# 4. Python in PATH (User)
Write-Host "`n4. Python in PATH (User):" -ForegroundColor Yellow
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -match "Python") {
    Write-Host "✓ Found in User PATH" -ForegroundColor Green
    $userPath.Split(';') | Where-Object { $_ -match "Python" } | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ Not found in User PATH" -ForegroundColor Red
}

# 5. Python in PATH (System)
Write-Host "`n5. Python in PATH (System):" -ForegroundColor Yellow
$systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($systemPath -match "Python") {
    Write-Host "✓ Found in System PATH" -ForegroundColor Green
    $systemPath.Split(';') | Where-Object { $_ -match "Python" } | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ Not found in System PATH" -ForegroundColor Red
}

# 6. Long Path Support
Write-Host "`n6. Windows Long Path Support:" -ForegroundColor Yellow
try {
    $longPathEnabled = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -ErrorAction SilentlyContinue
    if ($longPathEnabled.LongPathsEnabled -eq 1) {
        Write-Host "✓ Long paths ENABLED (supports paths > 260 chars)" -ForegroundColor Green
    } else {
        Write-Host "✗ Long paths DISABLED (260 char limit)" -ForegroundColor Red
        Write-Host "`n  To enable, run PowerShell as Administrator and execute:" -ForegroundColor Yellow
        Write-Host "  New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -PropertyType DWORD -Force" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠ Unable to check (may need admin privileges)" -ForegroundColor Yellow
}

# 7. Pip Available
Write-Host "`n7. Pip Package Manager:" -ForegroundColor Yellow
try {
    pip --version
} catch {
    Write-Host "✗ Pip not found" -ForegroundColor Red
}

# 8. Python Packages Count
Write-Host "`n8. Installed Packages:" -ForegroundColor Yellow
try {
    $packages = pip list 2>$null
    $packageCount = ($packages | Measure-Object -Line).Lines - 2
    Write-Host "✓ $packageCount packages installed" -ForegroundColor Green
} catch {
    Write-Host "⚠ Cannot list packages" -ForegroundColor Yellow
}

# 9. Python Site Packages
Write-Host "`n9. Site Packages Directory:" -ForegroundColor Yellow
try {
    python -c "import site; print(site.getsitepackages()[0])"
} catch {
    Write-Host "✗ Cannot determine site packages directory" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ Verification Complete" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Pause at the end
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
