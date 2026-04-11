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
    @State private var taskToEdit: Task? = nil
    @State private var navigationPath = NavigationPath()

    private var pendingCount: Int {
        taskEntities.filter { !$0.isCompleted }.count
    }

    private var completedCount: Int {
        taskEntities.filter { $0.isCompleted }.count
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            mainColumn
                .navigationDestination(for: UUID.self) { taskId in
                    detailView(for: taskId)
                }
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showAddTask) {
                    AddTaskSheet()
                }
                .sheet(item: $taskToEdit) { task in
                    editSheetContent(for: task)
                }
        }
    }

    private var mainColumn: some View {
        VStack(spacing: 0) {
            headerBar
            if taskEntities.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
    }

    private var headerBar: some View {
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
    }

    private var emptyState: some View {
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
    }

    private var taskList: some View {
        List {
            ForEach(Array(taskEntities), id: \.objectID) { entity in
                taskRow(entity: entity)
            }
        }
        .listStyle(.plain)
    }

    private func taskBinding(for entity: TaskEntity) -> Binding<Task> {
        Binding(
            get: { entity.toTask() },
            set: { new in
                entity.update(from: new)
                PersistenceController.shared.save()
            }
        )
    }

    private func taskRow(entity: TaskEntity) -> some View {
        let task = entity.toTask()
        return HStack(alignment: .top, spacing: 0) {
            Button {
                navigationPath.append(task.id)
            } label: {
                TaskRow(task: task)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                entity.isCompleted.toggle()
                PersistenceController.shared.save()
            } label: {
                Image(systemName: entity.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(entity.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
        }
        .padding(.vertical, 8)
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .background(Color(.systemBackground))
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.secondarySystemGroupedBackground))
        .swipeActions(edge: .trailing) {
            Button {
                taskToEdit = entity.toTask()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    @ViewBuilder
    private func detailView(for taskId: UUID) -> some View {
        if let entity = taskEntities.first(where: { $0.id == taskId }) {
            TaskDetailView(
                task: taskBinding(for: entity),
                onDelete: {
                    viewContext.delete(entity)
                    PersistenceController.shared.save()
                }
            )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func editSheetContent(for task: Task) -> some View {
        if let entity = taskEntities.first(where: { $0.id == task.id }) {
            EditTaskSheet(task: taskBinding(for: entity))
        } else {
            EmptyView()
        }
    }
}

#Preview {
    TaskListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
