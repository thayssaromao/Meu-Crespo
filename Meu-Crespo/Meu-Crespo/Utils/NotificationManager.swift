import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let identifiers = ["dailyMorning", "dailyEvening"]

    func requestPermissionIfNeeded(thenSchedule schedule: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    if granted && schedule {
                        DispatchQueue.main.async { self?.scheduleDailyNotification() }
                    }
                }
            case .authorized, .provisional:
                if schedule {
                    DispatchQueue.main.async { self?.scheduleDailyNotification() }
                }
            default:
                break
            }
        }
    }

    func scheduleDailyNotification() {
        // Read localized strings on main thread before entering UNUserNotificationCenter
        let title = L("notification.title")
        let body  = L("notification.body")

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        schedule(identifier: "dailyMorning", hour: 9,  minute: 0, title: title, body: body, to: center)
        schedule(identifier: "dailyEvening", hour: 17, minute: 0, title: title, body: body, to: center)
    }

    func scheduleIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else { return }
            DispatchQueue.main.async { self?.scheduleDailyNotification() }
        }
    }

    private func schedule(identifier: String, hour: Int, minute: Int,
                          title: String, body: String,
                          to center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }
}
