//
//  NotificationManager.swift
//  SmartTask
//
//  Handles local notifications for task due-date reminders.
//

import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Request authorization for local notifications. Call at app launch.
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    /// Schedule a local notification at the task's due date.
    func scheduleNotification(taskId: UUID, title: String, dueDate: Date) {
        cancelNotification(taskId: taskId)
        guard dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task due"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task-\(taskId.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Cancel the notification for a task (e.g. when deleted or marked completed).
    func cancelNotification(taskId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task-\(taskId.uuidString)"]
        )
    }
}
