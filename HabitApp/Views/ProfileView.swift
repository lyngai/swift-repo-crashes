import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habitViewModel.currentUser?.nickname ?? "未登录")
                                .font(.headline)
                            Text(habitViewModel.currentUser?.phoneNumber ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingEditProfile = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 统计信息
                Section(header: Text("统计")) {
                    HStack {
                        Text("习惯总数")
                        Spacer()
                        Text("\(habitViewModel.habits.count)")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("总体完成率")
                        Spacer()
                        Text("\(Int(habitViewModel.getOverallCompletionRate() * 100))%")
                            .foregroundColor(.gray)
                    }
                }
                
                // 设置
                Section(header: Text("设置")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingRow(icon: "bell.fill", title: "通知设置")
                    }
                    
                    NavigationLink(destination: ThemeSettingsView()) {
                        SettingRow(icon: "paintbrush.fill", title: "主题设置")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        SettingRow(icon: "info.circle.fill", title: "关于我们")
                    }
                }
                
                // 退出登录
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        Text("退出登录")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("个人中心")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("退出登录"),
                message: Text("确定要退出登录吗？"),
                primaryButton: .destructive(Text("退出")) {
                    habitViewModel.logout()
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            Text(title)
        }
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var nickname: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("昵称", text: $nickname)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    // 保存用户信息
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct NotificationSettingsView: View {
    @State private var enableNotifications = true
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    
    var body: some View {
        Form {
            Section {
                Toggle("启用通知", isOn: $enableNotifications)
            }
            
            if enableNotifications {
                Section(header: Text("通知类型")) {
                    Toggle("每日提醒", isOn: $dailyReminder)
                    Toggle("每周报告", isOn: $weeklyReport)
                }
            }
        }
        .navigationTitle("通知设置")
    }
}

struct ThemeSettingsView: View {
    @State private var selectedTheme = 0
    
    var body: some View {
        Form {
            Section {
                Picker("主题", selection: $selectedTheme) {
                    Text("浅色").tag(0)
                    Text("深色").tag(1)
                    Text("跟随系统").tag(2)
                }
            }
        }
        .navigationTitle("主题设置")
    }
}

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                NavigationLink("用户协议") {
                    Text("用户协议内容")
                        .padding()
                }
                
                NavigationLink("隐私政策") {
                    Text("隐私政策内容")
                        .padding()
                }
            }
        }
        .navigationTitle("关于我们")
    }
} 