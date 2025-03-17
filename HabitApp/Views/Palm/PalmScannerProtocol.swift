import SwiftUI

// MARK: - 掌纹扫描模式
enum PalmScanMode {
    case register    // 注册模式
    case verify     // 验证模式
    
    var title: String {
        "Palm service"  // 统一的服务名称，提升品牌一致性
    }
    
    var mainTitle: String {
        "Place your palm"  // 统一的主要指引文案，减少用户学习成本
    }
    
    var subtitle: String {
        switch self {
        case .register:
            return "Place your palm in the\ncircular area"  // 注册时需要更精确的位置指引
        case .verify:
            return "Please scan palm to pass"  // 验证时使用更简洁的指引
        }
    }
}

// MARK: - 掌纹识别状态
enum PalmScannerState: Equatable {
    // MARK: 正常流程状态
    case ready                                      // 准备扫描状态
    case scanning                                   // 扫描中状态
    case registrationSuccess                        // 注册成功状态
    case verificationSuccess(username: String, time: Date)  // 验证成功状态
    
    // MARK: 引导状态
    case notRegisteredWithQR                        // 未注册状态（需要注册）
    case notRegisteredWithoutQR                     // 未注册状态（联系管理员）
    
    // MARK: 异常状态
    case networkError                               // 网络异常状态
    case deviceNotActivated                         // 设备未激活状态
    case deviceNotInitialized                       // 设备未初始化状态
    
    // MARK: UI 属性
    var icon: String {
        switch self {
        case .ready, .scanning:
            return "hand.raised.fill"               // 手掌图标表示扫描相关状态
        case .registrationSuccess, .verificationSuccess:
            return "checkmark.circle.fill"          // 对勾图标表示成功状态
        case .notRegisteredWithQR, .notRegisteredWithoutQR,
             .networkError, .deviceNotActivated, .deviceNotInitialized:
            return "info.circle.fill"               // 信息图标表示提示状态
        }
    }
    
    var iconColor: Color {
        switch self {
        case .ready, .scanning, .registrationSuccess, .verificationSuccess:
            return .green                           // 绿色表示正常/成功状态
        case .notRegisteredWithQR, .notRegisteredWithoutQR,
             .networkError, .deviceNotActivated, .deviceNotInitialized:
            return .orange                          // 橙色表示警告/提示状态
        }
    }
    
    var title: String {
        switch self {
        case .ready, .scanning:
            return "Place your palm"                // 扫描相关状态的主标题
        case .notRegisteredWithQR, .notRegisteredWithoutQR:
            return "No palm registered"             // 未注册状态的主标题
        case .registrationSuccess:
            return "Registration Succeed"           // 注册成功状态的主标题
        case .verificationSuccess:
            return "Welcome"                        // 验证成功状态的主标题
        case .networkError:
            return "Network anomaly"                // 网络异常状态的主标题
        case .deviceNotActivated:
            return "Device not activated"           // 设备未激活状态的主标题
        case .deviceNotInitialized:
            return "Device not initialized"         // 设备未初始化状态的主标题
        }
    }
    
    var subtitle: String {
        switch self {
        case .ready:
            return "Place your palm in the\ncircular area"  // 准备状态的引导文案
        case .scanning:
            return "Please scan palm to pass"               // 扫描中状态的引导文案
        case .notRegisteredWithoutQR:
            return "Please contact the administrator"       // 需要管理员协助的提示文案
        case .notRegisteredWithQR:
            return "Please continue on your phone"          // 需要手机操作的提示文案
        case .registrationSuccess:
            return "Welcome to use Palm Service"            // 注册成功的欢迎文案
        case .verificationSuccess(let username, let time):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return "\(username)\nVerification time: \(formatter.string(from: time))"  // 验证成功的详细信息
        case .networkError:
            return "Please check the network"              // 网络异常的提示文案
        case .deviceNotActivated:
            return "Please activate before use"            // 设备未激活的提示文案
        case .deviceNotInitialized:
            return "Please contact the administrator"      // 设备未初始化的提示文案
        }
    }
    
    // MARK: 功能标志
    var showQRCode: Bool {
        switch self {
        case .notRegisteredWithQR, .networkError:
            return true     // 需要用户扫码操作的状态显示二维码
        default:
            return false    // 其他状态不显示二维码
        }
    }
    
    var showRefreshButton: Bool {
        switch self {
        case .deviceNotActivated, .deviceNotInitialized, .networkError:
            return true     // 可以通过刷新解决的异常状态显示刷新按钮
        default:
            return false    // 其他状态不显示刷新按钮
        }
    }
    
    var showScanGuide: Bool {
        switch self {
        case .ready, .scanning:
            return true     // 扫描相关状态显示扫描引导图
        default:
            return false    // 其他状态不显示扫描引导图
        }
    }
    
    // MARK: - Equatable
    static func == (lhs: PalmScannerState, rhs: PalmScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready),
             (.scanning, .scanning),
             (.registrationSuccess, .registrationSuccess),
             (.notRegisteredWithoutQR, .notRegisteredWithoutQR),
             (.notRegisteredWithQR, .notRegisteredWithQR),
             (.networkError, .networkError),
             (.deviceNotActivated, .deviceNotActivated),
             (.deviceNotInitialized, .deviceNotInitialized):
            return true
        case let (.verificationSuccess(lhsUsername, lhsTime),
                 .verificationSuccess(rhsUsername, rhsTime)):
            return lhsUsername == rhsUsername && lhsTime == rhsTime
        default:
            return false
        }
    }
}

// 掌纹识别配置
struct PalmScannerConfig {
    let mode: PalmScanMode
    let scanAreaSize: CGFloat
    let scanAreaColor: Color
    
    static func `default`(mode: PalmScanMode) -> PalmScannerConfig {
        PalmScannerConfig(
            mode: mode,
            scanAreaSize: 200,
            scanAreaColor: .green.opacity(0.3)
        )
    }
}

// 掌纹识别代理
protocol PalmScannerDelegate: AnyObject {
    func palmScannerDidComplete(result: Result<Void, Error>)
    func palmScannerDidCancel()
}

// 掌纹识别器协议
protocol PalmScannerProtocol {
    var state: PalmScannerState { get }
    var config: PalmScannerConfig { get }
    var delegate: PalmScannerDelegate? { get set }
    
    func startScanning()
    func stopScanning()
    func reset()
} 