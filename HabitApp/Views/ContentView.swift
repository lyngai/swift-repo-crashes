import SwiftUI

struct ContentView: View {
    @State private var showPalmRegister = false
    @State private var selectedState: PalmRegisterView.RegistrationState = .notRegistered
    @State private var selectedError: PalmError?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Palm 注册测试")
                    .font(.title)
                    .padding(.top, 50)
                
                // 正常注册入口
                Button(action: {
                    selectedState = .notRegistered
                    selectedError = nil
                    showPalmRegister = true
                }) {
                    demoButton(title: "注册 Palm", subtitle: "展示正常注册流程", color: .orange)
                }
                
                // 网络错误入口
                Button(action: {
                    selectedState = .networkError
                    selectedError = .network
                    showPalmRegister = true
                }) {
                    demoButton(title: "网络错误", subtitle: "展示网络异常状态", color: .red)
                }
                
                // 注册成功入口
                Button(action: {
                    selectedState = .registrationSuccess
                    selectedError = nil
                    showPalmRegister = true
                }) {
                    demoButton(title: "注册成功", subtitle: "展示注册成功状态", color: .green)
                }
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showPalmRegister) {
                PalmRegisterView(registrationState: selectedState, currentError: selectedError)
                    .onDisappear {
                        // 重置状态
                        selectedState = .notRegistered
                        selectedError = nil
                    }
            }
        }
    }
    
    private func demoButton(title: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 