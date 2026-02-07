# App Store Screenshots Template & Guidelines

## Overview
This document provides specifications and guidelines for creating App Store screenshots for linfuse.

## Screenshot Requirements by Device

### iPhone (6.5" Display)
| Property | Value |
|----------|-------|
| Width | 1280 pixels |
| Height | 2778 pixels |
| Format | PNG or JPEG |
| Color Space | sRGB |
| Max File Size | 10 MB |
| Portrait Orientation | Required |
| Number Required | 5-10 screenshots |

### iPad (12.9" Display)
| Property | Value |
|----------|-------|
| Width | 2048 pixels |
| Height | 2732 pixels |
| Format | PNG or JPEG |
| Color Space | sRGB |
| Max File Size | 10 MB |
| Portrait Orientation | Required |
| Number Required | 5-10 screenshots |

### Mac App Store
| Property | Value |
|----------|-------|
| Width | 1280 pixels |
| Height | 800 pixels |
| Format | PNG or JPEG |
| Color Space | sRGB |
| Max File Size | 10 MB |
| Landscape Orientation | Required |
| Number Required | 5-10 screenshots |

## Recommended Screenshot Sequence

### 1. Main Library View (Screenshot #1)
**Purpose**: Show the primary value proposition - organized video library

**Content to Include:**
- Grid or list view of video collection
- Clean, modern UI design
- Multiple video covers visible
- Search bar visible (emphasizing discovery)
- Library statistics (e.g., "150 movies")

**Caption Suggestion (EN):**
> "Your personal video library, beautifully organized"

**Caption Suggestion (ZH):**
> "您的个人视频库，精彩呈现"

---

### 2. Movie Detail View (Screenshot #2)
**Purpose**: Showcase metadata quality and visual design

**Content to Include:**
- Full movie poster artwork
- Movie title and year
- Cast members visible
- Plot synopsis
- Genre tags
- Rating display

**Caption Suggestion (EN):**
> "Beautiful metadata from TMDB"

**Caption Suggestion (ZH):**
> "来自 TMDB 的精美元数据"

---

### 3. Video Player (Screenshot #3)
**Purpose**: Demonstrate playback capabilities

**Content to Include:**
- Video playback in progress
- Custom player controls visible
- Progress bar/ scrubber
- Quality indicator
- Subtitles (if applicable)

**Caption Suggestion (EN):**
> "Built-in player with hardware acceleration"

**Caption Suggestion (ZH):**
> "内置播放器，支持硬件加速"

---

### 4. Smart Categories (Screenshot #4)
**Purpose**: Show organization and discovery features

**Content to Include:**
- Collection cards (e.g., "Continue Watching", "Recently Added")
- Genre browsing
- Year-based filtering
- Smart recommendations

**Caption Suggestion (EN):**
> "Smart categories for easy discovery"

**Caption Suggestion (ZH):**
> "智能分类，轻松发现"

---

### 5. iCloud Sync (Screenshot #5)
**Purpose**: Highlight cross-device experience

**Content to Include:**
- Sync status indicator
- Multiple device icons (Mac, iPhone, iPad)
- Progress synchronization visual
- "Sync complete" message

**Caption Suggestion (EN):**
> "iCloud sync - watch anywhere, continue everywhere"

**Caption Suggestion (ZH):**
> "iCloud 同步 - 随时随地，无缝观看"

---

### 6. Subscription Options (Screenshot #6)
**Purpose**: Showcase pricing and value

**Content to Include:**
- Subscription tiers displayed
- Price per month/year
- "7-day free trial" badge
- Family sharing icon
- "Lifetime" option

**Caption Suggestion (EN):**
> "Flexible plans: $1.99/mo, $9.99/yr, or $19.99 lifetime"

**Caption Suggestion (ZH):**
> "灵活方案：¥18/月、¥128/年或¥198终身"

---

## Screenshot Design Guidelines

### Do's ✓

1. **Use High-Quality Images**
   - Minimum 72 DPI ( Retina recommended)
   - Sharp text and icons
   - No compression artifacts

2. **Show Real Content**
   - Use actual movie covers (with permission)
   - Show realistic library content
   - Avoid placeholder images

3. **Include Device Frame (Optional)**
   - Can include iPhone/iPad/Mac frame
   - Not required by Apple
   - Keep frame subtle

4. **Add Localized Text**
   - Screenshot text in screenshot language
   - Include both EN and ZH versions
   - Consistent with app localization

5. **Use App Store Preview Text**
   - Add 3-5 word captions
   - Highlight key features
   - Use readable font size

### Don'ts ✗

1. **Avoid Device Rotation**
   - All screenshots in portrait (mobile)
   - All screenshots in landscape (Mac)

2. **Don't Include Pricing in Screenshot**
   - Prices change frequently
   - Use caption text instead

3. **Don't Show Sensitive Info**
   - Hide personal file paths
   - Remove personal movie titles if sensitive
   - Use generic examples

4. **Avoid Rounded Corners**
   - Apple adds rounded corners automatically
   - Don't add them yourself

5. **No Hardware Buttons**
   - Don't show home button or notch
   - Use bezel-less design

---

## File Naming Convention

```
screenshot_[device]_[language]_[number].[ext]

Examples:
- screenshot_iphone_en-US_01.png
- screenshot_iphone_zh-CN_01.png
- screenshot_ipad_en-US_01.png
- screenshot_mac_en-US_01.png
```

---

## App Store Preview Text

### iPhone Screenshots
Each screenshot can have up to 3 preview text lines (40 chars max per line).

**Line 1**: Feature name
**Line 2**: Benefit
**Line 3**: Call to action

### Mac Screenshots
Each screenshot can have up to 3 preview text lines (80 chars max per line).

---

## Localization Requirements

### Required Languages
| Language | Locale Code | Status |
|----------|-------------|--------|
| English (US) | en-US | ✅ Required |
| Chinese (Simplified) | zh-CN | ✅ Required |
| Chinese (Traditional) | zh-TW | ⏳ Optional |
| Japanese | ja | ⏳ Optional |
| Korean | ko | ⏳ Optional |

### Screenshot Set Structure
```
Screenshots/
├── iPhone 6.5-inch/
│   ├── en-US/
│   │   ├── screenshot_01.png
│   │   ├── screenshot_02.png
│   │   ├── ...
│   │   └── preview_text.txt
│   └── zh-CN/
│       ├── screenshot_01.png
│       └── ...
├── iPad 12.9-inch/
│   ├── en-US/
│   └── zh-CN/
└── Mac/
    ├── en-US/
    └── zh-CN/
```

---

## Tools for Creating Screenshots

### Built-in Tools
1. **Xcode Simulator**
   - Capture directly from simulator
   - Use ⌘S to save screenshot
   - Location: ~/Desktop

2. **QuickTime Player**
   - Record screen
   - Export specific frames

3. **Screenshots (macOS)**
   - ⌘⇧4 for region capture
   - ⌘⇧5 for window/display

### Third-Party Tools
1. **CleanShot X** (macOS)
   - Annotation features
   - Cloud uploads
   - Built-in background removal

2. **shotbot** (Web)
   - Browser-based
   - Device frames
   - Background blur

3. **App Store Connect Screenshot Uploader**
   - Web-based
   - Auto-resize
   - Preview generation

---

## Quality Checklist

Before uploading to App Store Connect:

- [ ] All screenshots meet size requirements
- [ ] No device frames included (optional but if used, clean design)
- [ ] Text is readable and not cut off
- [ ] No sensitive information visible
- [ ] All screenshots are in the correct orientation
- [ ] File names are descriptive
- [ ] Preview text is added
- [ ] Localized versions ready for each language
- [ ] No Apple hardware buttons visible
- [ ] Colors are accurate (sRGB)
- [ ] File sizes under 10 MB each

---

## Timeline

| Task | Duration |
|------|----------|
| Design mockups | 2-3 days |
| Capture screenshots | 1 day |
| Localization | 1 day |
| Review & revision | 1 day |
| **Total** | **5-7 days** |

---

## Notes

1. **First Upload**: Apple requires at least 1 screenshot for initial submission
2. **Video Preview**: Can replace screenshots with 15-30 second video
3. **App Previews**: Same dimensions as screenshots, but video format (.mov or .m4v)
4. **Updates**: Screenshots can be updated anytime without new build

---

**Last Updated**: 2026-02-04
**Contact**: support@linfuse.app
