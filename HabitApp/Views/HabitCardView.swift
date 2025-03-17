import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    @State private var isCompleted = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(habit.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: habit.icon)
                            .foregroundColor(Color(habit.color))
                            .font(.system(size: 24))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("连续 \(habit.streak) 天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("·")
                            .foregroundColor(.secondary)
                        
                        Text(habit.timeOfDay.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        isCompleted.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(isCompleted ? Color.clear : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 30, height: 30)
                        
                        if isCompleted {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 30, height: 30)
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
} 