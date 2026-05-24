import Foundation
import UserNotifications

// local notifications for daily reminders
class NotificationService {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("notification permission error: \(error)")
            }
            print("notifications allowed: \(granted)")
        }
    }

    // TEST: fires 30 seconds after toggle — change back to 1pm calendar trigger later
    func scheduleDailyReminder(for plan: WorkoutPlan) {
        cancelDailyReminders()

        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Don't forget to complete your workout today!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(
            identifier: "daily-reminder-test",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        print("scheduled test reminder for 30 seconds from now")
    }

    func cancelDailyReminders() {
        let ids = DayPlan.DayOfWeek.allCases.map { "daily-reminder-\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        print("cancelled daily reminders")
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func weekdayNumber(for day: DayPlan.DayOfWeek) -> Int? {
        switch day {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
