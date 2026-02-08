#!/bin/bash

# Vly Build Script - Fix FFmpegKit Framework Info.plist Issue
# This script fixes the FFmpeg framework bundle structure for macOS

set -e

# Default to Debug build output
BUILD_DIR="${1:-/Users/yanglin/.openclaw/workspace/Vly/build/Debug}"

echo "🔧 Fixing FFmpegKit framework structure..."
echo "   Build directory: $BUILD_DIR"

APP_PATH="$BUILD_DIR/Vly.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App bundle not found at $APP_PATH"
    echo "   Usage: fix-ffmpeg-frameworks.sh [build-directory]"
    exit 1
fi

FRAMEWORKS_PATH="$APP_PATH/Contents/Frameworks"

# List of frameworks that need fixing
FRAMES=(
    "Libavcodec"
    "Libavdevice"
    "Libavfilter"
    "Libavformat"
    "Libavutil"
    "Libswresample"
    "Libswscale"
    "gmp"
    "gnutls"
    "hogweed"
    "nettle"
    "lcms2"
    "libass"
    "libbluray"
    "libdav1d"
    "libfontconfig"
    "libfreetype"
    "libfribidi"
    "libharfbuzz"
    "libplacebo"
    "libshaderc_combined"
    "libsmbclient"
    "libsrt"
    "libzvbi"
)

fix_framework() {
    local framework="$1"
    local framework_path="$FRAMEWORKS_PATH/$framework.framework"

    if [ ! -d "$framework_path" ]; then
        return 0
    fi

    # Check if Info.plist is at root (iOS style)
    if [ -f "$framework_path/Info.plist" ]; then
        echo "  Fixing $framework..."
        
        # Create proper macOS framework structure
        local version_path="$framework_path/Versions/A"
        local resources_path="$version_path/Resources"
        local current_path="$framework_path/Versions/Current"

        # Create directories
        mkdir -p "$resources_path"

        # Move Info.plist to proper location
        mv "$framework_path/Info.plist" "$resources_path/Info.plist"

        # Move the main binary if it exists at root
        local binary_name="$framework"
        if [ -f "$framework_path/$binary_name" ]; then
            mv "$framework_path/$binary_name" "$version_path/$binary_name"
        fi

        # Create symlinks
        ln -sf "A" "$current_path"
        ln -sf "Versions/Current/Resources" "$framework_path/Resources"
        ln -sf "Versions/Current/$binary_name" "$framework_path/$binary_name"
    fi
}

# Process each framework
for frame in "${FRAMES[@]}"; do
    fix_framework "$frame"
done

echo "✅ FFmpegKit framework structure fixed!"
echo ""
echo "Note: This is a workaround for FFmpegKit's macOS bundle compatibility issue."
echo "      The frameworks are using iOS-style bundle structure by default."

exit 0
