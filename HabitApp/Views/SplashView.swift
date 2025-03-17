import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    var body: some View {
        if isActive {
            if habitViewModel.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
        } else {
            VStack {
                Text("习惯养成")
                    .font(.largeTitle)
                    .bold()
                
                Text("让美好的习惯伴随你的每一天")
                    .font(.subheadline)
                    .padding(.top, 8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
} 