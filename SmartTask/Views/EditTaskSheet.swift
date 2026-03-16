import SwiftUI
import CoreData

struct EditTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var task: Task

    @State private var title = ""
    @State private var dueDate = Date()
    @State private var selectedType: TaskType = .assignment
    @State private var notes = ""

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)

                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])

                    Picker("Type", selection: $selectedType) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                // Pre-fill fields with the existing task's values
                title        = task.title
                dueDate      = task.dueDate
                selectedType = task.type
                notes        = task.notes
            }
        }
    }

    // MARK: - Save to Core Data

    // MARK: - Save changes

    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        // Update the binding so the list reflects changes immediately
        task.title   = trimmedTitle
        task.dueDate = dueDate
        task.type    = selectedType
        task.notes   = notes

        // Also persist to Core Data
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        request.fetchLimit = 1

        do {
            let results = try viewContext.fetch(request)
            if let entity = results.first {
                entity.title    = trimmedTitle
                entity.dueDate  = dueDate
                entity.taskType = selectedType.rawValue
                entity.notes    = notes
                PersistenceController.shared.save()
            }
        } catch {
            print("Failed to fetch task for editing: \(error)")
        }

        dismiss()
    }
}