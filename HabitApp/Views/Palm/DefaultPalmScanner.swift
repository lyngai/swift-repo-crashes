import SwiftUI

class DefaultPalmScanner: PalmScannerProtocol {
    private(set) var state: PalmScannerState
    let config: PalmScannerConfig
    weak var delegate: PalmScannerDelegate?
    
    init(mode: PalmScanMode) {
        self.config = .default(mode: mode)
        // 根据模式设置初始状态
        switch mode {
        case .register:
            self.state = .notRegisteredWithQR
        case .verify:
            self.state = .ready
        }
    }
    
    func startScanning() {
        state = .scanning
    }
    
    func stopScanning() {
        // 根据模式重置状态
        switch config.mode {
        case .register:
            state = .notRegisteredWithQR
        case .verify:
            state = .ready
        }
    }
    
    func reset() {
        stopScanning()
    }
    
    // 更新状态（用于测试）
    func updateState(_ newState: PalmScannerState) {
        state = newState
    }
    
    // MARK: - 私有方法
    
    private func handleRegistration() {
        // 模拟注册流程
        let shouldSucceed = Bool.random()
        
        if shouldSucceed {
            // 注册成功
            state = .registrationSuccess
            delegate?.palmScannerDidComplete(result: .success(()))
        } else {
            // 注册失败，随机选择一个错误状态
            let errorStates: [PalmScannerState] = [
                .networkError,
                .deviceNotActivated,
                .deviceNotInitialized
            ]
            state = errorStates.randomElement() ?? .networkError
            
            // 根据错误状态创建对应的错误
            let error: Error
            switch state {
            case .networkError:
                error = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
            case .deviceNotActivated:
                error = NSError(domain: "PalmScannerError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Device not activated"])
            case .deviceNotInitialized:
                error = NSError(domain: "PalmScannerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Device not initialized"])
            default:
                error = NSError(domain: "PalmScannerError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
            }
            
            delegate?.palmScannerDidComplete(result: .failure(error))
        }
    }
    
    private func handleVerification() {
        // 模拟验证流程
        let shouldSucceed = Bool.random()
        
        if shouldSucceed {
            // 验证成功
            state = .verificationSuccess(username: "XiJie Yuan", time: Date())
            delegate?.palmScannerDidComplete(result: .success(()))
        } else {
            // 验证失败，随机选择一个错误状态
            let errorStates: [PalmScannerState] = [
                .notRegisteredWithoutQR,
                .networkError,
                .deviceNotActivated,
                .deviceNotInitialized
            ]
            state = errorStates.randomElement() ?? .networkError
            
            // 根据错误状态创建对应的错误
            let error: Error
            switch state {
            case .notRegisteredWithoutQR:
                error = NSError(domain: "PalmScannerError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Palm not registered"])
            case .networkError:
                error = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
            case .deviceNotActivated:
                error = NSError(domain: "PalmScannerError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Device not activated"])
            case .deviceNotInitialized:
                error = NSError(domain: "PalmScannerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Device not initialized"])
            default:
                error = NSError(domain: "PalmScannerError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
            }
            
            delegate?.palmScannerDidComplete(result: .failure(error))
        }
    }
} 