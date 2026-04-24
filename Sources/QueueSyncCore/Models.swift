import Foundation

public enum TransferStatus: String, Codable {
    case pending
    case transferring
    case completed
    case failed
    case paused
    case retrying
}

public struct QueueItem: Codable {
    public let id: String
    public let path: String
    public let type: String // "file" | "folder"
    public var status: TransferStatus
    public var progress: Double
    public var retries: Int
    public let createdAt: Date
    public var startedAt: Date?
    public var finishedAt: Date?
    
    public init(id: String = UUID().uuidString, path: String, type: String, status: TransferStatus = .pending, progress: Double = 0, retries: Int = 0, createdAt: Date = Date(), startedAt: Date? = nil, finishedAt: Date? = nil) {
        self.id = id
        self.path = path
        self.type = type
        self.status = status
        self.progress = progress
        self.retries = retries
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.finishedAt = finishedAt
    }
}

