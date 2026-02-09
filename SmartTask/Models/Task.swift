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

extension Task {
    static var sampleTasks: [Task] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Task(
                title: "Mobile App Development Assignment",
                dueDate: calendar.date(byAdding: .day, value: -2, to: now)!, //Overdue (red)
                type: .assignment,
                isCompleted: false,
                notes: "Complete the UI design milestone"
            ),
            Task(
                title: "Database Systems Quiz",
                dueDate: calendar.date(byAdding: .hour, value: 6, to: now)!, //Due soon (yellow)
                type: .quiz,
                isCompleted: false,
                notes: "Study chapters 5-7"
            ),
            Task(
                title: "Data Structures Midterm",
                dueDate: calendar.date(byAdding: .day, value: 5, to: now)!, //Normal (gray)
                type: .exam,
                isCompleted: false,
                notes: "Review all lecture notes and practice problems"
            ),
            Task(
                title: "Submit Project Proposal",
                dueDate: calendar.date(byAdding: .day, value: -5, to: now)!,
                type: .assignment,
                isCompleted: true,                        //Completed (green)
                notes: "Group project proposal submitted"
            ),
            Task(
                title: "Gym Workout",
                dueDate: calendar.date(byAdding: .day, value: 1, to: now)!,
                type: .personal,
                isCompleted: false,
                notes: "Upper body day"
            )
        ]
    }
}
