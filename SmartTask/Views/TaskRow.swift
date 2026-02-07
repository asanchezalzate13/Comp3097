import SwiftUI

/// A single task row with color-coded left border:
/// - Red: Overdue (past due date)
/// - Yellow: Due within 24 hours
/// - Green: Completed
struct TaskRow: View {
    let task: Task
    let onToggleComplete: () -> Void
    let onDelete: () -> Void
    
    private var borderColor: Color {
        if task.isCompleted {
            return .green
        }
        let now = Date()
        if task.dueDate < now {
            return .red    //overdue
        }
        let hoursUntilDue = task.dueDate.timeIntervalSince(now) / 3600
        if hoursUntilDue <= 24 {
            return .yellow //Due soon (within 24 hours)
        }
        return .gray       // Default/not urgent
    }
    
    private var dueText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: task.dueDate)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(borderColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .secondary)
                
                Text(dueText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(task.type.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                onToggleComplete()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }
}
