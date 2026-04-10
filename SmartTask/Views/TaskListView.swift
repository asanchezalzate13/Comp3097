import SwiftUI

struct TaskListView: View {
    //mock data for ui display
    @State private var tasks = Task.sampleTasks
    @State private var showAddTask = false
    @State private var taskToEdit: Task? = nil

    private var pendingCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    private var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
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

                if tasks.isEmpty {
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
                        ForEach(tasks) { task in
                            TaskRow(
                                task: task,
                                onToggleComplete: {
                                    print("Toggle completion tapped for: \(task.title)")
                                },
                                onDelete: {
                                    print("Delete tapped for: \(task.title)")
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                            .swipeActions(edge: .trailing) {
                                Button {
                                    taskToEdit = task
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
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
            .sheet(item: $taskToEdit) { task in
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    EditTaskSheet(task: $tasks[index])
                }
            }
        }
    }
}