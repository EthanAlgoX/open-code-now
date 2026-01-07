#!/bin/bash

# ============================================================================
# OpenCode Now - Quick Launcher for OpenCode CLI
# https://github.com/opencode/opencode-now
# ============================================================================
# Instantly launches OpenCode in the current or specified directory.
# Automatically detects OpenCode installation across multiple package managers.
# ============================================================================

# Note: We intentionally do NOT use 'set -e' here because function return values
# are used for control flow and set -e would cause premature script exits.

# Configuration
LAST_DIR_FILE="$HOME/.opencode-now-last-dir"
TERMINAL_CONFIG_FILE="$HOME/.opencode-now-terminal"

# ============================================================================
# PATH Setup - Detect and configure Node.js/package manager paths
# ============================================================================

setup_path() {
    local NVM_NODE_PATH=""
    
    # Detect nvm installation
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 2>/dev/null || true
        
        # Try to get current/default Node.js version
        if command -v nvm >/dev/null 2>&1; then
            local CURRENT_NODE_VERSION
            CURRENT_NODE_VERSION=$(nvm current 2>/dev/null | grep -v 'none' | head -1 || echo "")
            
            if [ -n "$CURRENT_NODE_VERSION" ] && [ "$CURRENT_NODE_VERSION" != "none" ] && [ "$CURRENT_NODE_VERSION" != "system" ]; then
                NVM_NODE_PATH="$HOME/.nvm/versions/node/$CURRENT_NODE_VERSION/bin"
            else
                # Fallback: find the latest installed version
                local LATEST_NODE_VERSION
                LATEST_NODE_VERSION=$(ls "$HOME/.nvm/versions/node/" 2>/dev/null | sort -V | tail -1 || echo "")
                if [ -n "$LATEST_NODE_VERSION" ]; then
                    NVM_NODE_PATH="$HOME/.nvm/versions/node/$LATEST_NODE_VERSION/bin"
                fi
            fi
        else
            # Fallback without nvm command
            local LATEST_NODE_VERSION
            LATEST_NODE_VERSION=$(ls "$HOME/.nvm/versions/node/" 2>/dev/null | sort -V | tail -1 || echo "")
            if [ -n "$LATEST_NODE_VERSION" ]; then
                NVM_NODE_PATH="$HOME/.nvm/versions/node/$LATEST_NODE_VERSION/bin"
            fi
        fi
    fi
    
    # Build comprehensive PATH
    local ADDITIONAL_PATHS="$HOME/.npm-global/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:/usr/local/share/npm/bin"
    
    if [ -n "$NVM_NODE_PATH" ]; then
        export PATH="$NVM_NODE_PATH:$ADDITIONAL_PATHS:$PATH"
    else
        export PATH="$ADDITIONAL_PATHS:$PATH"
    fi
}

# ============================================================================
# OpenCode Detection - Find the opencode binary
# ============================================================================

OPENCODE_PATH=""

check_opencode_path() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        OPENCODE_PATH="$1"
        return 0
    fi
    return 1
}

find_nvm_opencode() {
    if [ -d "$HOME/.nvm/versions/node" ]; then
        # Check latest node version first
        local LATEST_NODE
        LATEST_NODE=$(ls -t "$HOME/.nvm/versions/node/" 2>/dev/null | head -1)
        if [ -n "$LATEST_NODE" ]; then
            check_opencode_path "$HOME/.nvm/versions/node/$LATEST_NODE/bin/opencode" && return 0
        fi
        # Check all versions
        for node_version in "$HOME/.nvm/versions/node/"*; do
            if [ -d "$node_version" ]; then
                check_opencode_path "$node_version/bin/opencode" && return 0
            fi
        done
    fi
    return 1
}

detect_package_manager_bins() {
    # Try npm global prefix
    if command -v npm >/dev/null 2>&1; then
        local NPM_PREFIX
        NPM_PREFIX=$(npm config get prefix 2>/dev/null)
        if [ -n "$NPM_PREFIX" ] && [ -d "$NPM_PREFIX/bin" ]; then
            check_opencode_path "$NPM_PREFIX/bin/opencode" && return 0
        fi
    fi
    
    # Try yarn global bin
    if command -v yarn >/dev/null 2>&1; then
        local YARN_BIN
        YARN_BIN=$(yarn global bin 2>/dev/null)
        if [ -n "$YARN_BIN" ] && [ -d "$YARN_BIN" ]; then
            check_opencode_path "$YARN_BIN/opencode" && return 0
        fi
    fi
    
    # Try pnpm bin
    if command -v pnpm >/dev/null 2>&1; then
        local PNPM_BIN
        PNPM_BIN=$(pnpm bin -g 2>/dev/null)
        if [ -n "$PNPM_BIN" ] && [ -d "$PNPM_BIN" ]; then
            check_opencode_path "$PNPM_BIN/opencode" && return 0
        fi
    fi
    
    return 1
}

find_opencode() {
    # Priority 1: Check if opencode is already in PATH
    if command -v opencode >/dev/null 2>&1; then
        OPENCODE_PATH=$(command -v opencode)
        return 0
    fi
    
    # Priority 2: Dynamic package manager detection
    detect_package_manager_bins && return 0
    
    # Priority 3: Check nvm installations
    find_nvm_opencode && return 0
    
    # Priority 4: Check common static paths
    local COMMON_PATHS=(
        "$HOME/.local/bin/opencode"
        "$HOME/.npm-global/bin/opencode"
        "$HOME/.npm/bin/opencode"
        "$HOME/Library/pnpm/opencode"
        "$HOME/.yarn/bin/opencode"
        "/usr/local/bin/opencode"
        "/opt/homebrew/bin/opencode"
        "/usr/bin/opencode"
        "$HOME/.cargo/bin/opencode"
        "$HOME/go/bin/opencode"
        "$GOPATH/bin/opencode"
    )
    
    for path in "${COMMON_PATHS[@]}"; do
        check_opencode_path "$path" && return 0
    done
    
    return 1
}

show_not_found_error() {
    echo "❌ Error: OpenCode CLI not found"
    echo ""
    echo "🔍 Searched locations:"
    echo "   • Current PATH"
    echo "   • npm global installation"
    echo "   • yarn global installation"
    echo "   • pnpm global installation"
    echo "   • nvm Node.js versions"
    echo "   • ~/.local/bin"
    echo "   • ~/.npm-global/bin"
    echo "   • /usr/local/bin"
    echo "   • /opt/homebrew/bin"
    echo ""
    echo "💡 To install OpenCode CLI:"
    echo "   go install github.com/opencode-ai/opencode@latest"
    echo ""
    echo "   Or check if already installed:"
    echo "   which opencode"
    exit 1
}

# ============================================================================
# Directory Handling
# ============================================================================

get_target_directory() {
    local TARGET_DIR=""
    
    # Priority 1: Command line argument
    if [ -n "$1" ]; then
        TARGET_DIR="$1"
    # Priority 2: Last used directory
    elif [ -f "$LAST_DIR_FILE" ]; then
        TARGET_DIR=$(cat "$LAST_DIR_FILE")
    # Priority 3: Home directory
    else
        TARGET_DIR="$HOME"
    fi
    
    # Validate directory exists
    if [ ! -d "$TARGET_DIR" ]; then
        echo "❌ Error: Directory '$TARGET_DIR' does not exist" >&2
        exit 1
    fi
    
    echo "$TARGET_DIR"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Setup PATH
    setup_path
    
    # Get target directory (will exit if invalid)
    local TARGET_DIR
    TARGET_DIR=$(get_target_directory "$1")
    
    # Change to target directory
    cd "$TARGET_DIR" || exit 1
    
    echo "🚀 Launching OpenCode in '$TARGET_DIR'..."
    
    # Find OpenCode
    if ! find_opencode; then
        show_not_found_error
    fi
    
    echo "✅ Found OpenCode: $OPENCODE_PATH"
    
    # Save current directory for next launch
    echo "$TARGET_DIR" > "$LAST_DIR_FILE"
    
    # Launch OpenCode with permission bypass
    exec "$OPENCODE_PATH" --dangerously-skip-permissions
}

main "$@"
