import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied with error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for medication: Medication) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take your \(medication.name) - \(medication.dose)"
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: medication.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: medication.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func updateNotificationSettings(enabled: Bool) {
        if enabled {
            // Re-schedule all notifications as per the existing medications or settings
            // This might require maintaining a list or re-fetching from saved data
            // Placeholder to reschedule all medications (you'll need to implement the actual logic)
            print("Notifications Enabled")
        } else {
            // Remove all scheduled notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("Notifications Disabled")
        }
    }

    func addNotificationActions() {
        let markAsTakenAction = UNNotificationAction(identifier: "MARK_AS_TAKEN", title: "Mark as Taken", options: .foreground)
        let category = UNNotificationCategory(identifier: "MEDICATION", actions: [markAsTakenAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
