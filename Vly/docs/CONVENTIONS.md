# Vly 项目规范

## 文件管理

### 原型图
- 路径：`docs/prototypes/`
- 版本命名：`prototype_vN.html`
- 废弃版本：不删除，保留历史

### 文档
- 路径：`docs/`
- 子目录按功能分类：`01-Architecture/`, `02-Requirements/` 等
- 命名： kebab-case（如 `feature-design.md`）

### 代码
- 路径：`Sources/`
- 按功能模块组织：`App/`, `Views/`, `Models/`, `Services/`

---

## 代码规范

### Swift
- 文件/类名：UpperCamelCase
- 变量/函数：lowerCamelCase
- 常量：k 开头（如 `kMaxVolume`）
- 遵循 Apple Swift Style Guide

### 提交信息
```
feat: 新功能
fix: 修复 bug
docs: 文档更新
refactor: 重构
style: 格式调整
```

---

## 原型图版本

| 版本 | 说明 | 状态 |
|------|------|------|
| prototype_v1.html | 单行基础版 | ❌ 废弃 |
| prototype_v2.html | 单行+音量版 | ❌ 废弃 |
| prototype_v3.html | 双行基础版 | ❌ 废弃 |
| prototype_v4.html | 双行+玻璃质感 | ❌ 废弃 |
| prototype_v5.html | 双行最终版 | ✅ 确认 |

---

## 工作流程

1. **设计阶段** → 原型图确认
2. **开发阶段** → 代码实现
3. **测试阶段** → 功能验证
4. **提交阶段** → 文档同步
