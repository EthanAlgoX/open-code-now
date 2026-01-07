@echo off
chcp 65001 >nul
REM ============================================================================
REM OpenCode Now - Windows Context Menu Installation
REM ============================================================================
REM Adds "OpenCode Now" option to right-click context menu in Explorer.
REM Requires Administrator privileges.
REM ============================================================================

echo.
echo ========================================
echo   OpenCode Now - Context Menu Setup
echo ========================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Administrator privileges required
    echo.
    echo Please right-click this file and select "Run as administrator"
    pause
    exit /b 1
)

REM Check if PowerShell script exists
echo Checking for PowerShell script...
if not exist "%USERPROFILE%\bin\opencode-now.ps1" (
    echo Error: opencode-now.ps1 not found
    echo.
    echo Please run install.bat first to install the launcher script
    pause
    exit /b 1
)

echo PowerShell script found

echo Adding context menu entries...
echo.

REM Add folder context menu (right-click on folder)
reg add "HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow" /ve /d "OpenCode Now" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow" /v "Icon" /d "%%SystemRoot%%\System32\SHELL32.dll,43" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow\command" /ve /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%USERPROFILE%\bin\opencode-now.ps1\" \"%%V\"" /f >nul

echo Added: Folder right-click menu

REM Add folder background context menu (right-click in empty space)
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow" /ve /d "OpenCode Now" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow" /v "Icon" /d "%%SystemRoot%%\System32\SHELL32.dll,43" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow\command" /ve /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%USERPROFILE%\bin\opencode-now.ps1\" \"%%V\"" /f >nul

echo Added: Folder background right-click menu

REM Add drive context menu
reg add "HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow" /ve /d "OpenCode Now" /f >nul
reg add "HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow" /v "Icon" /d "%%SystemRoot%%\System32\SHELL32.dll,43" /f >nul
reg add "HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow\command" /ve /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%USERPROFILE%\bin\opencode-now.ps1\" \"%%V\"" /f >nul

echo Added: Drive right-click menu

echo.
echo ========================================
echo   Context Menu Installation Complete!
echo ========================================
echo.
echo You can now right-click on any folder and select "OpenCode Now"
echo.
pause
