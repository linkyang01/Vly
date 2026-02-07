# linfuse

A multi-platform media library application for macOS and iOS with iCloud synchronization.

## 🏝️ Overview

**linfuse** is a personal media library manager that lets you:
- 📽️ Organize your local movie collection
- 📺 Track TV shows and episodes
- ☁️ Sync your library across Mac and iPhone via iCloud
- 🎯 Keep watch history and progress synced everywhere

## 📱 Platforms

| Platform | Version | Target |
|----------|---------|--------|
| macOS | 14.0+ (Sonoma+) | Desktop |
| iOS | 17.0+ | iPhone & iPad |

## ✨ Features

### Core Features (Both Platforms)
- **Movie Library**: Import and organize local video files
- **Metadata Fetching**: Automatic metadata from TMDB
- **Watch Tracking**: Progress, history, and statistics
- **Smart Collections**: Recently added, continue watching, top rated
- **Search & Filter**: Find movies by title, genre, rating
- **Multiple View Modes**: Grid, list, and hero views

### iCloud Sync Features
- **Library Database Sync**: Movies, shows, episodes sync automatically
- **Watch Progress Sync**: Resume playback from any device
- **Preferences Sync**: Settings sync across devices
- **Playlists & Watchlist**: Collections sync via CloudKit
- **Conflict Resolution**: Smart merge for simultaneous edits

### macOS-Specific Features
- **Folder Monitoring**: Auto-detect new videos in library folders
- **Drag & Drop**: Easy import via Finder
- **Keyboard Shortcuts**: Power user shortcuts
- **Dark Mode**: Full native dark mode support

### iOS-Specific Features
- **Touch-Optimized UI**: Large buttons, swipe gestures
- **Portrait & Landscape**: Adaptive layouts
- **Background Sync**: Efficient iCloud synchronization
- **iPad Support**: Split view and external display support

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Shared Business Logic                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ ViewModels   │  │ Services    │  │ Utilities              │  │
│  │ (Shared)    │  │ (Shared)     │  │ (Shared)                │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │ Core Data + CloudKit │  │ TMDB API Service                 │ │
│  │ (iCloud Sync)        │  │ (Network)                        │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
              │                                      │
              ▼                                      ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│         macOS Target        │     │          iOS Target         │
│  ┌───────────────────────┐  │     │  ┌───────────────────────┐   │
│  │ SwiftUI + AppKit      │  │     │  │ SwiftUI + UIKit       │   │
│  │ (Mouse/Keyboard)      │  │     │  │ (Touch)               │   │
│  └───────────────────────┘  │     │  └───────────────────────┘   │
└─────────────────────────────┘     └─────────────────────────────┘
```

### Technology Stack

- **SwiftUI** - Modern declarative UI framework
- **Core Data + CloudKit** - Local persistence with iCloud sync
- **XcodeGen** - Project generation
- **Kingfisher** - Image loading and caching
- **Lottie** - Animations
- **TMDB API** - Movie metadata provider

### Key Components

1. **CloudSyncManager** - Handles iCloud synchronization
2. **FileAccessManager** - Platform-specific file operations
3. **TMDBService** - API integration
4. **LibraryViewModel** - Shared business logic

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- XcodeGen (`brew install xcodegen`)
- Apple Developer Account (for iCloud sync)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/linfuse.git
cd linfuse

# Generate Xcode project
xcodegen generate

# Build for macOS
xcodebuild -scheme linfuse-macOS -configuration Debug build

# Build for iOS (requires signing)
xcodebuild -scheme linfuse-iOS -configuration Debug build
```

### Configuration

1. **TMDB API Key**: Get one from [The Movie Database](https://www.themoviedb.org/)
2. **iCloud Container**: Configure in Apple Developer portal
3. **Team ID**: Set in project.yml or Xcode

## 📁 Project Structure

```
linfuse/
├── Sources/
│   ├── App/               # App entry points
│   ├── ViewModels/        # Business logic
│   ├── Models/
│   │   ├── CoreData/      # Data entities
│   │   └── DTO/           # API models
│   ├── Services/          # Cloud sync, API
│   ├── Utilities/         # Helpers
│   └── Views/             # UI components
├── Resources-macOS/       # macOS-specific
├── Resources-iOS/         # iOS-specific
├── Resources/             # Shared resources
├── project.yml            # XcodeGen config
└── Documentation/        # Guides
```

## 🔧 Development

### Running Locally

```bash
# Generate project
xcodegen generate

# Open in Xcode
open linfuse.xcodeproj
```

### Adding New Features

1. **Shared Logic**: Add to `Sources/ViewModels/` or `Sources/Services/`
2. **macOS-Only**: Add to `Sources/App/macOS/` or conditional compilation
3. **iOS-Only**: Add to `Sources/App/iOS/` or conditional compilation

### Code Style

- Swift 5.9+
- SwiftUI first
- Async/await for concurrency
- Swift Package Manager for dependencies

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| Kingfisher | 7.10.0+ | Image caching |
| Lottie | 4.3.0+ | Animations |
| CloudKit | 1.0.0+ | iCloud sync (native) |

## ☁️ iCloud Sync Architecture

### Data Model

All Core Data entities include sync metadata:
- `cloudKitRecordID`: Unique CloudKit identifier
- `syncStatus`: Sync state (synced, pending, conflict)
- `lastSyncDate`: Last successful sync timestamp
- `deviceModifiedDate`: Track local modifications

### Sync Flow

```
Local Change → Update Core Data → Mark Pending → Push to CloudKit
                                                            ↓
CloudKit Change ← Fetch Changes ← ← ← ← ← ← ← Acknowledge
                        ↓
                Update Local Store
```

### Conflict Resolution

1. **Automatic**: Most conflicts auto-resolve using timestamps
2. **Merge Strategy**: For watch progress, keep highest value
3. **Manual Review**: Complex conflicts prompt user decision

## 📄 License

MIT License - See LICENSE file for details.

## 🙏 Acknowledgments

- [The Movie Database](https://www.themoviedb.org/) for metadata
- [Kingfisher](https://github.com/onevcat/Kingfisher) for image handling
- [Lottie](https://github.com/airbnb/lottie-ios) for animations

---

**Built with ❤️ for media lovers**
