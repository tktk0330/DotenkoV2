import SwiftUI

struct SplashView: View {
    @ObservedObject var navigator: NavigationStateManager
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.red)
            }
        }
        .opacity(opacity)
        .onAppear {
            // フェードアウトしてから遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
            }
            
            // TopViewへ遷移
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                navigator.push(AnyView(TopView(navigator: navigator)))
            }
        }
    }
}
