import SwiftUI

struct LoginView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "注册" : "登录")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("手机号")
                    .foregroundColor(.gray)
                TextField("请输入手机号", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("密码")
                    .foregroundColor(.gray)
                SecureField("请输入密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: handleLoginOrRegister) {
                Text(isRegistering ? "注册" : "登录")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(phoneNumber.isEmpty || password.isEmpty)
            
            Button(action: { isRegistering.toggle() }) {
                Text(isRegistering ? "已有账号？立即登录" : "没有账号？立即注册")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
        }
    }
    
    private func handleLoginOrRegister() {
        guard isValidPhoneNumber(phoneNumber) else {
            alertMessage = "请输入有效的手机号"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "密码长度至少为6位"
            showAlert = true
            return
        }
        
        // 这里应该调用实际的登录/注册API
        // 现在我们简单模拟一下
        habitViewModel.login(phoneNumber: phoneNumber, nickname: "用户\(phoneNumber.suffix(4))")
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: phone)
    }
} 