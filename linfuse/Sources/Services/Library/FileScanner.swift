import Foundation
import Combine

/// 视频文件扫描器
final class FileScanner {
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.linfuse.scanner", qos: .userInitiated)
    
    /// 支持的视频文件扩展名
    let supportedExtensions: Set<String> = [
        "mp4", "m4v", "mov", "mkv", "avi", "wmv", "flv", "webm", "mpg", "mpeg", "3gp", "3g2", "ogg", "m2ts", "ts", "m4a"
    ]
    
    // MARK: - Full Scan
    
    /// 扫描整个文件夹
    func scanFolder(_ url: URL) async -> [ScannedVideoFile] {
        var videoFiles: [ScannedVideoFile] = []
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [
                .isRegularFileKey,
                .contentModificationDateKey,
                .fileSizeKey,
                .creationDateKey
            ],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  let isFile = values.isRegularFile,
                  isFile else {
                continue
            }
            
            let ext = fileURL.pathExtension.lowercased()
            if supportedExtensions.contains(ext) {
                let videoFile = ScannedVideoFile(
                    id: fileURL,
                    url: fileURL,
                    name: fileURL.deletingPathExtension().lastPathComponent,
                    size: Int64(values.fileSize ?? 0),
                    modifiedDate: values.contentModificationDate,
                    createdDate: values.creationDate,
                    `extension`: ext
                )
                videoFiles.append(videoFile)
            }
        }
        
        return videoFiles
    }
    
    /// 扫描单个文件
    func scanFile(_ url: URL) async -> ScannedVideoFile? {
        guard let values = try? url.resourceValues(
            forKeys: [
                .isRegularFileKey,
                .contentModificationDateKey,
                .fileSizeKey,
                .creationDateKey
            ]
        ),
        let isFile = values.isRegularFile,
        isFile else {
            return nil
        }
        
        let ext = url.pathExtension.lowercased()
        guard supportedExtensions.contains(ext) else {
            return nil
        }
        
        return ScannedVideoFile(
            id: url,
            url: url,
            name: url.deletingPathExtension().lastPathComponent,
            size: Int64(values.fileSize ?? 0),
            modifiedDate: values.contentModificationDate,
            createdDate: values.creationDate,
            `extension`: ext
        )
    }
    
    // MARK: - Incremental Scan
    
    /// 增量扫描 - 只扫描新增或修改的文件
    func incrementalScan(
        folderURL: URL,
        knownFiles: [URL: Date]
    ) async -> (newFiles: [ScannedVideoFile], modifiedFiles: [ScannedVideoFile], deletedFiles: [URL]) {
        var newFiles: [ScannedVideoFile] = []
        var modifiedFiles: [ScannedVideoFile] = []
        var deletedFiles: [URL] = []
        
        let currentFiles = await scanFolder(folderURL)
        var currentFileMap: [URL: Date] = [:]
        
        for videoFile in currentFiles {
            currentFileMap[videoFile.url] = videoFile.modifiedDate ?? Date.distantPast
            
            if let lastModified = knownFiles[videoFile.url] {
                // 检查是否修改
                if videoFile.modifiedDate ?? Date.distantPast > lastModified {
                    modifiedFiles.append(videoFile)
                }
            } else {
                // 新文件
                newFiles.append(videoFile)
            }
        }
        
        // 检测删除的文件
        for knownURL in knownFiles.keys {
            if currentFileMap[knownURL] == nil {
                deletedFiles.append(knownURL)
            }
        }
        
        return (newFiles, modifiedFiles, deletedFiles)
    }
    
    // MARK: - Batch Operations
    
    /// 批量扫描多个文件夹
    func scanMultipleFolders(_ urls: [URL]) async -> [ScannedVideoFile] {
        await withTaskGroup(of: [ScannedVideoFile].self) { group in
            for url in urls {
                group.addTask {
                    await self.scanFolder(url)
                }
            }
            
            var allFiles: [ScannedVideoFile] = []
            for await files in group {
                allFiles.append(contentsOf: files)
            }
            return allFiles
        }
    }
}

// MARK: - Video File Model

struct ScannedVideoFile: Identifiable, Hashable {
    let id: URL
    let url: URL
    let name: String
    let size: Int64
    let modifiedDate: Date?
    let createdDate: Date?
    let `extension`: String
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var pathString: String {
        url.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: ScannedVideoFile, rhs: ScannedVideoFile) -> Bool {
        lhs.url == rhs.url
    }
}
