import SwiftUI

struct PalmSettingsView: View {
    @State private var showingPalmScanner = false
    @State private var currentScanner: DefaultPalmScanner?
    
    // Palm UI 测试状态
    private let testStates: [(String, PalmScannerState)] = [
        ("扫描引导", .scanning),
        ("未注册（无二维码）", .notRegisteredWithoutQR),
        ("未注册（带二维码）", .notRegisteredWithQR),
        ("注册成功", .registrationSuccess),
        ("验证成功", .verificationSuccess(username: "XiJie Yuan", time: Date())),
        ("设备未激活", .deviceNotActivated),
        ("设备未初始化", .deviceNotInitialized),
        ("网络异常", .networkError)
    ]
    
    var body: some View {
        Section {
            ForEach(testStates, id: \.0) { title, state in
                Button(action: {
                    let mode: PalmScanMode = {
                        switch state {
                        case .registrationSuccess, .notRegisteredWithQR:
                            return .register
                        default:
                            return .verify
                        }
                    }()
                    
                    let scanner = DefaultPalmScanner(mode: mode)
                    scanner.updateState(state)
                    currentScanner = scanner
                    showingPalmScanner = true
                }) {
                    HStack {
                        Image(systemName: state.icon)
                            .foregroundColor(state.iconColor)
                        Text(title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
        } header: {
            Text("生物识别")
        }
        .sheet(isPresented: $showingPalmScanner) {
            if let scanner = currentScanner {
                PalmScannerView(scanner: scanner)
            }
        }
    }
} 