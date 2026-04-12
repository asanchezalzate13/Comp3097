//
//  TaskDetailView.swift
//  SmartTask
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var task: Task
    var onDelete: () -> Void
    var onBack: () -> Void

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    private static let primaryPurple = Color(red: 0.36, green: 0.26, blue: 0.95)

    private var overdueDayCount: Int? {
        guard !task.isCompleted, task.dueDate < Date() else { return nil }
        let cal = Calendar.current
        let start = cal.startOfDay(for: task.dueDate)
        let end = cal.startOfDay(for: Date())
        return cal.dateComponents([.day], from: start, to: end).day
    }

    private var isDueSoon: Bool {
        guard !task.isCompleted, task.dueDate >= Date() else { return false }
        let hours = task.dueDate.timeIntervalSince(Date()) / 3600
        return hours <= 24
    }

    private var formattedDueDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f.string(from: task.dueDate)
    }

    private var descriptionText: String {
        let t = task.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "No description" : t
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerGradient
                contentCard
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditSheet) {
            EditTaskSheet(task: $task)
        }
        .alert("Delete task?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                NotificationManager.shared.cancelNotification(taskId: task.id)
                onDelete()
                onBack()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var headerGradient: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    Self.primaryPurple,
                    Color(red: 0.45, green: 0.35, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)

            VStack(alignment: .leading, spacing: 12) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)  // ← bigger tap target
                        .contentShape(Rectangle())       // ← makes full area tappable
                }
                .accessibilityLabel("Back")
                .zIndex(1)                               // ← ensure it's on top

                Text(task.title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    if let days = overdueDayCount {
                        Text("Overdue by \(days) day\(days == 1 ? "" : "s")")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.25))
                            .foregroundStyle(Color.red.opacity(0.95))
                            .clipShape(Capsule())
                    } else if isDueSoon {
                        Text("Due Soon")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    Text(task.type.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.22))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 56)    // ← push content below the safe area / status bar
            .padding(.bottom, 24)
        }
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            detailRow(icon: "calendar", label: "Due Date", value: formattedDueDate)
            detailRow(icon: "tag.fill", label: "Task Type", value: task.type.displayName)

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(descriptionText)
                    .font(.body)
                    .foregroundStyle(descriptionText == "No description" ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            statusCard

            HStack(spacing: 12) {
                Button {
                    showEditSheet = true
                } label: {
                    Label("Edit Task", systemImage: "pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Self.primaryPurple)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.headline)
                        .frame(width: 56, height: 52)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .accessibilityLabel("Delete")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        )
        .padding(.horizontal, 16)
        .offset(y: -28)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Self.primaryPurple)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.semibold))
            }
        }
    }

    private var statusCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Task Status")
                    .font(.headline)
                Text(task.isCompleted ? "Completed" : "Mark as complete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                task.isCompleted.toggle()
                if task.isCompleted {
                    NotificationManager.shared.cancelNotification(taskId: task.id)
                } else {
                    NotificationManager.shared.scheduleNotification(
                        taskId: task.id,
                        title: task.title,
                        dueDate: task.dueDate
                    )
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                    Text(task.isCompleted ? "Mark Incomplete" : "Mark Complete")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(task.isCompleted ? Color.orange.opacity(0.9) : Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: .constant(Task(
                title: "Mobile App Assignment",
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                type: .assignment,
                notes: "Complete the UI design milestone"
            )),
            onDelete: {},
            onBack: {}
        )
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
