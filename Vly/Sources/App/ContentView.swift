//
//  ContentView.swift
//  Vly
//
//  主窗口内容视图
//

import SwiftUI
import UniformTypeIdentifiers
import AVKit

// MARK: - 自定义视频格式 UTType

extension UTType {
    static var mkv: UTType {
        UTType(filenameExtension: "mkv") ?? .movie
    }
    
    static var flv: UTType {
        UTType(filenameExtension: "flv") ?? .movie
    }
    
    static var webm: UTType {
        UTType(filenameExtension: "webm") ?? .movie
    }
    
    static var wmv: UTType {
        UTType(filenameExtension: "wmv") ?? .movie
    }
    
    static var mov: UTType {
        UTType(filenameExtension: "mov") ?? .video
    }
}

/// 主内容视图
struct ContentView: View {
    // MARK: - State
    
    @State private var videoURL: URL?
    @State private var showingFilePicker = false
    @State private var showingDropOverlay = false
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. 视频播放
                if let url = videoURL {
                    VlyVideoPlayerView(url: url)
                        .transition(.opacity)
                } else {
                    // 2. 空状态
                    emptyStateView
                        .transition(.opacity)
                }
                
                // 3. 拖放覆盖层
                if showingDropOverlay {
                    dropOverlay(geometry: geometry)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
            .onAppear {
                // 检查是否有保存的 URL
                if let savedURL = UserDefaults.standard.url(forKey: "lastOpenVideoURL") {
                    openVideo(savedURL)
                }
                
                // 注册通知监听
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("OpenVideoURL"),
                    object: nil,
                    queue: .main
                ) { notification in
                    if let url = notification.userInfo?["url"] as? URL {
                        openVideo(url)
                    }
                }
            }
            .onDrop(of: [.fileURL, .movie, .video], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
            .onHover { hovering in
                showingDropOverlay = hovering && videoURL == nil
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.movie, .video, .mpeg4Movie, .quickTimeMovie, .avi, .mkv, .flv, .webm, .mov],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
        .onOpenURL { url in
            openVideo(url)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // 图标
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.3))
            
            // 标题
            Text("Vly")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            // 副标题
            Text("简洁优雅的视频播放器")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            
            // 分隔线
            Divider()
                .frame(width: 100)
                .background(Color.white.opacity(0.2))
            
            // 说明
            VStack(spacing: 8) {
                Text("拖放视频文件到此处打开")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("或")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }
            
            // 按钮
            Button {
                showingFilePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                    Text("选择文件")
                }
                .font(.subheadline.bold())
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // 支持格式
            HStack(spacing: 8) {
                FormatBadge(format: "MP4")
                FormatBadge(format: "MKV")
                FormatBadge(format: "AVI")
                FormatBadge(format: "FLV")
                FormatBadge(format: "WebM")
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private func dropOverlay(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
            .foregroundColor(.white.opacity(0.5))
            .background(Color.white.opacity(0.05))
            .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.5)
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    Text("拖放视频文件到此处")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("支持 MP4、MKV、AVI、FLV、WebM 等格式")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            )
    }
    
    // MARK: - Actions
    
    /// 打开视频文件
    private func openVideo(_ url: URL) {
        print("Opening video: \(url)")
        
        // 处理本地文件 URL
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        videoURL = url
        if shouldStopAccessing {
            url.stopAccessingSecurityScopedResource()
        }
        
        // 保存到 UserDefaults
        UserDefaults.standard.set(url, forKey: "lastOpenVideoURL")
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            DispatchQueue.main.async {
                if let data = item as? Data,
                   let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL? {
                    openVideo(url)
                }
            }
        }
        
        return true
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                openVideo(url)
            }
        case .failure(let error):
            print("选择文件失败: \(error)")
        }
    }
}

// MARK: - Format Badge

struct FormatBadge: View {
    let format: String
    
    var body: some View {
        Text(format)
            .font(.caption2.bold())
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 600)
}
