import Foundation
import UniformTypeIdentifiers

/// 文件服务 - 处理本地文件导入和扫描
class FileService: ObservableObject {
    // MARK: - Singleton
    
    static let shared = FileService()
    
    // MARK: - Published Properties
    
    @Published var recentFiles: [URL] = []
    @Published var isImporting: Bool = false
    
    // MARK: - Private Properties
    
    private let userDefaultsRecentFilesKey = "vly_recent_files"
    private let maxRecentFiles = 20
    
    // MARK: - Supported Formats
    
    static let supportedVideoFormats: [UTType] = [
        .movie,
        .video,
        .mpeg4Movie,
        .quickTimeMovie,
        .avi,
        UTType(filenameExtension: "mkv") ?? .movie,
        UTType(filenameExtension: "flv") ?? .movie,
        UTType(filenameExtension: "webm") ?? .movie
    ]
    
    static let supportedSubtitleFormats: [UTType] = [
        .plainText,
        UTType(filenameExtension: "srt") ?? .plainText,
        UTType(filenameExtension: "ass") ?? .plainText,
        UTType(filenameExtension: "ssa") ?? .plainText,
        UTType(filenameExtension: "vtt") ?? .plainText
    ]
    
    // MARK: - Initialization
    
    private init() {
        loadRecentFiles()
    }
    
    // // MARK: - File Operations
    
    func importFile(url: URL) -> Video? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // 复制文件到应用目录
        guard let destinationURL = copyFileToAppDirectory(url) else { return nil }
        
        // 添加到最近文件
        addToRecentFiles(destinationURL)
        
        // 创建视频对象
        return createVideo(from: destinationURL)
    }
    
    func importFiles(urls: [URL]) -> [Video] {
        isImporting = true
        defer { isImporting = false }
        
        return urls.compactMap { importFile(url: $0) }
    }
    
    func importDirectory(url: URL) -> [Video] {
        guard url.hasDirectoryPath else { return [] }
        
        let fileManager = FileManager.default
        var videos: [Video] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey, .contentTypeKey],
                options: [.skipsHiddenFiles]
            )
            
            for fileURL in contents {
                guard fileURL.isFileURL else { continue }
                
                if let contentType = try? fileURL.resourceValues(forKeys: [.contentTypeKey]).contentType,
                   isVideoFile(contentType: contentType) {
                    if let video = importFile(url: fileURL) {
                        videos.append(video)
                    }
                }
            }
        } catch {
            print("Error reading directory: \(error)")
        }
        
        return videos
    }
    
    func deleteFile(url: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            removeFromRecentFiles(url)
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
    func getFileInfo(url: URL) -> (size: Int64, created: Date?, modified: Date?) {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey]) else {
            return (0, nil, nil)
        }
        
        return (
            values.fileSize.map { Int64($0) } ?? 0,
            values.creationDate,
            values.contentModificationDate
        )
    }
    
    // MARK: - Video Creation
    
    private func createVideo(from url: URL) -> Video? {
        let fileInfo = getFileInfo(url: url)
        let format = detectVideoFormat(url: url)
        let resolution = detectVideoResolution(url: url)
        
        let video = Video(
            title: url.deletingPathExtension().lastPathComponent,
            url: url,
            localPath: url.path,
            duration: 0, // 将在播放时获取
            currentPosition: 0,
            format: format,
            resolution: resolution,
            fileSize: fileInfo.size,
            dateAdded: fileInfo.created ?? Date()
        )
        
        return video
    }
    
    // MARK: - Format Detection
    
    private func detectVideoFormat(url: URL) -> VideoFormat {
        let ext = url.pathExtension.lowercased()
        
        switch ext {
        case "mp4", "m4v": return .mp4
        case "mkv": return .mkv
        case "avi": return .avi
        case "flv": return .flv
        case "webm": return .webm
        case "mov": return .mov
        case "ts", "m2ts": return .ts
        case "m3u8": return .m3u8
        default: return .unknown
        }
    }
    
    private func detectVideoResolution(url: URL) -> VideoResolution {
        // 实际实现需要使用 AVAsset 或 FFmpeg 获取视频信息
        // 这里返回 unknown，实际播放时会更新
        return .unknown
    }
    
    private func isVideoFile(contentType: UTType) -> Bool {
        for videoType in Self.supportedVideoFormats {
            if contentType.conforms(to: videoType) {
                return true
            }
        }
        return false
    }
    
    // MARK: - File Management
    
    private func copyFileToAppDirectory(_ url: URL) -> URL? {
        let fileManager = FileManager.default
        
        // 创建应用文档目录下的 Videos 文件夹
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosPath = documentsPath.appendingPathComponent("Videos", isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: videosPath.path) {
                try fileManager.createDirectory(at: videosPath, withIntermediateDirectories: true)
            }
            
            let destinationURL = videosPath.appendingPathComponent(url.lastPathComponent)
            
            // 如果文件已存在，添加序号
            var finalURL = destinationURL
            var counter = 1
            while fileManager.fileExists(atPath: finalURL.path) {
                let name = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension
                finalURL = videosPath.appendingPathComponent("\(name)_\(counter).\(ext)")
                counter += 1
            }
            
            // 复制文件
            try fileManager.copyItem(at: url, to: finalURL)
            return finalURL
        } catch {
            print("Error copying file: \(error)")
            return nil
        }
    }
    
    // MARK: - Recent Files
    
    private func addToRecentFiles(_ url: URL) {
        recentFiles.removeAll { $0 == url }
        recentFiles.insert(url, at: 0)
        
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        saveRecentFiles()
    }
    
    private func removeFromRecentFiles(_ url: URL) {
        recentFiles.removeAll { $0 == url }
        saveRecentFiles()
    }
    
    func clearRecentFiles() {
        recentFiles.removeAll()
        saveRecentFiles()
    }
    
    private func saveRecentFiles() {
        UserDefaults.standard.set(recentFiles.map { $0.absoluteString }, forKey: userDefaultsRecentFilesKey)
    }
    
    private func loadRecentFiles() {
        if let strings = UserDefaults.standard.stringArray(forKey: userDefaultsRecentFilesKey) {
            recentFiles = strings.compactMap { URL(string: $0) }
        }
    }
}
