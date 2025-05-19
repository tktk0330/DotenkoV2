/**
 * SplashView
 * 
 * アプリケーションの起動時に表示されるスプラッシュ画面
 * 認証処理とアプリステータスの確認中に表示される
 */

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// スプラッシュ画面のView
struct SplashView: View {
    // MARK: - Properties
    
    /// 画面遷移を管理するナビゲーター
    @ObservedObject var navigator: NavigationStateManager
    
    /// ビジネスロジックを管理するViewModel
    @StateObject private var viewModel = SplashViewModel()
    
    /// 画面の透明度（フェードアウト用）
    @State private var opacity: Double = 1.0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // 背景
            Color.white
                .ignoresSafeArea()
            
            // メインコンテンツ
            VStack(spacing: 16) {
                // アプリロゴ
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                // アプリ名
                Text("Dotenko")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // プログレスビュー（最前面に表示）
            if viewModel.isAuthenticating {
                CustomProgressView(isShowing: .constant(true))
            }
        }
        .opacity(opacity)
        .task {
            do {
                // 認証処理の実行
                try await viewModel.authenticateAndUpdateUser()
                
                // 認証成功時のみ画面遷移
                if viewModel.shouldNavigate {
                    // フェードアウトアニメーション
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                    
                    // TopViewへの遷移
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigator.push(AnyView(TopView(navigator: navigator)))
                    }
                }
            } catch {
                // エラーが発生した場合は、エラーメッセージを表示
                ErrorManager.shared.showError(error.localizedDescription)
            }
        }
        .withErrorHandling()
    }
}
