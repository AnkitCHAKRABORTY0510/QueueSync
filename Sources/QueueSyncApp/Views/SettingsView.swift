import SwiftUI
import QueueSyncCore

struct SettingsView: View {
    @State private var config = Config.load()
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Connection Settings")) {
                TextField("Host IP", text: $config.host)
                TextField("Username", text: $config.user)
                TextField("Destination Path", text: $config.destination)
            }
            
            Section(header: Text("Transfer Settings")) {
                Stepper("Max Retries: \(config.maxRetries)", value: $config.maxRetries, in: 1...10)
                TextField("SSH Key Path", text: $config.sshKeyPath)
            }
            
            Section {
                Button("Save Settings") {
                    Config.save(config)
                    showingAlert = true
                }
            }
        }
        .padding()
        .navigationTitle("Settings")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Settings Saved"), dismissButton: .default(Text("OK")))
        }
    }
}
