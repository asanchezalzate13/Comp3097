import SwiftUI

@main
struct SmartTaskApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
