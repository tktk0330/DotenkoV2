import SwiftUI

struct RootView: View {
    private let bannerHeight: CGFloat = CGFloat(Constant.BANNER_HEIGHT) // バナー広告の高さを定数として定義
    @StateObject private var navigator = NavigationStateManager()
    @StateObject private var allViewNavigator = NavigationAllViewStateManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mainContent
                fullScreenContent
                bannerView(width: geometry.size.width)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .environmentObject(navigator)
        .environmentObject(allViewNavigator)
        .withNetworkMonitoring() // ネットワーク監視を追加
        .withErrorHandling() // エラーハンドリングを追加
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        Group {
            if let currentView = navigator.currentView {
                currentView
            } else {
                SplashView(navigator: navigator)
            }
        }
    }
    
    // MARK: - Full Screen Content
    private var fullScreenContent: some View {
        Group {
            if let allScreenView = allViewNavigator.currentView {
                allScreenView
            }
        }
    }
    
    // MARK: - Banner View
    private func bannerView(width: CGFloat) -> some View {
        VStack {
            Spacer()
            BannerAdView(adUnitID: Config.bannerId)
                .frame(height: bannerHeight)
                .background(Color(uiColor: Appearance.Color.mossGreen))
        }
        .frame(width: width)
    }
}
