@echo off
REM Automated Software Installation Launcher
REM This batch file launches the PowerShell installation script

echo ========================================
echo   Automated Software Installation
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running as Administrator
) else (
    echo [WARNING] Not running as Administrator
    echo Some installations may require administrator privileges.
    echo.
    echo To run as admin: Right-click this file and select "Run as administrator"
    echo.
    pause
)

echo.
echo Starting installation script...
echo.

REM Run the PowerShell script
PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0Install-Software.ps1"

echo.
echo ========================================
echo   Script execution completed
echo ========================================
echo.
pause
