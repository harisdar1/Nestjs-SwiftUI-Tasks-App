import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let reminderLeadTime: TimeInterval = 60 * 60 // 1 hour before deadline

    private init() {}

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    /// Schedules a reminder that fires `reminderLeadTime` seconds before the task's deadline.
    /// Does nothing if the task has no id/deadline, is already completed, or the deadline has passed.
    func scheduleDeadlineReminder(for task: TaskItem, deadline: Date) {
        guard let id = task.id, task.status != .completed else { return }

        let fireDate = deadline.addingTimeInterval(-reminderLeadTime)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task due soon"
        content.body = task.name
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: identifier(for: id), content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: id)])
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule reminder for task \(id): \(error.localizedDescription)")
            }
        }
    }

    func cancelReminder(forTaskId id: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: id)])
    }

    private func identifier(for taskId: Int) -> String {
        "task-deadline-\(taskId)"
    }
}
