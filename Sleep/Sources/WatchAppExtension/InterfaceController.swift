import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    @IBAction func startBreathing() {
        // 发送消息到iOS App
        if WCSession.default.isReachable {
            let message = ["command": "startBreathing"]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func stopBreathing() {
        if WCSession.default.isReachable {
            let message = ["command": "stopBreathing"]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}
