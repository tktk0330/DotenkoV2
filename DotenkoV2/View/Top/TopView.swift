import SwiftUI

struct TopView: View {
    
    @ObservedObject var navigator: NavigationStateManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Welcome to DTNK")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("アプリの説明や初期設定などをここに表示します")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("メイン画面へ") {
                    navigator.push(
                        AnyView(ContentView(bannerHeight: CGFloat(Constant.BANNER_HEIGHT))))
                }
            }
            .padding()
        }
    }
}
