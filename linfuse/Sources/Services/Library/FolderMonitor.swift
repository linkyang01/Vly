import Foundation

/// 文件夹监控器 - 简化版（v1.0 占位实现）
/// 注意：完整实现需要 FSEvents 框架，v1.0 暂时使用手动刷新
final class FolderMonitor {
    struct Event {
        let path: URL
        let flags: UInt32
        let eventID: UInt64
    }
    
    var onEvent: ((Event) -> Void)?
    
    init() {}
    
    func startMonitoring(url: URL) {
        // v1.0 占位实现 - 不执行实际监控
        // 完整实现需要使用 FSEvents 框架
    }
    
    func stopMonitoring() {
        // v1.0 占位实现
    }
}

extension FolderMonitor.Event {
    var isCreated: Bool { false }
    var isModified: Bool { false }
    var isRemoved: Bool { false }
    var isRenamed: Bool { false }
    var isDirectory: Bool { false }
    var isFile: Bool { false }
}
