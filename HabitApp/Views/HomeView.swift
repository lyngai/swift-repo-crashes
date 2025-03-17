import SwiftUI

struct HomeView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingAddHabit = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 日期选择器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(-6...6, id: \.self) { offset in
                                let date = calendar.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                                DateButton(date: date,
                                         isSelected: calendar.isDate(date, inSameDayAs: habitViewModel.selectedDate),
                                         dateFormatter: dateFormatter,
                                         weekdayFormatter: weekdayFormatter) {
                                    habitViewModel.selectedDate = date
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 习惯列表
                    LazyVStack(spacing: 15) {
                        ForEach(habitViewModel.habits) { habit in
                            HabitCard(habit: habit)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("今日习惯")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let dateFormatter: DateFormatter
    let weekdayFormatter: DateFormatter
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(weekdayFormatter.string(from: date))
                    .font(.caption)
                Text(dateFormatter.string(from: date))
                    .font(.title3)
                    .bold()
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(width: 45, height: 70)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(10)
        }
    }
}

struct HabitCard: View {
    let habit: Habit
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(habit.color).opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: habit.icon)
                            .foregroundColor(Color(habit.color))
                    )
                
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                    Text(habit.timeOfDay.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if habit.isCompleted(for: habitViewModel.selectedDate) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Button(action: { habitViewModel.markHabitAsCompleted(habit) }) {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: habit.completionRate())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(habit.color)))
                
                Text("已坚持 \(habit.streak) 天")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 