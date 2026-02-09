import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    
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
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        
        print("=== UI-ONLY: Task would be saved ===")
        print("Title: \(trimmedTitle)")
        print("Due Date: \(dueDate)")
        print("Type: \(selectedType.displayName)")
        print("Notes: \(notes)")
        print("=====================================")
        
        dismiss()
    }
}
