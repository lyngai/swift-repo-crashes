import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "今年"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if habitViewModel.habits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("还没有任何习惯数据")
                            .font(.headline)
                        Text("添加一些习惯，开始追踪你的进步吧")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 100)
                } else {
                    VStack(spacing: 20) {
                        // 总体完成率卡片
                        VStack(alignment: .leading, spacing: 16) {
                            Text("总体完成率")
                                .font(.headline)
                            
                            HStack(alignment: .bottom) {
                                Text("\(Int(habitViewModel.getOverallCompletionRate(days: selectedTimeRange.days) * 100))%")
                                    .font(.system(size: 36, weight: .bold))
                                Text("完成度")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 8)
                                
                                Spacer()
                                
                                Picker("时间范围", selection: $selectedTimeRange) {
                                    ForEach(TimeRange.allCases, id: \.self) { range in
                                        Text(range.rawValue).tag(range)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // 完成情况概览
                            HStack(spacing: 20) {
                                StatBox(
                                    title: "习惯总数",
                                    value: "\(habitViewModel.habits.count)",
                                    icon: "list.bullet",
                                    color: .blue
                                )
                                
                                StatBox(
                                    title: "最长连续",
                                    value: "\(habitViewModel.habits.map { $0.streak }.max() ?? 0)天",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatBox(
                                    title: "今日完成",
                                    value: "\(habitViewModel.habits.filter { $0.isCompleted() }.count)/\(habitViewModel.habits.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // 习惯列表
                        LazyVStack(spacing: 15) {
                            ForEach(habitViewModel.habits.sorted { $0.streak > $1.streak }) { habit in
                                HabitStatsCard(habit: habit, timeRange: selectedTimeRange)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("统计分析")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct HabitStatsCard: View {
    let habit: Habit
    let timeRange: StatsView.TimeRange
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
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("连续坚持 \(habit.streak) 天")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(habitViewModel.getCompletionRate(for: habit, days: timeRange.days) * 100))%")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color(habit.color))
                    Text(timeRange.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(habit.color))
                        .frame(width: geometry.size.width * CGFloat(habitViewModel.getCompletionRate(for: habit, days: timeRange.days)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // 时间段分布热图
            VStack(alignment: .leading, spacing: 4) {
                Text("完成情况")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(0..<min(timeRange.days, 28), id: \.self) { day in
                        let date = Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date()
                        Rectangle()
                            .fill(habit.isCompleted(for: date) ? Color(habit.color) : Color(.systemGray5))
                            .frame(height: 20)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(HabitViewModel())
} 