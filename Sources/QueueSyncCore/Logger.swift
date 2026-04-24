import Foundation

public struct Logger {
    public static var logFileURL: URL {
        return Storage.dataDirectoryURL.appendingPathComponent("logs.txt")
    }
    
    public static func log(event: String, filename: String, details: String = "") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = formatter.string(from: Date())
        
        let detailString = details.isEmpty ? "" : " \(details)"
        let logLine = "\(timestamp)  \(event.padding(toLength: 10, withPad: " ", startingAt: 0)) \(filename)\(detailString)\n"
        
        // Ensure file exists
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: logFileURL.path) {
            fileManager.createFile(atPath: logFileURL.path, contents: Data())
        }
        
        // Append to file
        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            fileHandle.seekToEndOfFile()
            if let data = logLine.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
    }
    
    public static func printLogs() {
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let content = try? String(contentsOf: logFileURL, encoding: .utf8) {
                print(content)
            } else {
                print("Error reading logs.")
            }
        } else {
            print("No logs found.")
        }
    }
}
