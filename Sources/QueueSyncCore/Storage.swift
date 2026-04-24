import Foundation

public struct Storage {
    static let fileManager = FileManager.default
    public static var testOverrideURL: URL?
    
    public static var dataDirectoryURL: URL {
        if let override = testOverrideURL { return override }
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDir = paths[0].appendingPathComponent("QueueSync")
        if !fileManager.fileExists(atPath: appSupportDir.path) {
            try? fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
        }
        return appSupportDir
    }
    
    static var queueFileURL: URL {
        return dataDirectoryURL.appendingPathComponent("queue.json")
    }
    
    public static func saveQueue(_ items: [QueueItem]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(items)
            try data.write(to: queueFileURL)
        } catch {
            print("Error saving queue: \(error)")
        }
    }
    
    public static func loadQueue() -> [QueueItem] {
        guard fileManager.fileExists(atPath: queueFileURL.path) else { return [] }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let data = try Data(contentsOf: queueFileURL)
            let items = try decoder.decode([QueueItem].self, from: data)
            return items
        } catch {
            print("Error loading queue: \(error)")
            return []
        }
    }
}
