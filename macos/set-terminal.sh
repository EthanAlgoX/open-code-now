#!/bin/bash

# ============================================================================
# OpenCode Now - Terminal Configuration Tool
# ============================================================================
# Configure your preferred terminal application for OpenCode Now.
# Supports: iTerm2, Warp, Alacritty, and system Terminal.app
# ============================================================================

TERMINAL_CONFIG_FILE="$HOME/.opencode-now-terminal"

echo "🔧 OpenCode Now - Terminal Configuration"
echo "=========================================="
echo ""

# Detect installed terminal applications
echo "🔍 Detecting installed terminal applications..."
AVAILABLE_TERMINALS=()

if [ -d "/Applications/iTerm.app" ] || [ -d "/Applications/iTerm 2.app" ]; then
    AVAILABLE_TERMINALS+=("iTerm2")
    echo "✅ iTerm2 detected"
fi

if [ -d "/Applications/Warp.app" ]; then
    AVAILABLE_TERMINALS+=("Warp")
    echo "✅ Warp detected"
fi

if [ -d "/Applications/Alacritty.app" ]; then
    AVAILABLE_TERMINALS+=("Alacritty")
    echo "✅ Alacritty detected"
fi

if [ -d "/Applications/Kitty.app" ] || command -v kitty >/dev/null 2>&1; then
    AVAILABLE_TERMINALS+=("Kitty")
    echo "✅ Kitty detected"
fi

# Terminal.app is always available
AVAILABLE_TERMINALS+=("Terminal")
echo "✅ Terminal (system default)"

echo ""

# Show current configuration
if [ -f "$TERMINAL_CONFIG_FILE" ]; then
    CURRENT_TERMINAL=$(cat "$TERMINAL_CONFIG_FILE" 2>/dev/null | tr -d '\n\r')
    echo "📋 Current setting: $CURRENT_TERMINAL"
else
    echo "📋 Current setting: Auto-detect (iTerm2 > Warp > Kitty > Alacritty > Terminal)"
fi

echo ""
echo "🛠 Choose your preferred terminal:"
echo "0) Auto-detect (remove custom setting)"

for i in "${!AVAILABLE_TERMINALS[@]}"; do
    echo "$((i+1))) ${AVAILABLE_TERMINALS[$i]}"
done

echo ""
read -p "Enter your choice (0-$((${#AVAILABLE_TERMINALS[@]}))): " choice

case $choice in
    0)
        if [ -f "$TERMINAL_CONFIG_FILE" ]; then
            rm "$TERMINAL_CONFIG_FILE"
            echo "✅ Custom terminal setting removed. Will auto-detect best available terminal."
        else
            echo "ℹ️  Already using auto-detection."
        fi
        ;;
    [1-9]*)
        index=$((choice-1))
        if [ $index -ge 0 ] && [ $index -lt ${#AVAILABLE_TERMINALS[@]} ]; then
            selected_terminal="${AVAILABLE_TERMINALS[$index]}"
            echo "$selected_terminal" > "$TERMINAL_CONFIG_FILE"
            echo "✅ Terminal preference set to: $selected_terminal"
        else
            echo "❌ Invalid choice. Please run the script again."
            exit 1
        fi
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Configuration complete! OpenCode Now will use your preferred terminal."
echo ""
echo "💡 Tips:"
echo "  - Run this script anytime to change your preference"
echo "  - If preferred terminal is unavailable, auto-detection is used"
echo "  - Supported terminals: iTerm2, Warp, Kitty, Alacritty, Terminal"
