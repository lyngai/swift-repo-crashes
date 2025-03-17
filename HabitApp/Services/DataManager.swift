import Foundation
import UserNotifications

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    
    private init() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已获取")
            } else if let error = error {
                print("获取通知权限失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - User Data Management
    
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    func loadUser() -> User? {
        guard let userData = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            return nil
        }
        return user
    }
    
    func clearUserData() {
        userDefaults.removeObject(forKey: userKey)
    }
    
    // MARK: - Notification Management
    
    func scheduleHabitReminder(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "习惯提醒"
        content.body = "该完成今天的\(habit.name)啦！"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString,
                                          content: content,
                                          trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("设置提醒失败: \(error.localizedDescription)")
            }
        }
    }
    
    func removeHabitReminder(for habit: Habit) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
    
    func removeAllHabitReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
} 