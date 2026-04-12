import Foundation

enum TaskType: String, CaseIterable, Codable {
    case assignment = "Assignment"
    case quiz = "Quiz"
    case exam = "Exam"
    case personal = "Personal"
    
     var displayName: String { rawValue }
}

