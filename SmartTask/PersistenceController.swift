//
//  PersistenceController.swift
//  SmartTask
//
//  Created by user289899 on 3/14/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        for i in 0..<5 {
            let task = TaskEntity(context: viewContext)
            task.id = UUID()
            task.title = "Sample Task \(i + 1)"
            task.dueDate = Date().addingTimeInterval(TimeInterval(i * 86400)) // i days from now
            task.taskType = ["Assignment", "Quiz", "Exam", "Personal"][i % 4]
            task.isCompleted = i == 3 // Make one task completed
            task.notes = "This is a sample note for task \(i + 1)"
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SmartTask")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
