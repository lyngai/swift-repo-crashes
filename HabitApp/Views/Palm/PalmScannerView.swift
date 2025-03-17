import SwiftUI

struct PalmScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PalmScannerViewModel
    
    init(scanner: PalmScannerProtocol) {
        _viewModel = StateObject(wrappedValue: PalmScannerViewModel(scanner: scanner))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 顶部工具栏
            HStack {
                // 关闭按钮
                Button(action: {
                    viewModel.cancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // 服务标题
            Text("Palm service")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // 主标题
            Text(viewModel.scanner.state.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if viewModel.scanner.state.showScanGuide {
                // 扫描引导图
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    // 掌纹图片
                    Image("palm_scan_guide")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    // 扫描区域指示
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .offset(y: 20)
                }
            } else {
                // 状态图标
                Image(systemName: viewModel.scanner.state.icon)
                    .font(.system(size: 50))
                    .foregroundColor(viewModel.scanner.state.iconColor)
                    .padding(.bottom, 10)
                
                // 二维码（仅在需要时显示）
                if viewModel.scanner.state.showQRCode {
                    QRCodeView(url: viewModel.qrCodeURL)
                        .frame(width: 200, height: 200)
                        .padding(.vertical, 20)
                }
            }
            
            // 副标题
            Text(viewModel.scanner.state.subtitle)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // 刷新按钮
            if viewModel.scanner.state.showRefreshButton {
                Button(action: {
                    viewModel.refresh()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("刷新")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
            
            // 底部品牌标识
            Text("Palm Service")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom)
        }
        .padding(.top, 20)
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .onChange(of: viewModel.scanner.state) { newState in
            // 如果是验证成功状态，3秒后自动关闭
            if case .verificationSuccess = newState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

// 二维码视图组件
struct QRCodeView: View {
    let url: String
    
    var body: some View {
        if let qrImage = generateQRCode(from: url) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = outputImage.transformed(by: transform)
                
                if let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}

// 预览
struct PalmScannerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 注册模式预览
            PalmScannerView(scanner: MockPalmScanner(mode: .register))
                .previewDisplayName("Register Mode")
            
            // 验证模式预览
            PalmScannerView(scanner: MockPalmScanner(mode: .verify))
                .previewDisplayName("Verify Mode")
        }
    }
}

// 模拟掌纹识别器（用于预览）
private class MockPalmScanner: PalmScannerProtocol {
    var state: PalmScannerState = .notRegisteredWithoutQR
    let config: PalmScannerConfig
    var delegate: PalmScannerDelegate?
    
    init(mode: PalmScanMode) {
        self.config = .default(mode: mode)
        // 根据模式设置初始状态
        switch mode {
        case .register:
            state = .notRegisteredWithQR
        case .verify:
            state = .verificationSuccess(username: "XiJie Yuan", time: Date())
        }
    }
    
    func startScanning() {}
    func stopScanning() {}
    func reset() {}
} 