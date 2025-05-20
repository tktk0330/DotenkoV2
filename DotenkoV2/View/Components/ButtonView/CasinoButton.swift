import SwiftUI

struct CasinoButton: View {
    let title: String
    let action: () -> Void
    @State private var isBlinking = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    ZStack {
                        // メインのグラデーション背景
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: Appearance.Color.casinoGradient.button.main.map { Color($0) }),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // ゴールドのアクセント
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: Appearance.Color.casinoGradient.button.accent.map { Color($0) }),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    // 点滅する太いボーダー
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: Appearance.Color.casinoGradient.button.border.map { Color($0) }),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isBlinking ? 8 : 2 // 太さをアニメーション
                        )
                        .opacity(isBlinking ? 1.0 : 0.3) // 点滅
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isBlinking)
                )
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: Color.yellow.opacity(0.7), radius: 16, x: 0, y: 0) // より強い影
        }
        .buttonStyle(CasinoButtonStyle())
        .padding(.horizontal, 40)
        .onAppear {
            isBlinking = true
        }
    }
}

// カジノ風のボタンスタイル
struct CasinoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
