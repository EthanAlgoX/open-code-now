@echo off
chcp 65001 >nul
REM ============================================================================
REM OpenCode Now - Windows Diagnostic Tool
REM ============================================================================
REM Checks the environment and provides troubleshooting information.
REM ============================================================================

echo.
echo ========================================
echo   OpenCode Now - Diagnostic Tool
echo ========================================
echo.

echo [System Information]
echo   OS: %OS%
echo   User: %USERNAME%
echo   Home: %USERPROFILE%
echo   Current Dir: %CD%
echo.

echo [Installation Check]

REM Check bin directory
echo   Bin Directory: %USERPROFILE%\bin
if exist "%USERPROFILE%\bin" (
    echo   Status: EXISTS
    if exist "%USERPROFILE%\bin\opencode-now.ps1" (
        echo   opencode-now.ps1: FOUND
    ) else (
        echo   opencode-now.ps1: NOT FOUND
    )
) else (
    echo   Status: NOT FOUND
)
echo.

echo [PATH Check]
echo %PATH% | findstr /C:"%USERPROFILE%\bin" >nul
if %errorLevel% equ 0 (
    echo   User bin in PATH: YES
) else (
    echo   User bin in PATH: NO
)
echo.

echo [Development Environment]

REM Check Go
where go >nul 2>&1
if %errorLevel% equ 0 (
    echo   Go: INSTALLED
    go version
) else (
    echo   Go: NOT FOUND
)

REM Check Node.js
where node >nul 2>&1
if %errorLevel% equ 0 (
    echo   Node.js: INSTALLED
    node --version
) else (
    echo   Node.js: NOT FOUND
)

REM Check npm
where npm >nul 2>&1
if %errorLevel% equ 0 (
    echo   npm: INSTALLED
    npm --version
) else (
    echo   npm: NOT FOUND
)
echo.

echo [OpenCode CLI]
where opencode >nul 2>&1
if %errorLevel% equ 0 (
    echo   Status: INSTALLED
    opencode --version 2>nul || echo   (version check failed)
) else (
    echo   Status: NOT FOUND
    echo.
    echo   To install OpenCode CLI:
    echo     go install github.com/opencode-ai/opencode@latest
)
echo.

echo [Troubleshooting Tips]
echo   1. Make sure OpenCode CLI is installed
echo   2. Run install.bat to set up the launcher
echo   3. Restart your terminal after PATH changes
echo   4. Run install-context-menu.bat as Administrator for right-click menu
echo.

pause
