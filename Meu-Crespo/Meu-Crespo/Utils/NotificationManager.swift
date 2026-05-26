import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermissionIfNeeded(thenSchedule schedule: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    if granted && schedule { self.scheduleDailyNotification() }
                }
            case .authorized, .provisional:
                if schedule { self.scheduleDailyNotification() }
            default:
                break
            }
        }
    }

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMorning"])

        let content = UNMutableNotificationContent()
        content.title = L("notification.title")
        content.body  = L("notification.body")
        content.sound = .default

        var components = DateComponents()
        components.hour   = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyMorning", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMorning"])
    }

    func scheduleSmartDailyNotification(treatment: String, humidity: String) {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 9; comps.minute = 0
        guard let fireDate = Calendar.current.date(from: comps), fireDate > Date() else { return }
        _ = fireDate

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMorning"])

        let content = UNMutableNotificationContent()
        content.title = L("notification.smart.title")
        content.body  = String(format: L("notification.smart.body"), treatment, humidity)
        content.sound = .default

        var triggerComps = DateComponents()
        triggerComps.hour = 9; triggerComps.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: true)
        center.add(UNNotificationRequest(identifier: "dailyMorning", content: content, trigger: trigger))
    }
    
    func TESTscheduleSmartDailyNotification(treatment: String, humidity: String) {
        // TEST MODE: fires 5 seconds after data loads (remove this block and restore calendar trigger for production)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyMorning"])

        let content = UNMutableNotificationContent()
        content.title = L("notification.smart.title")
        content.body  = String(format: L("notification.smart.body"), treatment, humidity)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        center.add(UNNotificationRequest(identifier: "dailyMorning", content: content, trigger: trigger))
    }
}
