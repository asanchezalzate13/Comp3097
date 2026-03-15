//
//  TaskEntity+Extensions.swift
//  SmartTask
//
//  Created by user289899 on 3/14/26.
//

import Foundation
import CoreData

extension TaskEntity {
    
    convenience init(context: NSManagedObjectContext, title: String, dueDate: Date, type: TaskType, notes: String = "") {
        self.init(context: context)
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.taskType = type.rawValue
        self.isCompleted = false
        self.notes = notes
    }
    
    
    func toTask() -> Task {
        return Task(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            dueDate: self.dueDate ?? Date(),
            type: TaskType(rawValue: self.taskType ?? "Personal") ?? .personal,
            isCompleted: self.isCompleted,
            notes: self.notes ?? ""
        )
    }
    
    func update(from task: Task) {
        self.title = task.title
        self.dueDate = task.dueDate
        self.taskType = task.type.rawValue
        self.isCompleted = task.isCompleted
        self.notes = task.notes
    }
        
    func toggleCompletion() {
        self.isCompleted.toggle()
    }
}
