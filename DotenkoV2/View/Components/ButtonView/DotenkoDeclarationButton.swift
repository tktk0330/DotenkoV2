import SwiftUI

// MARK: - Dotenko Declaration Button
/// どてんこ宣言専用ボタンコンポーネント（カジノ風デザイン）
struct DotenkoDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    @State private var isPressed = false
    @State private var isBlinking = false
    
    private let width: CGFloat = 120
    private let height: CGFloat = 50
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                // カジノ風背景
                casinoBackground
                
                // メインテキスト
                VStack(spacing: 2) {
                    Text("DOTENKO")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(textColor)
                        .tracking(1.0)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.8), radius: 1, x: 0, y: 1)
                    
                    Text("宣言")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(textColor.opacity(0.9))
                        .tracking(0.5)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.6), radius: 1, x: 0, y: 1)
                }
                
                // 押下時のオーバーレイ
                if isPressed && isEnabled {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Appearance.Color.commonWhite.opacity(0.2))
                }
            }
            .frame(width: width, height: height)
            .scaleEffect(isPressed && isEnabled ? 0.95 : 1.0)
            .scaleEffect(isBlinking ? 1.08 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isBlinking)
            .opacity(1.0) // 🔧 DEBUG: 一時的に常時表示
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2000)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(!isEnabled)
        .onAppear {
            // 🔧 DEBUG: 一時的に常時点滅
            isBlinking = true
        }
        .onChange(of: isEnabled) { enabled in
            // 🔧 DEBUG: 一時的に常時点滅
            isBlinking = true
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    @ViewBuilder
    private var casinoBackground: some View {
        ZStack {
            // ベース背景（深い紫のグラデーション）
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.dotenkoButtonBackground.opacity(0.95), location: 0.0),
                            .init(color: Appearance.Color.dotenkoButtonBackground, location: 0.3),
                            .init(color: Appearance.Color.dotenkoButtonBackground.opacity(0.8), location: 0.7),
                            .init(color: Appearance.Color.dotenkoButtonBackground.opacity(0.9), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Appearance.Color.dotenkoButtonBackground.opacity(0.6), radius: 8, x: 0, y: 4)
            
            // ゴールドの装飾枠線（二重枠）
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Appearance.Color.dotenkoButtonAccent,
                            Appearance.Color.playerGold,
                            Appearance.Color.dotenkoButtonAccent,
                            Appearance.Color.playerGold
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
            
            // 内側の細い枠線
            RoundedRectangle(cornerRadius: 10)
                .stroke(Appearance.Color.commonWhite.opacity(isEnabled ? 0.3 : 0.1), lineWidth: 1)
                .scaleEffect(0.92)
            
            // カジノ風の光沢エフェクト
            if isEnabled {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.25), location: 0.0),
                                .init(color: Appearance.Color.commonClear, location: 0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .scaleEffect(0.8)
                    .offset(x: -8, y: -4)
            }
            
            // カジノ風の装飾パターン（角の装飾）
            VStack {
                HStack {
                    casinoCornerDecoration
                    Spacer()
                    casinoCornerDecoration
                }
                Spacer()
                HStack {
                    casinoCornerDecoration
                    Spacer()
                    casinoCornerDecoration
                }
            }
            .padding(4)
        }
    }
    
    @ViewBuilder
    private var casinoCornerDecoration: some View {
        Circle()
            .fill(Appearance.Color.playerGold.opacity(isEnabled ? 0.6 : 0.2))
            .frame(width: 4, height: 4)
    }
} 