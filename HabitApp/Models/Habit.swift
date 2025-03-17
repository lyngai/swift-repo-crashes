import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var frequency: Frequency
    var timeOfDay: TimeOfDay
    var streak: Int
    var lastCompletedDate: Date?
    var reminderTime: Date?
    var createdAt: Date
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "每天"
        case weekly = "每周"
        case monthly = "每月"
    }
    
    enum TimeOfDay: String, Codable, CaseIterable {
        case morning = "清晨"
        case afternoon = "午后"
        case evening = "夜晚"
        case anytime = "随时"
    }
    
    init(id: UUID = UUID(), name: String, icon: String = "star.fill", color: String = "blue", 
         frequency: Frequency = .daily, timeOfDay: TimeOfDay = .anytime, 
         streak: Int = 0, lastCompletedDate: Date? = nil, reminderTime: Date? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.timeOfDay = timeOfDay
        self.streak = streak
        self.lastCompletedDate = lastCompletedDate
        self.reminderTime = reminderTime
        self.createdAt = Date()
    }
    
    mutating func markAsCompleted(for date: Date = Date()) {
        lastCompletedDate = date
        streak += 1
    }
    
    func isCompleted(for date: Date = Date()) -> Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDate(lastCompleted, inSameDayAs: date)
    }
    
    func completionRate(for days: Int = 30) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return 0
        }
        
        var date = startDate
        var completedDays = 0
        
        while date <= endDate {
            if isCompleted(for: date) {
                completedDays += 1
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return Double(completedDays) / Double(days)
    }
} 