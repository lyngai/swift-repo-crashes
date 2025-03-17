import SwiftUI

// 注册状态回调协议
protocol PalmRegistrationDelegate: AnyObject {
    func onRegistrationSuccess()
    func onRegistrationError(_ error: PalmError)
    func onRegistrationCancelled()
}

// Palm 错误类型
enum PalmError: Error {
    case network
    case timeout
    case serverError
    case unknown
    
    var message: String {
        switch self {
        case .network:
            return "Please check the network"
        case .timeout:
            return "Connection timeout"
        case .serverError:
            return "Service unavailable"
        case .unknown:
            return "Unknown error"
        }
    }
}

struct PalmRegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var qrCodeImage: UIImage?
    @State private var registrationState: RegistrationState
    @State private var currentError: PalmError?
    
    // 回调代理
    var delegate: PalmRegistrationDelegate?
    
    // 初始化方法
    init(registrationState: RegistrationState = .notRegistered, currentError: PalmError? = nil) {
        _registrationState = State(initialValue: registrationState)
        _currentError = State(initialValue: currentError)
    }
    
    enum RegistrationState {
        case notRegistered      // 未注册状态，显示二维码
        case registrationSuccess // 注册成功
        case networkError      // 网络错误
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 顶部关闭按钮
            HStack {
                Button(action: {
                    delegate?.onRegistrationCancelled()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // 状态图标
            Circle()
                .fill(stateColor)
                .frame(width: 60, height: 60)
                .overlay(
                    stateIcon
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // 状态标题和描述
            VStack(spacing: 8) {
                Text(stateTitle)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                if let subtitle = stateSubtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 二维码或其他内容
            Group {
                switch registrationState {
                case .notRegistered:
                    if let qrCodeImage = qrCodeImage {
                        Image(uiImage: qrCodeImage)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                    }
                case .networkError:
                    VStack(spacing: 16) {
                        // 错误信息框
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            .frame(width: 200, height: 200)
                            .overlay(
                                Group {
                                    if let qrCodeImage = qrCodeImage {
                                        Image(uiImage: qrCodeImage)
                                            .interpolation(.none)
                                            .resizable()
                                            .frame(width: 180, height: 180)
                                    }
                                }
                            )
                        
                        // 重试按钮
                        Button(action: {
                            retryRegistration()
                        }) {
                            Text("重试")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 44)
                                .background(Color.orange)
                                .cornerRadius(22)
                        }
                    }
                default:
                    EmptyView()
                }
            }
            
            // 底部提示
            VStack(spacing: 4) {
                if case .notRegistered = registrationState {
                    Text("Please continue on your phone")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text("Palm")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(.top)
        .background(Color(.systemBackground))
        .onAppear {
            generateQRCode()
        }
        .onChange(of: registrationState) { newState in
            switch newState {
            case .registrationSuccess:
                delegate?.onRegistrationSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            case .networkError:
                if let error = currentError {
                    delegate?.onRegistrationError(error)
                }
            default:
                break
            }
        }
    }
    
    private var stateColor: Color {
        switch registrationState {
        case .notRegistered:
            return .orange
        case .registrationSuccess:
            return .green
        case .networkError:
            return .orange
        }
    }
    
    private var stateIcon: some View {
        Group {
            switch registrationState {
            case .notRegistered:
                Text("i")
            case .registrationSuccess:
                Image(systemName: "checkmark")
            case .networkError:
                Image(systemName: "exclamationmark")
            }
        }
    }
    
    private var stateTitle: String {
        switch registrationState {
        case .notRegistered:
            return "未注册Palm"
        case .registrationSuccess:
            return "Registration\nSucceed"
        case .networkError:
            return "Network anomaly"
        }
    }
    
    private var stateSubtitle: String? {
        switch registrationState {
        case .registrationSuccess:
            return "Welcome to use Palm Service"
        case .networkError:
            return currentError?.message ?? "Please check the network"
        default:
            return nil
        }
    }
    
    private func generateQRCode() {
        // 生成实际的注册链接
        let registrationCode = "palm_register_\(UUID().uuidString)"
        qrCodeImage = QRCodeGenerator.generateQRCode(from: registrationCode)
    }
    
    private func retryRegistration() {
        withAnimation {
            registrationState = .notRegistered
            currentError = nil
            generateQRCode()
        }
    }
    
    // 供外部调用的状态更新方法
    func updateRegistrationState(_ state: RegistrationState, error: PalmError? = nil) {
        withAnimation {
            registrationState = state
            currentError = error
        }
    }
}

// 预览
struct PalmRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 未注册状态
            PalmRegisterView(registrationState: .notRegistered)
            
            // 网络错误状态
            PalmRegisterView(registrationState: .networkError)
                .previewDisplayName("Network Error")
            
            // 注册成功状态
            PalmRegisterView(registrationState: .registrationSuccess)
                .previewDisplayName("Success")
        }
    }
} 