import Foundation
import Combine

class HabitViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var habits: [Habit] = []
    @Published var selectedDate: Date = Date()
    
    private let dataManager = DataManager.shared
    
    init() {
        loadUser()
        if habits.isEmpty {
            // 添加示例数据
            habits = [
                Habit(name: "晨间冥想", icon: "sun.max.fill", color: "orange", timeOfDay: .morning),
                Habit(name: "读书半小时", icon: "book.fill", color: "blue", timeOfDay: .afternoon),
                Habit(name: "晚间复盘", icon: "moon.stars.fill", color: "purple", timeOfDay: .evening)
            ]
            saveHabits()
        }
        {

    }
    
    // MARK: - User Management
    
    func loadUser() {
        currentUser = dataManager.loadUser()
        habits = currentUser?.habits ?? []
    }
    
    func login(phoneNumber: String, nickname: String) {
        let user = User(phoneNumber: phoneNumber, nickname: nickname)
        currentUser = user
        dataManager.saveUser(user)
    }
    
    func logout() {
        currentUser = nil
        habits = []
        dataManager.removeAllHabitReminders()
        dataManager.clearUserData()
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        if habit.reminderTime != nil {
            dataManager.scheduleHabitReminder(for: habit)
        }
        saveHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        dataManager.removeHabitReminder(for: habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let oldHabit = habits[index]
            habits[index] = habit
            
            // 更新提醒
            dataManager.removeHabitReminder(for: oldHabit)
            if habit.reminderTime != nil {
                dataManager.scheduleHabitReminder(for: habit)
            }
            
            saveHabits()
        }
    }
    
    func markHabitAsCompleted(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            updatedHabit.markAsCompleted(for: selectedDate)
            habits[index] = updatedHabit
            saveHabits()
        }
    }
    
    // MARK: - Statistics
    
    func getCompletionRate(for habit: Habit, days: Int = 30) -> Double {
        return habit.completionRate(for: days)
    }
    
    func getOverallCompletionRate(days: Int = 30) -> Double {
        return currentUser?.getCompletionRate(for: days) ?? 0
    }
    
    // MARK: - Private Methods
    
    private func saveHabits() {
        guard var user = currentUser else { return }
        user.habits = habits
        currentUser = user
        dataManager.saveUser(user)
    }
} 