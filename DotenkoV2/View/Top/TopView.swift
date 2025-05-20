import SwiftUI

struct TopView: View {
    
    @ObservedObject var navigator: NavigationStateManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // ロゴとアイコンの重ね合わせ
                ZStack {
                    // アイコン（少し上に配置）
//                    Image(uiImage: UIImage(named: Appearance.Image.Top.topIcon) ?? UIImage())
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 300)
                    
                    // メインロゴ
                    Image(uiImage: UIImage(named: Appearance.Image.Top.topLogo) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .offset(y: -250) // 上に移動
                }
                .frame(height: 350) // 重なりを考慮した高さ
                
                CasinoButton(title: "Start") {
                    navigator.push(
                        AnyView(ContentView(bannerHeight: CGFloat(Constant.BANNER_HEIGHT))))
                }
            }
            .padding()
        }
    }
}
