import SwiftUI

@main
struct VlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 处理命令行参数中的文件
                    handleCommandLineArguments()
                }
                .onOpenURL { url in
                    // 处理 Finder 打开的文件
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: Notification.Name("OpenVideoURL"),
                            object: nil,
                            userInfo: ["url": url]
                        )
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    private func handleCommandLineArguments() {
        let arguments = CommandLine.arguments
        
        if arguments.count > 1 {
            for i in 1..<arguments.count {
                let arg = arguments[i]
                if !arg.hasPrefix("-") {
                    let url = URL(fileURLWithPath: arg)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: Notification.Name("OpenVideoURL"),
                            object: nil,
                            userInfo: ["url": url]
                        )
                    }
                    break
                }
            }
        }
    }
}
