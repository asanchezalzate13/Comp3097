import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default
    )
    private var taskEntities: FetchedResults<TaskEntity>

    @State private var showAddTask = false

    private var pendingCount: Int {
        taskEntities.filter { !$0.isCompleted }.count
    }

    private var completedCount: Int {
        taskEntities.filter { $0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Tasks")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(pendingCount) pending · \(completedCount) completed")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                .padding()

                if taskEntities.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)

                        Text("No tasks yet")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Get started by adding your first task")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            showAddTask = true
                        }) {
                            Text("Add Your First Task")
                                .fontWeight(.semibold)
                                .frame(width: 220, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(taskEntities, id: \.objectID) { entity in
                            TaskRow(
                                task: entity.toTask(),
                                onToggleComplete: {
                                    toggleComplete(entity: entity)
                                },
                                onDelete: {
                                    deleteTask(entity: entity)
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                deleteTask(entity: taskEntities[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddTask) {
                AddTaskSheet()
            }
        }
    }

    private func toggleComplete(entity: TaskEntity) {
        entity.toggleCompletion()
        if let id = entity.id {
            if entity.isCompleted {
                NotificationManager.shared.cancelNotification(taskId: id)
            } else if let date = entity.dueDate, let title = entity.title {
                NotificationManager.shared.scheduleNotification(taskId: id, title: title, dueDate: date)
            }
        }
        PersistenceController.shared.save()
    }

    private func deleteTask(entity: TaskEntity) {
        if let id = entity.id {
            NotificationManager.shared.cancelNotification(taskId: id)
        }
        viewContext.delete(entity)
        PersistenceController.shared.save()
    }
}
