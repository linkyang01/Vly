# QuitDo 系统架构

## 📐 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    用户设备 (iOS)                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              SwiftUI Views                       │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐          │   │
│  │  │HomeView │ │ChatView │ │Profile  │          │   │
│  │  └─────────┘ └─────────┘ └─────────┘          │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │              Services Layer                       │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐          │   │
│  │  │Firebase │ │MiniMax  │ │HealthKit│          │   │
│  │  │Auth/Srv │ │   API   │ │   API   │          │   │
│  │  └─────────┘ └─────────┘ └─────────┘          │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Firebase Backend                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐     │
│  │  Auth       │ │  Firestore  │ │ Cloud Msg   │     │
│  │  (用户管理) │ │  (数据存储) │ │  (推送)     │     │
│  └─────────────┘ └─────────────┘ └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   MiniMax API                             │
│              (AI 对话 + 个性化辅导)                       │
└─────────────────────────────────────────────────────────┘
```

## 🗂️ 模块划分

```
QuitDo/
├── Sources/
│   ├── App/                    # 应用入口
│   │   └── QuitDoApp.swift
│   ├── Views/                  # 视图层
│   │   ├── Home/
│   │   ├── Chat/
│   │   ├── Profile/
│   │   └── Components/
│   ├── Models/                 # 数据模型
│   │   ├── User.swift
│   │   ├── SmokingRecord.swift
│   │   └── Achievement.swift
│   ├── Services/               # 服务层
│   │   ├── FirebaseService.swift
│   │   ├── MiniMaxService.swift
│   │   ├── HealthKitService.swift
│   │   └── NotificationService.swift
│   └── Cells/                  # 列表单元格
├── Resources/
│   ├── sounds/                 # 音效
│   ├── assets/                 # 图片资源
│   └── Localizable.strings      # 多语言
└── docs/                       # 文档
```

## 🔌 服务接口

### Firebase Service
```swift
class FirebaseService {
    // 用户认证
    func signIn(email: String, password: String) async throws
    
    // 数据保存
    func saveSmokingRecord(_ record: SmokingRecord) async throws
    
    // 数据查询
    func fetchSmokingRecords(userId: String) async throws
}
```

### MiniMax Service
```swift
class MiniMaxService {
    // AI 对话
    func sendMessage(_ message: String, context: [Message]) async throws -> String
    
    // 烟瘾应对话术
    func getCravingResponse(trigger: String) async throws -> String
}
```

### HealthKit Service
```swift
class HealthKitService {
    // 获取心率
    func fetchHeartRate() async throws -> Double
    
    // 写入戒烟进度
    func saveQuitProgress(_ progress: QuitProgress) async throws
}
```

## 📊 数据模型

### User
```swift
struct User {
    let id: String
    var quitDate: Date
    var cigarettesPerDay: Int
    var pricePerPack: Int
    var streakDays: Int
    var achievements: [Achievement]
}
```

### SmokingRecord
```swift
struct SmokingRecord {
    let id: String
    let userId: String
    let date: Date
    var cigarettesSmoked: Int
    var cravings: [Craving]
    var mood: Mood
}
```

### Achievement
```swift
struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    var unlockedAt: Date?
}
```

## 🔐 安全设计

1. **API Key 存储**: 使用 `.env` 文件，不提交到代码库
2. **用户隐私**: HealthKit 数据本地加密
3. **网络请求**: HTTPS + TLS 1.3

## 🚀 部署架构

| 环境 | Firebase | API | 域名 |
|------|----------|-----|------|
| 开发 | Local Emulator | MiniMax Sandbox | localhost |
| 测试 | Firebase Test | MiniMax Production | quitdo.test |
| 生产 | Firebase Prod | MiniMax Production | quitdo.app |

---

*最后更新: 2026-02-06*
