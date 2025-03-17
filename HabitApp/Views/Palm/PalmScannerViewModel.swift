import SwiftUI
import Combine

class PalmScannerViewModel: ObservableObject {
    // MARK: - 公开属性
    private(set) var scanner: PalmScannerProtocol {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var shouldDismiss = false
    @Published var qrCodeURL = "https://example.com/palm-register"
    
    // MARK: - 私有属性
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 生命周期
    init(scanner: PalmScannerProtocol) {
        self.scanner = scanner
        self.scanner.delegate = self
    }
    
    // MARK: - 公开方法
    func startScanning() {
        scanner.startScanning()
    }
    
    func stopScanning() {
        scanner.stopScanning()
    }
    
    func cancel() {
        shouldDismiss = true
    }
    
    func refresh() {
        scanner.reset()
        scanner.startScanning()
    }
}

// MARK: - PalmScannerDelegate
extension PalmScannerViewModel: PalmScannerDelegate {
    func palmScannerDidComplete(result: Result<Void, Error>) {
        switch result {
        case .success:
            if case .verify = scanner.config.mode {
                if let scanner = scanner as? DefaultPalmScanner {
                    scanner.updateState(.verificationSuccess(username: "XiJie Yuan", time: Date()))
                }
            } else {
                if let scanner = scanner as? DefaultPalmScanner {
                    scanner.updateState(.registrationSuccess)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.shouldDismiss = true
            }
            
        case .failure(let error):
            if let scanner = scanner as? DefaultPalmScanner {
                if (error as NSError).domain == NSURLErrorDomain {
                    scanner.updateState(.networkError)
                } else {
                    switch (error as NSError).code {
                    case 1001:
                        scanner.updateState(.deviceNotActivated)
                    case 1002:
                        scanner.updateState(.deviceNotInitialized)
                    case 1003:
                        scanner.updateState(.notRegisteredWithoutQR)
                    default:
                        scanner.updateState(.networkError)
                    }
                }
            }
        }
    }
    
    func palmScannerDidCancel() {
        // 直接关闭，不改变状态
        shouldDismiss = true
    }
} 
