import Foundation

public class TransferManager {
    let queueManager: QueueManager
    
    public init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    public func start() {
        let pendingItems = queueManager.items.filter { $0.status == .pending || $0.status == .retrying }
        guard !pendingItems.isEmpty else {
            print("No pending items to transfer.")
            return
        }
        
        let config = Config.load()
        if config.host.isEmpty || config.user.isEmpty || config.destination.isEmpty {
            print("Error: Config missing host, user, or dest. Run queuesync config set first.")
            return
        }
        
        for item in pendingItems {
            let filename = (item.path as NSString).lastPathComponent
            queueManager.updateStatus(for: item.id, to: .transferring)
            Logger.log(event: "START", filename: filename)
            
            var attempt = item.retries
            var success = false
            let backoffSchedule = [5, 10, 20] // seconds
            
            while attempt < config.maxRetries && !success {
                if attempt > 0 {
                    print("\nTransferring \(filename) (Attempt \(attempt + 1))...")
                }
                
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/rsync")
                
                process.arguments = [
                    "-avz",
                    "--partial",
                    "--progress",
                    "--rsh=ssh -o StrictHostKeyChecking=no -o BatchMode=yes",
                    item.path,
                    "\(config.user)@\(config.host):\(config.destination)"
                ]
                
                let pipe = Pipe()
                process.standardOutput = pipe
                let outHandle = pipe.fileHandleForReading
                
                do {
                    try process.run()
                    let regex = try? NSRegularExpression(pattern: "([0-9]+)%")
                    
                    while process.isRunning {
                        let data = outHandle.availableData
                        if data.isEmpty { break }
                        
                        if let str = String(data: data, encoding: .utf8) {
                            let range = NSRange(location: 0, length: str.utf16.count)
                            if let match = regex?.firstMatch(in: str, options: [], range: range),
                               let percentRange = Range(match.range(at: 1), in: str),
                               let percentInt = Double(str[percentRange]) {
                                
                                queueManager.updateProgress(for: item.id, to: percentInt)
                                let progressStr = String(format: "\rTransferring %-15@ [%-20@] %3.0f%%", filename as NSString, String(repeating: "=", count: Int(percentInt / 5)) as NSString, percentInt)
                                print(progressStr, terminator: "")
                                fflush(stdout)
                            }
                        }
                    }
                    process.waitUntilExit()
                    if attempt == 0 {
                        print("") // Complete progress bar newline
                    }
                    
                    if process.terminationStatus == 0 {
                        success = true
                    } else {
                        success = false
                    }
                } catch {
                    print("\nError running rsync: \(error)")
                    success = false
                }
                
                if success {
                    queueManager.updateStatus(for: item.id, to: .completed)
                    Logger.log(event: "SUCCESS", filename: filename)
                } else {
                    attempt += 1
                    queueManager.updateStatus(for: item.id, to: .retrying)
                    Logger.log(event: "RETRY(\(attempt))", filename: filename)
                    
                    if attempt < config.maxRetries { 
                        let waitTime = backoffSchedule[min(attempt - 1, backoffSchedule.count - 1)]
                        print("Transfer failed. Retrying in \(waitTime) seconds...")
                        sleep(UInt32(waitTime))
                    } else {
                        queueManager.updateStatus(for: item.id, to: .failed)
                        Logger.log(event: "FAILED", filename: filename)
                        print("Transfer failed completely after \(config.maxRetries) retries.")
                    }
                }
            }
        }
        print("All transfers finished.")
    }
}
