import SwiftUI

// MARK: - Game Action Button
/// ゲーム操作ボタンコンポーネント
struct GameActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    let backgroundColor: Color
    let size: CGFloat
    let isEnabled: Bool
    
    @State private var isPressed = false
    
    init(icon: String, label: String, action: @escaping () -> Void, backgroundColor: Color, size: CGFloat, isEnabled: Bool = true) {
        self.icon = icon
        self.label = label
        self.action = action
        self.backgroundColor = backgroundColor
        self.size = size
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(iconColor)
                    .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Text(label)
                    .font(.system(size: size * 0.18, weight: .heavy))
                    .foregroundColor(textColor)
                    .tracking(1.2)
                    .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 2, x: 0, y: 1)
                    .lineLimit(1)
            }
            .frame(width: size, height: size)
            .background(buttonBackground)
            .overlay(pressedOverlay)
            .scaleEffect(isPressed && isEnabled ? 0.92 : 1.0)
            .shadow(
                color: shadowColor,
                radius: isPressed && isEnabled ? 6 : 12,
                x: 0,
                y: isPressed && isEnabled ? 2 : 6
            )
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(1000) // 最前面に配置
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(!isEnabled)
    }
    
    // MARK: - Computed Properties
    
    private var iconColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    private var shadowColor: Color {
        isEnabled ? backgroundColor.opacity(0.6) : Appearance.Color.commonGray.opacity(0.3)
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        ZStack {
            // ベースの円形背景
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: backgroundGradientColor.opacity(0.9), location: 0.0),
                            .init(color: backgroundGradientColor, location: 0.7),
                            .init(color: backgroundGradientColor.opacity(0.6), location: 1.0)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.8
                    )
                )
            
            // カジノ風の装飾リング
            Circle()
                .stroke(borderGradient, lineWidth: 3)
            
            // 内側の装飾リング
            Circle()
                .stroke(Appearance.Color.commonWhite.opacity(isEnabled ? 0.4 : 0.2), lineWidth: 1)
                .scaleEffect(0.85)
            
            // 光沢エフェクト
            if isEnabled {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.3), location: 0.0),
                                .init(color: Appearance.Color.commonClear, location: 0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -size * 0.1, y: -size * 0.1)
            }
        }
    }
    
    @ViewBuilder
    private var pressedOverlay: some View {
        // 押下時のエフェクト
        Circle()
            .fill(Appearance.Color.commonWhite.opacity(isPressed && isEnabled ? 0.2 : 0.0))
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var backgroundGradientColor: Color {
        isEnabled ? backgroundColor : Appearance.Color.commonGray
    }
    
    private var borderGradient: LinearGradient {
        if isEnabled {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Appearance.Color.playerGold,
                    Appearance.Color.playerDarkGold,
                    Appearance.Color.playerGold
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Appearance.Color.commonGray.opacity(0.6),
                    Appearance.Color.commonGray.opacity(0.4),
                    Appearance.Color.commonGray.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
