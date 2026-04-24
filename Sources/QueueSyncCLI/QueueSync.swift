import Foundation
import QueueSyncCore

@main
public struct QueueSync {
    public static func main() {
        let args = CommandLine.arguments
        
        // Ensure there is at least one argument passed (the command itself)
        guard args.count > 1 else {
            printUsage()
            exit(1)
        }
        
        let command = args[1]
        let manager = QueueManager()
        
        switch command {
        case "add":
            guard args.count > 2 else {
                print("Error: Missing path argument for 'add' command.")
                exit(1)
            }
            let path = args[2]
            manager.add(path: path)
            
        case "list":
            manager.list()
            
        case "start":
            let transferManager = TransferManager(queueManager: manager)
            transferManager.start()
            
        case "clear":
            manager.clear()
            
        case "logs":
            Logger.printLogs()
            
        case "config":
            guard args.count > 2, args[2] == "set", args.count > 4 else {
                print("Usage: queuesync config set <key> <value>")
                exit(1)
            }
            let key = args[3]
            let value = args[4]
            var config = Config.load()
            
            switch key {
            case "host": config.host = value
            case "user": config.user = value
            case "dest": config.destination = value
            case "sshKeyPath": config.sshKeyPath = value
            default:
                print("Unknown config key. Supported: host, user, dest, sshKeyPath")
                exit(1)
            }
            Config.save(config)
            print("Config updated: \(key) = \(value)")
            
        default:
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    }
    
    static func printUsage() {
        print("""
        QueueSync Engine
        Usage:
          queuesync add <path>   Add file or folder to queue
          queuesync list         Display all queue items
          queuesync start        Start sequential transfer worker
          queuesync logs         Print recent log entries
          queuesync clear        Remove completed items from queue
        """)
    }
}
