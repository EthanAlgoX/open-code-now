@echo off
chcp 65001 >nul
REM ============================================================================
REM OpenCode Now - Remove Context Menu
REM ============================================================================
REM Removes "OpenCode Now" from Windows Explorer context menu.
REM Requires Administrator privileges.
REM ============================================================================

echo.
echo ========================================
echo   OpenCode Now - Remove Context Menu
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

echo Removing context menu entries...
echo.

REM Remove folder context menu
reg delete "HKEY_CLASSES_ROOT\Directory\shell\OpenCodeNow" /f >nul 2>&1
echo Removed: Folder right-click menu

REM Remove folder background context menu
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\OpenCodeNow" /f >nul 2>&1
echo Removed: Folder background right-click menu

REM Remove drive context menu
reg delete "HKEY_CLASSES_ROOT\Drive\shell\OpenCodeNow" /f >nul 2>&1
echo Removed: Drive right-click menu

echo.
echo ========================================
echo   Context Menu Removed Successfully!
echo ========================================
echo.
pause
