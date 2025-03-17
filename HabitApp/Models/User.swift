import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var phoneNumber: String
    var nickname: String
    var avatar: String?
    var habits: [Habit]
    var friends: [UUID]
    var createdAt: Date
    
    init(id: UUID = UUID(), phoneNumber: String, nickname: String, avatar: String? = nil, habits: [Habit] = []) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.nickname = nickname
        self.avatar = avatar
        self.habits = habits
        self.friends = []
        self.createdAt = Date()
    }
    
    mutating func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    mutating func removeHabit(withId id: UUID) {
        habits.removeAll { $0.id == id }
    }
    
    mutating func addFriend(_ friendId: UUID) {
        if !friends.contains(friendId) {
            friends.append(friendId)
        }
    }
    
    mutating func removeFriend(_ friendId: UUID) {
        friends.removeAll { $0 == friendId }
    }
    
    func getCompletionRate(for days: Int = 30) -> Double {
        guard !habits.isEmpty else { return 0 }
        let totalRate = habits.reduce(0.0) { $0 + $1.completionRate(for: days) }
        return totalRate / Double(habits.count)
    }
} 