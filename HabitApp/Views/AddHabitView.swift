import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var selectedFrequency = Habit.Frequency.daily
    @State private var selectedTimeOfDay = Habit.TimeOfDay.anytime
    @State private var isReminderEnabled = false
    @State private var reminderTime = Date()
    
    private let icons = [
        "star.fill", "sun.max.fill", "moon.stars.fill", "book.fill",
        "heart.fill", "leaf.fill", "flame.fill", "drop.fill",
        "bolt.fill", "crown.fill", "flag.fill", "target"
    ]
    
    private let colors = [
        "blue", "purple", "orange", "green",
        "red", "pink", "teal", "indigo"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("习惯名称", text: $name)
                    
                    Picker("频率", selection: $selectedFrequency) {
                        ForEach(Habit.Frequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    
                    Picker("时间段", selection: $selectedTimeOfDay) {
                        ForEach(Habit.TimeOfDay.allCases, id: \.self) { timeOfDay in
                            Text(timeOfDay.rawValue).tag(timeOfDay)
                        }
                    }
                }
                
                Section(header: Text("提醒设置")) {
                    Toggle("启用每日提醒", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker("提醒时间",
                                 selection: $reminderTime,
                                 displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(icon == selectedIcon ? Color(selectedColor) : .gray)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(icon == selectedIcon ? Color(selectedColor).opacity(0.2) : Color.clear)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: color == selectedColor ? 2 : 0)
                                )
                                .shadow(color: color == selectedColor ? Color(color).opacity(0.5) : .clear,
                                       radius: 5)
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("添加新习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        let habit = Habit(
                            name: name,
                            icon: selectedIcon,
                            color: selectedColor,
                            frequency: selectedFrequency,
                            timeOfDay: selectedTimeOfDay,
                            reminderTime: isReminderEnabled ? reminderTime : nil
                        )
                        habitViewModel.addHabit(habit)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 