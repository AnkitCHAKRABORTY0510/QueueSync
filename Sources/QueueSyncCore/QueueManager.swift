import Foundation

public class QueueManager: ObservableObject {
    @Published public private(set) var items: [QueueItem] = []
    
    public init() {
        self.items = Storage.loadQueue()
    }
    
    public func add(path: String) {
        let fullPath = (path as NSString).expandingTildeInPath
        let fileManager = FileManager.default
        
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) {
            let type = isDir.boolValue ? "folder" : "file"
            let item = QueueItem(path: fullPath, type: type)
            DispatchQueue.main.async {
                self.items.append(item)
                Storage.saveQueue(self.items)
                print("Added \(type) to queue: \(fullPath)")
            }
        } else {
            print("Error: File or folder not found at path: \(fullPath)")
            // No longer exiting to avoid crashing the GUI
        }
    }
    
    public func list() {
        if items.isEmpty {
            print("Queue is empty.")
            return
        }
        
        print(String(format: "%-20@ | %-12@ | %-8@ | %@", "ID" as NSString, "STATUS" as NSString, "TYPE" as NSString, "PATH" as NSString))
        print(String(repeating: "-", count: 80))
        
        for item in items {
            let shortId = String(item.id.prefix(8)) + "..."
            print(String(format: "%-20@ | %-12@ | %-8@ | %@", shortId as NSString, item.status.rawValue.uppercased() as NSString, item.type as NSString, item.path as NSString))
        }
    }
    
    public func updateStatus(for id: String, to newStatus: TransferStatus) {
        DispatchQueue.main.async {
            if let index = self.items.firstIndex(where: { $0.id == id }) {
                self.items[index].status = newStatus
                if newStatus == .transferring && self.items[index].startedAt == nil {
                    self.items[index].startedAt = Date()
                } else if newStatus == .completed || newStatus == .failed {
                    self.items[index].finishedAt = Date()
                }
                Storage.saveQueue(self.items)
            }
        }
    }
    
    public func updateProgress(for id: String, to newProgress: Double) {
        DispatchQueue.main.async {
            if let index = self.items.firstIndex(where: { $0.id == id }) {
                self.items[index].progress = newProgress
                Storage.saveQueue(self.items)
            }
        }
    }
    public func remove(id: String) {
        DispatchQueue.main.async {
            self.items.removeAll(where: { $0.id == id })
            Storage.saveQueue(self.items)
        }
    }
    
    public func clear() {
        let initialCount = items.count
        DispatchQueue.main.async {
            self.items.removeAll(where: { $0.status == .completed || $0.status == .failed })
            Storage.saveQueue(self.items)
            print("Cleared \(initialCount - self.items.count) completed/failed items from queue.")
        }
    }
}
