import SwiftUI
import QueueSyncCore
import UniformTypeIdentifiers

struct MainView: View {
    @EnvironmentObject var queueManager: QueueManager
    @State private var selectedTab: String? = "Queue"
    
    var body: some View {
        NavigationView {
            // Sidebar
            List {
                NavigationLink(destination: QueueListView(), tag: "Queue", selection: $selectedTab) {
                    Label("Queue", systemImage: "tray.full.fill")
                }
                NavigationLink(destination: LogsView(), tag: "Logs", selection: $selectedTab) {
                    Label("Logs", systemImage: "doc.text.fill")
                }
                NavigationLink(destination: SettingsView(), tag: "Settings", selection: $selectedTab) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            
            // Default View
            QueueListView()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct QueueListView: View {
    @EnvironmentObject var queueManager: QueueManager
    @State private var isSyncing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Queue")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Spacer()
                
                Button(action: addFile) {
                    Label("Add File", systemImage: "plus")
                }
                
                Button(action: { queueManager.clear() }) {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(queueManager.items.filter { $0.status == .completed || $0.status == .failed }.isEmpty)
                
                Button(action: startSync) {
                    Label(isSyncing ? "Syncing..." : "Start Sync", systemImage: "play.fill")
                }
                .accentColor(.green)
                .disabled(isSyncing || queueManager.items.filter { $0.status == .pending }.isEmpty)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
            
            // List
            if queueManager.items.isEmpty {
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding()
                    Text("Your queue is empty")
                        .font(.headline)
                    Text("Drag and drop files here or click '+' to add")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(queueManager.items, id: \.id) { item in
                        QueueRowView(item: item)
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(.inset)
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { item, _ in
                    if let url = item {
                        DispatchQueue.main.async {
                            queueManager.add(path: url.path)
                        }
                    }
                }
            }
            return true
        }
    }
    
    private func addFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                queueManager.add(path: url.path)
            }
        }
    }
    
    private func startSync() {
        isSyncing = true
        let transferManager = TransferManager(queueManager: queueManager)
        
        // Run in background thread
        DispatchQueue.global(qos: .userInitiated).async {
            transferManager.start()
            DispatchQueue.main.async {
                isSyncing = false
            }
        }
    }
}

struct LogsView: View {
    @State private var logContent = "Loading logs..."
    
    var body: some View {
        ScrollView {
            Text(logContent)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Transfer Logs")
        .onAppear {
            let logURL = Storage.dataDirectoryURL.appendingPathComponent("logs.txt")
            if let content = try? String(contentsOf: logURL) {
                logContent = content
            } else {
                logContent = "No logs found."
            }
        }
    }
}
