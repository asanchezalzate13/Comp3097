import XCTest
@testable import SmartTask

final class SmartTaskTests: XCTestCase {

    // MARK: - TaskType Tests

    func testTaskTypeRawValues() {
        XCTAssertEqual(TaskType.assignment.rawValue, "Assignment")
        XCTAssertEqual(TaskType.quiz.rawValue, "Quiz")
        XCTAssertEqual(TaskType.exam.rawValue, "Exam")
        XCTAssertEqual(TaskType.personal.rawValue, "Personal")
    }

    func testTaskTypeDisplayName() {
        XCTAssertEqual(TaskType.assignment.displayName, "Assignment")
        XCTAssertEqual(TaskType.quiz.displayName, "Quiz")
    }

    func testTaskTypeAllCasesCount() {
        XCTAssertEqual(TaskType.allCases.count, 4)
    }

    // MARK: - Task Model Tests

    func testTaskDefaultValues() {
        let task = Task(title: "Test Task", dueDate: Date(), type: .assignment)
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(task.notes, "")
    }

    func testTaskIsOverdue() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let task = Task(title: "Overdue Task", dueDate: pastDate, type: .assignment)
        XCTAssertTrue(task.dueDate < Date())
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskIsDueSoon() {
        let soonDate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let task = Task(title: "Due Soon Task", dueDate: soonDate, type: .quiz)
        let hoursUntilDue = task.dueDate.timeIntervalSince(Date()) / 3600
        XCTAssertTrue(hoursUntilDue <= 24)
    }

    func testTaskCompletionToggle() {
        var task = Task(title: "Test", dueDate: Date(), type: .personal)
        XCTAssertFalse(task.isCompleted)
        task.isCompleted.toggle()
        XCTAssertTrue(task.isCompleted)
        task.isCompleted.toggle()
        XCTAssertFalse(task.isCompleted)
    }

    // MARK: - Core Data Tests

    func testCoreDataTaskEntityCreation() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let entity = TaskEntity(
            context: context,
            title: "Test Entity",
            dueDate: Date(),
            type: .assignment,
            notes: "Some notes"
        )

        XCTAssertEqual(entity.title, "Test Entity")
        XCTAssertEqual(entity.taskType, "Assignment")
        XCTAssertFalse(entity.isCompleted)
        XCTAssertNotNil(entity.id)
    }

    func testCoreDataToTaskConversion() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let entity = TaskEntity(
            context: context,
            title: "Convert Me",
            dueDate: Date(),
            type: .exam,
            notes: "Notes here"
        )

        let task = entity.toTask()
        XCTAssertEqual(task.title, "Convert Me")
        XCTAssertEqual(task.type, .exam)
        XCTAssertEqual(task.notes, "Notes here")
        XCTAssertFalse(task.isCompleted)
    }

    func testCoreDataToggleCompletion() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let entity = TaskEntity(
            context: context,
            title: "Toggle Test",
            dueDate: Date(),
            type: .personal
        )

        XCTAssertFalse(entity.isCompleted)
        entity.toggleCompletion()
        XCTAssertTrue(entity.isCompleted)
        entity.toggleCompletion()
        XCTAssertFalse(entity.isCompleted)
    }
}
