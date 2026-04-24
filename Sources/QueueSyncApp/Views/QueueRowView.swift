import SwiftUI
import QueueSyncCore

struct QueueRowView: View {
    @EnvironmentObject var queueManager: QueueManager
    let item: QueueItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.type == "folder" ? "folder.fill" : "doc.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text((item.path as NSString).lastPathComponent)
                    .font(.headline)
                
                HStack {
                    Text(item.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    if item.status == .transferring {
                        ProgressView(value: item.progress, total: 100)
                            .progressViewStyle(.linear)
                            .frame(width: 100)
                        Text("\(Int(item.progress))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if item.status == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if item.status == .failed {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            }
            
            Button(action: {
                queueManager.remove(id: item.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch item.status {
        case .pending: return .secondary
        case .transferring: return .blue
        case .completed: return .green
        case .failed: return .red
        case .retrying: return .orange
        case .paused: return .gray
        }
    }
}
