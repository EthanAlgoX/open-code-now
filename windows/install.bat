@echo off
chcp 65001 >nul
REM ============================================================================
REM OpenCode Now - Windows Installation Script
REM ============================================================================
REM Copies launcher scripts to user's bin directory and adds to PATH.
REM ============================================================================

echo.
echo ========================================
echo   OpenCode Now - Installation
echo ========================================
echo.

REM Create user bin directory if it doesn't exist
if not exist "%USERPROFILE%\bin" (
    echo Creating bin directory...
    mkdir "%USERPROFILE%\bin"
)

REM Check if PowerShell script exists in current directory
if not exist "opencode-now.ps1" (
    echo.
    echo Error: opencode-now.ps1 not found in current directory
    echo Please run this script from the opencode-now\windows directory
    pause
    exit /b 1
)

REM Copy PowerShell script
echo Copying opencode-now.ps1...
copy /Y "opencode-now.ps1" "%USERPROFILE%\bin\" >nul
if %errorLevel% neq 0 (
    echo Failed to copy PowerShell script
    pause
    exit /b 1
)

echo Installed: %USERPROFILE%\bin\opencode-now.ps1

REM Check if bin is in PATH
echo %PATH% | findstr /C:"%USERPROFILE%\bin" >nul
if %errorLevel% neq 0 (
    echo.
    echo Adding %USERPROFILE%\bin to user PATH...
    REM Use PowerShell to safely update user PATH without truncation
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';%USERPROFILE%\bin', 'User')"
    if %errorLevel% equ 0 (
        echo PATH updated successfully.
    ) else (
        echo Warning: Could not update PATH automatically.
        echo Please manually add %USERPROFILE%\bin to your PATH.
    )
    echo Please restart your terminal for changes to take effect.
)

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Usage:
echo   1. Open PowerShell in any directory
echo   2. Run: opencode-now
echo.
echo Optional: Run install-context-menu.bat to add right-click menu integration
echo.
pause
