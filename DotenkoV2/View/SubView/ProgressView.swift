/**
 * ProgressView
 * 
 * アプリケーション全体で使用するカスタムプログレスビュー
 * Firebaseの通信待ちなどのローディング表示に使用
 */

import SwiftUI

/// カスタムプログレスビュー
struct CustomProgressView: View {
    /// プログレスビューの表示状態
    @Binding var isShowing: Bool
    
    /// プログレスビューの背景色
    private let backgroundColor = Color.black.opacity(0.4)
    
    /// プログレスビューのサイズ
    private let size: CGFloat = 50
    
    var body: some View {
        ZStack {
            if isShowing {
                // 背景オーバーレイ
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                // プログレスインジケータ
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .frame(width: size, height: size)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                    .transition(.scale)
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
}

/// プログレスビューの表示を管理するクラス
class ProgressViewManager: ObservableObject {
    /// シングルトンインスタンス
    static let shared = ProgressViewManager()
    
    /// プログレスビューの表示状態
    @Published var isShowing = false
    
    private init() {}
    
    /// プログレスビューを表示する
    func show() {
        DispatchQueue.main.async {
            self.isShowing = true
        }
    }
    
    /// プログレスビューを非表示にする
    func hide() {
        DispatchQueue.main.async {
            self.isShowing = false
        }
    }
}

/// プログレスビューを使用するためのViewModifier
struct ProgressViewModifier: ViewModifier {
    @ObservedObject private var progressManager = ProgressViewManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            CustomProgressView(isShowing: $progressManager.isShowing)
        }
    }
}

// MARK: - View Extension
extension View {
    /// プログレスビューを追加する
    func withProgressView() -> some View {
        modifier(ProgressViewModifier())
    }
}

// MARK: - Preview
struct CustomProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            CustomProgressView(isShowing: .constant(true))
        }
    }
}
