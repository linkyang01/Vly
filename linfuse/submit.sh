#!/bin/bash

#===============================================================================
# linfuse App Store Submission Helper Script
# 
# Usage: ./submit.sh [command]
# Commands:
#   help     - Show this help message
#   setup    - Setup environment and prerequisites
#   generate - Generate Xcode project
#   build    - Build for App Store
#   testflight - Upload to TestFlight
#   submit   - Submit to App Store
#   screenshots - Capture App Store screenshots
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="linfuse"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FASTLANE_DIR="${PROJECT_DIR}/fastlane"
BUILD_DIR="${PROJECT_DIR}/build"

# Functions
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_help() {
    print_header "linfuse App Store Submission Helper"
    echo ""
    echo "Usage: ./submit.sh [command]"
    echo ""
    echo "Commands:"
    echo "  help        Show this help message"
    echo "  setup       Check prerequisites and setup"
    echo "  generate    Generate Xcode project with XcodeGen"
    echo "  build       Build App Store version"
    echo "  testflight  Upload to TestFlight"
    echo "  submit      Submit to App Store"
    echo "  screenshots Capture App Store screenshots"
    echo "  validate    Validate configuration"
    echo ""
    echo "Examples:"
    echo "  ./submit.sh setup      # Check prerequisites"
    echo "  ./submit.sh generate   # Generate project"
    echo "  ./submit.sh build      # Build for App Store"
    echo "  ./submit.sh submit     # Submit to App Store"
    echo ""
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check XcodeGen
    if command -v xcodegen &> /dev/null; then
        print_status "XcodeGen is installed ($(xcodegen --version))"
    else
        print_warning "XcodeGen is NOT installed"
        echo "  Install with: brew install xcodegen"
    fi
    
    # Check Fastlane
    if command -v fastlane &> /dev/null; then
        print_status "Fastlane is installed ($(fastlane --version | head -n1))"
    else
        print_warning "Fastlane is NOT installed"
        echo "  Install with: brew install fastlane"
    fi
    
    # Check Xcode
    if command -v xcodebuild &> /dev/null; then
        XCODE_VERSION=$(xcodebuild -version | head -n1)
        print_status "Xcode is installed (${XCODE_VERSION})"
    else
        print_error "Xcode is NOT installed"
        echo "  Please install Xcode from the App Store"
    fi
    
    # Check git
    if command -v git &> /dev/null; then
        print_status "Git is installed ($(git --version))"
    else
        print_error "Git is NOT installed"
    fi
}

setup_environment() {
    print_header "Setting Up Environment"
    
    # Create directories
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}/screenshots"
    
    # Check for App Store Connect API Key
    if [ -f "${PROJECT_DIR}/AppStoreConnect_API_Key.json" ]; then
        print_status "App Store Connect API Key found"
    else
        print_warning "App Store Connect API Key not found"
        echo "  Create one in App Store Connect > Users and Access > Keys"
        echo "  Or set FASTLANE_USER and FASTLANE_PASSWORD environment variables"
    fi
    
    # Verify project.yml exists
    if [ -f "${PROJECT_DIR}/project.yml" ]; then
        print_status "project.yml found"
    else
        print_error "project.yml not found"
        exit 1
    fi
}

generate_project() {
    print_header "Generating Xcode Project"
    
    cd "${PROJECT_DIR}"
    
    # Check XcodeGen
    if ! command -v xcodegen &> /dev/null; then
        print_error "XcodeGen not found. Install with: brew install xcodegen"
        exit 1
    fi
    
    # Generate project
    echo "Running: xcodegen generate..."
    xcodegen generate
    
    if [ -f "${PROJECT_DIR}/${APP_NAME}.xcodeproj/project.pbxproj" ]; then
        print_status "Xcode project generated successfully"
    else
        print_error "Failed to generate Xcode project"
        exit 1
    fi
}

build_appstore() {
    print_header "Building App Store Version"
    
    cd "${PROJECT_DIR}"
    
    # Ensure project is generated
    if [ ! -f "${PROJECT_DIR}/${APP_NAME}.xcodeproj/project.pbxproj" ]; then
        print_warning "Project not generated. Running generate..."
        generate_project
    fi
    
    # Build
    echo "Building ${APP_NAME} for App Store..."
    xcodebuild \
        -scheme "${APP_NAME}" \
        -configuration Release \
        -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
        archive \
        CODE_SIGN_STYLE=automatic \
        DEVELOPMENT_TEAM="" \
        -quiet
    
    if [ -d "${BUILD_DIR}/${APP_NAME}.xcarchive" ]; then
        print_status "Archive created: ${BUILD_DIR}/${APP_NAME}.xcarchive"
    else
        print_error "Failed to create archive"
        exit 1
    fi
}

upload_testflight() {
    print_header "Uploading to TestFlight"
    
    cd "${PROJECT_DIR}"
    
    # Build if needed
    if [ ! -d "${BUILD_DIR}/${APP_NAME}.xcarchive" ]; then
        print_warning "Archive not found. Building first..."
        build_appstore
    fi
    
    # Export for App Store
    echo "Exporting IPA..."
    xcodebuild \
        -exportArchive \
        -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
        -exportOptionsPlist "${PROJECT_DIR}/ExportOptions.plist" \
        -exportPath "${BUILD_DIR}/upload" \
        -quiet
    
    if [ -f "${BUILD_DIR}/upload/${APP_NAME}.ipa" ]; then
        print_status "IPA created: ${BUILD_DIR}/upload/${APP_NAME}.ipa"
    fi
    
    # Upload using Fastlane
    if command -v fastlane &> /dev/null; then
        echo "Uploading to TestFlight via Fastlane..."
        fastlane mac testflight
    else
        print_warning "Fastlane not installed. Using Transporter or Xcode:"
        echo "  1. Open Transporter app"
        echo "  2. Add ${BUILD_DIR}/upload/${APP_NAME}.ipa"
        echo "  3. Upload to App Store Connect"
    fi
    
    print_status "Upload initiated. Check App Store Connect for status."
}

submit_appstore() {
    print_header "Submitting to App Store"
    
    cd "${PROJECT_DIR}"
    
    # Check prerequisites
    if ! command -v fastlane &> /dev/null; then
        print_error "Fastlane not found. Install with: brew install fastlane"
        exit 1
    fi
    
    # Run Fastlane submit lane
    echo "Running Fastlane submit..."
    fastlane mac submit
    
    print_status "Submission initiated!"
    echo ""
    echo "Next steps:"
    echo "  1. Go to https://appstoreconnect.apple.com"
    echo "  2. Select your app"
    echo "  3. Check submission status"
    echo "  4. Respond to any review comments"
}

capture_screenshots() {
    print_header "Capturing App Store Screenshots"
    
    cd "${PROJECT_DIR}"
    
    if command -v fastlane &> /dev/null; then
        fastlane mac screenshots
    else
        print_warning "Fastlane not installed. Manual screenshot capture:"
        echo ""
        echo "iPhone 6.5\" (1280 x 2778 px):"
        echo "  1. Open simulator (Xcode > Open Developer Tool > Simulator)"
        echo "  2. Select iPhone 15 Pro or similar"
        echo "  3. Navigate to each screen"
        echo "  4. Use ⌘S to capture screenshot"
        echo "  5. Save to Screenshots/iPhone/en-US/"
        echo ""
        echo "iPad 12.9\" (2048 x 2732 px):"
        echo "  1. Select iPad Pro 12.9\" simulator"
        echo "  2. Repeat capture process"
        echo ""
        echo "Mac (1280 x 800 px):"
        echo "  1. Run macOS app"
        echo "  2. Capture main screens"
    fi
    
    print_status "Screenshots captured"
}

validate_config() {
    print_header "Validating Configuration"
    
    cd "${PROJECT_DIR}"
    
    # Check project.yml
    if [ -f "project.yml" ]; then
        print_status "project.yml exists"
    else
        print_error "project.yml not found"
    fi
    
    # Check Fastfile
    if [ -f "fastlane/Fastfile" ]; then
        print_status "fastlane/Fastfile exists"
    else
        print_error "fastlane/Fastfile not found"
    fi
    
    # Check ExportOptions.plist
    if [ -f "ExportOptions.plist" ]; then
        print_status "ExportOptions.plist exists"
        # Check for team ID placeholder
        if grep -q "\[YOUR TEAM ID\]" ExportOptions.plist; then
            print_warning "ExportOptions.plist contains placeholder [YOUR TEAM ID]"
            echo "  Replace with your actual Apple Developer Team ID"
        fi
    else
        print_error "ExportOptions.plist not found"
    fi
    
    # Check App Store configuration
    if [ -f "Resources/App Store/AppStore_English.md" ]; then
        print_status "App Store configuration exists"
    else
        print_error "App Store configuration not found"
    fi
    
    # Check TestFlight configuration
    if [ -f "Resources/App Store/TestFlight.md" ]; then
        print_status "TestFlight configuration exists"
    else
        print_error "TestFlight configuration not found"
    fi
    
    print_status "Configuration validation complete"
}

# Main script
case "${1:-help}" in
    help)
        show_help
        ;;
    setup)
        check_prerequisites
        setup_environment
        ;;
    generate)
        generate_project
        ;;
    build)
        build_appstore
        ;;
    testflight)
        upload_testflight
        ;;
    submit)
        submit_appstore
        ;;
    screenshots)
        capture_screenshots
        ;;
    validate)
        validate_config
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use './submit.sh help' for usage information"
        exit 1
        ;;
esac

echo ""
print_status "Done!"
