# ============================================================================
# OpenCode Now - Windows PowerShell Launcher
# ============================================================================
# Quick launcher for OpenCode CLI on Windows.
# Automatically detects OpenCode installation and launches with permission skip.
# ============================================================================

param(
    [string]$TargetDir = ""
)

# Configuration
$LastDirFile = "$env:USERPROFILE\.opencode-now-last-dir"

# ============================================================================
# Determine Target Directory
# ============================================================================

function Get-TargetDirectory {
    param([string]$InputDir)
    
    # Priority 1: Command line argument
    if ($InputDir -and (Test-Path $InputDir -PathType Container)) {
        return $InputDir
    }
    
    # Priority 2: Last used directory
    if (Test-Path $LastDirFile) {
        $LastDir = Get-Content $LastDirFile -ErrorAction SilentlyContinue
        if ($LastDir -and (Test-Path $LastDir -PathType Container)) {
            return $LastDir
        }
    }
    
    # Priority 3: User home directory
    return $env:USERPROFILE
}

# ============================================================================
# Find OpenCode CLI
# ============================================================================

function Find-OpenCode {
    # Priority 1: Check if opencode is in PATH
    $OpenCodeCmd = Get-Command opencode -ErrorAction SilentlyContinue
    if ($OpenCodeCmd) {
        return $OpenCodeCmd.Source
    }
    
    # Priority 2: Check common installation paths
    $PossiblePaths = @(
        "$env:APPDATA\npm\opencode.cmd",
        "$env:LOCALAPPDATA\npm\opencode.cmd",
        "$env:ProgramFiles\nodejs\opencode.cmd",
        "$env:USERPROFILE\go\bin\opencode.exe",
        "$env:GOPATH\bin\opencode.exe",
        "C:\Go\bin\opencode.exe"
    )
    
    foreach ($path in $PossiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    return $null
}

# ============================================================================
# Main Execution
# ============================================================================

$TargetDirectory = Get-TargetDirectory -InputDir $TargetDir

if (-not (Test-Path $TargetDirectory -PathType Container)) {
    Write-Host "❌ Error: Directory '$TargetDirectory' does not exist" -ForegroundColor Red
    exit 1
}

Set-Location $TargetDirectory
Write-Host "🚀 Launching OpenCode in '$TargetDirectory'..." -ForegroundColor Green

$OpenCodePath = Find-OpenCode

if (-not $OpenCodePath) {
    Write-Host "❌ Error: OpenCode CLI not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 To install OpenCode CLI:" -ForegroundColor Yellow
    Write-Host "   go install github.com/opencode-ai/opencode@latest" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Searched locations:" -ForegroundColor Cyan
    Write-Host "   - Current PATH"
    Write-Host "   - $env:APPDATA\npm\opencode.cmd"
    Write-Host "   - $env:LOCALAPPDATA\npm\opencode.cmd"
    Write-Host "   - $env:USERPROFILE\go\bin\opencode.exe"
    exit 1
}

Write-Host "✅ Found OpenCode: $OpenCodePath" -ForegroundColor Green

# Save current directory for next launch
$TargetDirectory | Out-File -FilePath $LastDirFile -Encoding utf8

# Security validation
if ($OpenCodePath -match "opencode(\.exe|\.cmd)?$") {
    Write-Host "🔒 Security validation passed, launching OpenCode..." -ForegroundColor Green
    & $OpenCodePath --dangerously-skip-permissions
} else {
    Write-Host "❌ Security validation failed: Invalid OpenCode path detected" -ForegroundColor Red
    Write-Host "🔍 Current path: $OpenCodePath" -ForegroundColor Yellow
    Write-Host "⚠️  Refusing to execute for security reasons" -ForegroundColor Yellow
    exit 1
}
