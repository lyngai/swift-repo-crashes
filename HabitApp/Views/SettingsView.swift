import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Palm 生物识别设置
                PalmSettingsView()
                
                // 系统设置部分
                Section {
                    NavigationLink {
                        Text("通知设置")
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("通知设置")
                        }
                    }
                    
                    NavigationLink {
                        Text("数据备份")
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.icloud.fill")
                                .foregroundColor(.green)
                            Text("数据备份")
                        }
                    }
                } header: {
                    Text("系统设置")
                }
                
                // 退出登录部分
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("退出登录")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
        .alert("确认退出", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                habitViewModel.logout()
            }
        } message: {
            Text("退出后需要重新登录才能继续使用")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitViewModel())
} 