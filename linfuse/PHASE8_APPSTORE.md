# Phase 8: App Store 上架准备

**状态**: ✅ 已完成  
**日期**: 2026-02-04  
**优先级**: P0（最高）

---

## 📋 任务概览

本 Phase 完成 App Store 上架所需的全部配置，包括：

1. ✅ App Store 页面配置（美国市场 - 英文）
2. ✅ 定价与订阅系统配置
3. ✅ TestFlight 分发配置
4. ✅ Fastlane 自动化部署
5. ✅ App Store 截图规范

---

## 📁 创建的配置文件

```
linfuse/
├── submit.sh                    # 一键提交脚本
├── ExportOptions.plist         # App Store 分发配置
├── fastlane/
│   └── Fastfile                # Fastlane 自动化脚本
└── Resources/App Store/
    ├── AppStore.md              # 快速配置指南
    ├── AppStore_English.md     # 完整英文配置（美国市场）
    ├── In-App_Purchases.json   # 应用内购买配置
    ├── Info.plist              # App Store 版本 Info.plist
    ├── TestFlight.md           # TestFlight 测试配置
    └── Screenshots_Guide.md    # 截图规格与设计指南
```

---

## 💰 定价配置

| 订阅类型 | Product ID | 美国价格 | 中国价格 | 免费试用 | 家庭共享 |
|----------|-----------|---------|---------|---------|---------|
| **月度订阅** | `linfuse.monthly` | $1.99 | ¥18 | 7天 | 5台设备 |
| **年度订阅** | `linfuse.yearly` | $9.99 | ¥128 | 7天 | 5台设备 |
| **终身买断** | `linfuse.lifetime` | $19.99 | ¥198 | - | 5台设备 |

---

## 🚀 快速开始

### 1. 检查环境
```bash
./submit.sh setup
```

### 2. 生成项目
```bash
./submit.sh generate
```

### 3. 构建版本
```bash
./submit.sh build
```

### 4. 上传 TestFlight
```bash
./submit.sh testflight
```

### 5. 提交审核
```bash
./submit.sh submit
```

---

## 📱 截图要求

| 设备 | 尺寸 | 数量 |
|------|------|------|
| iPhone 6.5" | 1280 x 2778 px | 5-10 张 |
| iPad 12.9" | 2048 x 2732 px | 5-10 张 |
| Mac | 1280 x 800 px | 5-10 张 |

### 建议截图顺序

1. 📚 **主界面** - 媒体库概览
2. 🎬 **电影详情** - 元数据展示
3. ▶️ **播放器** - 播放界面
4. 🏷️ **智能分类** - 分类浏览
5. ☁️ **iCloud 同步** - 跨设备体验
6. 💰 **订阅选项** - 定价展示

---

## 📝 提交流程

### 使用 Fastlane
```bash
# 准备截图
fastlane mac screenshots

# 上传 TestFlight
fastlane mac testflight

# 提交 App Store
fastlane mac submit
```

### 手动上传
1. Xcode: Product > Archive > Distribute App > App Store Connect
2. 或使用 Transporter.app

---

## ⚠️ 上架前检查清单

- [ ] **App Store 截图** - 准备 5-6 张关键界面
- [ ] **App 图标** - 1024x1024 px 高清图标
- [ ] **隐私政策** - 发布 https://linfuse.app/privacy
- [ ] **支持邮箱** - support@linfuse.app
- [ ] **Apple Developer** - 配置 App Store Connect
- [ ] **Team ID** - 更新 ExportOptions.plist
- [ ] **API Key** - 配置 App Store Connect API Key

---

## 📞 资源链接

- **官网**: https://linfuse.app
- **支持邮箱**: support@linfuse.app
- **隐私政策**: https://linfuse.app/privacy
- **Apple Developer**: https://developer.apple.com
- **App Store Connect**: https://appstoreconnect.apple.com

---

## ⏭️ 下一步

1. 准备 App Store 截图
2. 配置 App Store Connect
3. 创建应用内购买产品
4. 构建并上传 TestFlight
5. 提交审核

---

## 📄 文档列表

| 文件 | 说明 |
|------|------|
| `submit.sh` | 一键提交脚本 |
| `PROGRESS.md` | 开发进度跟踪 |
| `README.md` | 项目说明文档 |
| `fastlane/Fastfile` | Fastlane 自动化 |
| `AppStore_English.md` | 完整英文配置 |
| `TestFlight.md` | TestFlight 配置 |
| `Screenshots_Guide.md` | 截图规范 |

---

**Phase 8 完成日期**: 2026-02-04
