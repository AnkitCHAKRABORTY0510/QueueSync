import Foundation

public struct Config: Codable {
    public var host: String
    public var user: String
    public var destination: String
    public var sshKeyPath: String
    public var maxRetries: Int
    
    public init(host: String = "", user: String = "", destination: String = "", sshKeyPath: String = "~/.ssh/id_rsa", maxRetries: Int = 3) {
        self.host = host
        self.user = user
        self.destination = destination
        self.sshKeyPath = sshKeyPath
        self.maxRetries = maxRetries
    }
    
    static var configFileURL: URL {
        return Storage.dataDirectoryURL.appendingPathComponent("config.json")
    }
    
    public static func load() -> Config {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: configFileURL.path) else {
            return Config()
        }
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: configFileURL)
            return try decoder.decode(Config.self, from: data)
        } catch {
            print("Error loading config: \\(error)")
            return Config()
        }
    }
    
    public static func save(_ config: Config) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(config)
            try data.write(to: configFileURL)
        } catch {
            print("Error saving config: \\(error)")
        }
    }
}
