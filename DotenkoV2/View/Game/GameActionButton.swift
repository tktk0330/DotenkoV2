import SwiftUI

// MARK: - Game Action Button
/// ゲーム操作ボタンコンポーネント
struct GameActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    let backgroundColor: Color
    let size: CGFloat
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Text(label)
                    .font(.system(size: size * 0.18, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(1.2)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .lineLimit(1)
            }
            .frame(width: size, height: size)
            .background(
                ZStack {
                    // ベースの円形背景
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: backgroundColor.opacity(0.9), location: 0.0),
                                    .init(color: backgroundColor, location: 0.7),
                                    .init(color: backgroundColor.opacity(0.6), location: 1.0)
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: size * 0.8
                            )
                        )
                    
                    // カジノ風の装飾リング
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                                    Color(red: 0.8, green: 0.6, blue: 0.0),
                                    Color(red: 1.0, green: 0.84, blue: 0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                    
                    // 内側の装飾リング
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .scaleEffect(0.85)
                    
                    // 光沢エフェクト
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.3), location: 0.0),
                                    .init(color: Color.clear, location: 0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .scaleEffect(0.6)
                        .offset(x: -size * 0.1, y: -size * 0.1)
                }
            )
            .overlay(
                // 押下時のエフェクト
                Circle()
                    .fill(Color.white.opacity(isPressed ? 0.2 : 0.0))
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .shadow(
                color: backgroundColor.opacity(0.6),
                radius: isPressed ? 6 : 12,
                x: 0,
                y: isPressed ? 2 : 6
            )
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(1000) // 最前面に配置
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
