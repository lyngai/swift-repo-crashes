import SwiftUI

struct MainTabView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("习惯", systemImage: "list.bullet")
                }
            
            StatsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
        .environmentObject(habitViewModel)
    }
} 