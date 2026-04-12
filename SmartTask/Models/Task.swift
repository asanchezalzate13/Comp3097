import Foundation

struct Task: Identifiable {
    let id: UUID
    var title: String
    var dueDate: Date
    var type: TaskType
    var isCompleted: Bool
    var notes: String

    init(id: UUID = UUID(), title: String, dueDate: Date, type: TaskType, isCompleted: Bool = false, notes: String = "") {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.type = type
        self.isCompleted = isCompleted
        self.notes = notes
    }
}
