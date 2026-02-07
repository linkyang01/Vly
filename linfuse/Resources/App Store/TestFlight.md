# TestFlight Configuration for linfuse

## Overview
This document describes the TestFlight distribution configuration for linfuse beta testing.

## TestFlight Setup

### Prerequisites
1. Apple Developer Account with active membership
2. App Store Connect access
3. Xcode with proper signing configuration

### Build Configuration

#### Debug Configuration
- Configuration: Debug
- Build Settings:
  - CODE_SIGN_IDENTITY: "-"
  - CODE_SIGNING_REQUIRED: NO
  - CODE_SIGNING_ALLOWED: NO

#### Release Configuration (for Archive)
- Configuration: Release
- Build Settings:
  - CODE_SIGN_IDENTITY: "Apple Development"
  - CODE_SIGN_STYLE: Automatic
  - DEVELOPMENT_TEAM: [Your Team ID]

### Required Capabilities

1. **iCloud**
   - Enable CloudKit
   - Container: iCloud.com.linfuse.app

2. **App Sandbox**
   - File Read/Write
   - Network Client
   - Camera (if applicable)

3. **Family Sharing**
   - Enable in App Store Connect
   - Configure in StoreKit configuration

### TestFlight Features

#### Beta Testing
- **TestFlight Beta Testing**: Enabled
- **External Testing**: Up to 10,000 testers
- **Beta App Version**: 1.8 (1)
- **Test Info**:
  - What's new in this beta: See CHANGES.md
  - Feedback email: support@linfuse.app

#### Beta Review
- Demo Account Required: No
- Notes for Beta Review:
  - App is fully functional without login
  - All features available in beta
  - Subscription required for premium features

### Testing Groups

#### Internal Testing
- Developers and team members
- Automatic access
- Immediate availability

#### External Testing
- Up to 10,000 external testers
- Email or public link invitation
- Requires Beta App Review (typically 1-2 business days)

### TestFlight Users

**Internal Testers:**
| Name | Email | Role |
|------|-------|------|
| Developer | developer@linfuse.app | Admin |
| QA Team | qa@linfuse.app | Tester |

**External Testers (invite via email):**
| Name | Email | Status |
|------|-------|--------|
| Beta User 1 | user1@example.com | Pending |
| Beta User 2 | user2@example.com | Pending |
| Beta User 3 | user3@example.com | Pending |

### Testing Scenarios

#### Required Testing Checklist

- [ ] **Installation**
  - [ ] Download from TestFlight
  - [ ] First launch experience
  - [ ] Permissions request handling

- [ ] **Core Features**
  - [ ] Add video folder
  - [ ] Video scanning
  - [ ] Metadata fetching
  - [ ] Library display
  - [ ] Video playback
  - [ ] Progress tracking

- [ ] **iCloud Sync**
  - [ ] Sync across devices
  - [ ] Progress synchronization
  - [ ] Conflict resolution

- [ ] **Subscription**
  - [ ] Monthly subscription purchase
  - [ ] Yearly subscription purchase
  - [ ] Lifetime purchase
  - [ ] 7-day free trial activation
  - [ ] Family sharing activation

- [ ] **Performance**
  - [ ] Large library scanning
  - [ ] Memory usage
  - [ ] Battery impact (iOS)

- [ ] **Stability**
  - [ ] Crash-free operation
  - [ ] Network disconnection handling
  - [ ] Background/foreground transitions

### TestFlight Metadata

#### App Information
- **App Name**: linfuse
- **Category**: Entertainment
- **Subtitle**: Smart Video Library Manager
- **Description**: See AppStore_English.md

#### Screenshots
- **iPhone 6.5"**: 1280 x 2778 px (6 screenshots)
- **iPad 12.9"**: 2048 x 2732 px (6 screenshots)
- **Mac**: 1280 x 800 px (6 screenshots)

#### What's New in Build
```
Version 1.8 (Build 1)
🚀 Welcome to TestFlight!

This beta brings the complete linfuse experience:
- Smart video library management
- Automatic metadata from TMDB
- iCloud sync across devices
- Built-in video player
- Watch history & favorites
- Multiple subscription options

Known Issues:
- First-time library scan may take several minutes
- Some rare video formats may not play

Feedback: support@linfuse.app
```

### Distribution Steps

1. **Prepare Build**
   ```bash
   # Generate project
   cd /path/to/linfuse
   xcodegen generate
   
   # Build for archiving
   xcodebuild -scheme linfuse \
     -configuration Release \
     -archivePath build/linfuse.xcarchive \
     archive
   ```

2. **Upload to App Store Connect**
   ```bash
   # Using Xcode
   xcodebuild -exportArchive \
     -archivePath build/linfuse.xcarchive \
     -exportOptionsPlist ExportOptions.plist \
     -exportPath upload
   
   # Or using Transporter app
   open Transporter
   ```

3. **Submit for TestFlight**
   - Go to App Store Connect
   - Navigate to TestFlight tab
   - Select build
   - Complete beta app information
   - Submit for review

4. **Distribute to Testers**
   - Add external testers (if approved)
   - Send invitations
   - Monitor feedback

### Export Options (ExportOptions.plist)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>[YOUR TEAM ID]</string>
    <key>uploadBitcode</key>
    <true/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
</dict>
</plist>
```

### Troubleshooting

#### Common Issues

1. **Build Rejection**
   - Ensure all screenshots are provided
   - Verify privacy policy URL
   - Check App Store Connect for missing information

2. **TestFlight Not Available**
   - Verify beta testing is enabled
   - Check build processing status
   - Ensure app state is "Ready to Test"

3. **Install Issues**
   - Verify tester has accepted invitation
   - Check device UDID registration
   - Ensure iOS/macOS version compatibility

#### Support
- TestFlight app support
- Apple Developer documentation
- App Store Connect help

### Version History

| Version | Build | Date | Status |
|---------|-------|------|--------|
| 1.8 | 1 | 2026-02-04 | Testing |

---

**For questions about TestFlight, contact: support@linfuse.app**
