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
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
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
            // 有効な時のみ点滅
            isBlinking = isEnabled
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅制御
            isBlinking = enabled
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

// MARK: - Revenge Declaration Button
/// リベンジ宣言専用ボタンコンポーネント（カジノ風デザイン）
struct RevengeDeclarationButton: View {
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
                // カジノ風背景（リベンジ用カラー）
                revengeBackground
                
                // メインテキスト
                VStack(spacing: 2) {
                    Text("REVENGE")
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
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
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
            // 有効な時のみ点滅
            isBlinking = isEnabled
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅制御
            isBlinking = enabled
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    @ViewBuilder
    private var revengeBackground: some View {
        ZStack {
            // ベース背景（深い赤のグラデーション）
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.red.opacity(0.95), location: 0.0),
                            .init(color: Color.red, location: 0.3),
                            .init(color: Color.red.opacity(0.8), location: 0.7),
                            .init(color: Color.red.opacity(0.9), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.red.opacity(0.6), radius: 8, x: 0, y: 4)
            
            // ゴールドの装飾枠線（二重枠）
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Color.orange,
                            Appearance.Color.playerGold,
                            Color.orange,
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
                    revengeCornerDecoration
                    Spacer()
                    revengeCornerDecoration
                }
                Spacer()
                HStack {
                    revengeCornerDecoration
                    Spacer()
                    revengeCornerDecoration
                }
            }
            .padding(4)
        }
    }
    
    @ViewBuilder
    private var revengeCornerDecoration: some View {
        Circle()
            .fill(Appearance.Color.playerGold.opacity(isEnabled ? 0.6 : 0.2))
            .frame(width: 4, height: 4)
    }
}

// MARK: - Shotenko Declaration Button
/// しょてんこ宣言専用ボタンコンポーネント（カジノ風デザイン）
struct ShotenkoDeclarationButton: View {
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
                // カジノ風背景（しょてんこ用カラー）
                shotenkoBackground
                
                // メインテキスト
                VStack(spacing: 2) {
                    Text("SHOTENKO")
                        .font(.system(size: 13, weight: .black))
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
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
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
            // 有効な時のみ点滅
            isBlinking = isEnabled
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅制御
            isBlinking = enabled
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    @ViewBuilder
    private var shotenkoBackground: some View {
        ZStack {
            // ベース背景（深いオレンジのグラデーション）
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.orange.opacity(0.95), location: 0.0),
                            .init(color: Color.orange, location: 0.3),
                            .init(color: Color.orange.opacity(0.8), location: 0.7),
                            .init(color: Color.orange.opacity(0.9), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.orange.opacity(0.6), radius: 8, x: 0, y: 4)
            
            // ゴールドの装飾枠線（二重枠）
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Color.yellow,
                            Appearance.Color.playerGold,
                            Color.yellow,
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
                    shotenkoCornerDecoration
                    Spacer()
                    shotenkoCornerDecoration
                }
                Spacer()
                HStack {
                    shotenkoCornerDecoration
                    Spacer()
                    shotenkoCornerDecoration
                }
            }
            .padding(4)
        }
    }
    
    @ViewBuilder
    private var shotenkoCornerDecoration: some View {
        Circle()
            .fill(Appearance.Color.playerGold.opacity(isEnabled ? 0.6 : 0.2))
            .frame(width: 4, height: 4)
    }
}

// MARK: - Challenge Zone Draw Card Button
/// チャレンジゾーン用カード引きボタン
struct ChallengeDrawCardButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Text("カードを引く")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
            }
            .frame(width: 100, height: 80)
            .background(challengeButtonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(challengeButtonBorder)
            .shadow(color: challengeButtonShadowColor, radius: 6, x: 0, y: 3)
            .scaleEffect(isEnabled ? 1.0 : 0.9)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
    
    private var challengeButtonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.blue.opacity(0.6),
                Color.blue.opacity(0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var challengeButtonBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.8),
                        Color.blue.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    private var challengeButtonShadowColor: Color {
        Color.blue.opacity(0.4)
    }
}

// MARK: - Game Announcement View
/// ゲームアナウンス表示コンポーネント（右から流れて中央で1秒停止して左に流れる）
struct GameAnnouncementView: View {
    let title: String
    let subtitle: String
    let isVisible: Bool
    
    @State private var animationPhase: AnnouncementPhase = .hidden
    @State private var sparkleAnimation: Bool = false
    @State private var glowAnimation: Bool = false
    
    enum AnnouncementPhase {
        case hidden      // 非表示
        case entering    // 右から中央へ
        case staying     // 中央で停止
        case exiting     // 中央から左へ
    }
    
    var body: some View {
        if isVisible {
            // 絶対位置指定でレイアウトに影響しないオーバーレイ
            GeometryReader { geometry in
                VStack(spacing: 16) {
                    // 装飾的なトップライン
                    decorativeTopLine
                    
                    // メインタイトル
                    Text(title)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Appearance.Color.commonWhite)
                        .tracking(3.0)
                        .shadow(color: Appearance.Color.commonBlack, radius: 4, x: 0, y: 2)
                        .shadow(color: Appearance.Color.playerGold.opacity(0.8), radius: 8, x: 0, y: 0)
                        .scaleEffect(glowAnimation ? 1.05 : 1.0)
                    
                    // サブタイトル
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.95))
                            .tracking(1.5)
                            .shadow(color: Appearance.Color.commonBlack, radius: 3, x: 0, y: 1)
                            .shadow(color: Appearance.Color.playerGold.opacity(0.6), radius: 6, x: 0, y: 0)
                    }
                    
                    // 装飾的なボトムライン
                    decorativeBottomLine
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
                .background(luxuryAnnouncementBackground)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(luxuryAnnouncementBorder)
                .overlay(sparkleOverlay)
                .shadow(color: Appearance.Color.commonBlack.opacity(0.7), radius: 15, x: 0, y: 8)
                .shadow(color: Appearance.Color.playerGold.opacity(0.4), radius: 20, x: 0, y: 0)
                .scaleEffect(animationPhase == .staying ? (glowAnimation ? 1.02 : 1.0) : 1.0)
                .position(
                    x: geometry.size.width / 2 + offsetX(for: geometry),
                    y: geometry.size.height / 2
                )
                .opacity(opacity)
            }
            .allowsHitTesting(false) // タッチイベントを完全に無効化
            .zIndex(99999) // 確実に最前面に表示（全ての要素より上）
            .onAppear {
                startAnimation()
                startContinuousAnimations()
            }
            .onChange(of: isVisible) { visible in
                if visible {
                    startAnimation()
                    startContinuousAnimations()
                } else {
                    animationPhase = .hidden
                    sparkleAnimation = false
                    glowAnimation = false
                }
            }
        }
    }
    
    // MARK: - Decorative Elements
    
    @ViewBuilder
    private var decorativeTopLine: some View {
        HStack(spacing: 12) {
            luxuryDecorationCluster
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonClear,
                            Appearance.Color.playerGold.opacity(0.3),
                            Appearance.Color.playerGold,
                            Color.yellow.opacity(0.8),
                            Appearance.Color.playerGold,
                            Appearance.Color.playerGold.opacity(0.3),
                            Appearance.Color.commonClear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.commonClear,
                                    Appearance.Color.commonWhite.opacity(0.6),
                                    Appearance.Color.commonClear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .offset(y: -1)
                )
            
            luxuryDecorationCluster
        }
    }
    
    @ViewBuilder
    private var decorativeBottomLine: some View {
        HStack(spacing: 12) {
            luxuryDecorationCluster
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonClear,
                            Appearance.Color.playerGold.opacity(0.3),
                            Appearance.Color.playerGold,
                            Color.yellow.opacity(0.8),
                            Appearance.Color.playerGold,
                            Appearance.Color.playerGold.opacity(0.3),
                            Appearance.Color.commonClear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.commonClear,
                                    Appearance.Color.commonWhite.opacity(0.6),
                                    Appearance.Color.commonClear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .offset(y: -1)
                )
            
            luxuryDecorationCluster
        }
    }
    
    @ViewBuilder
    private var luxuryDecorationCluster: some View {
        HStack(spacing: 4) {
            // 大きなダイヤモンド
            Diamond()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.yellow,
                            Appearance.Color.playerGold,
                            Color.orange.opacity(0.8)
                        ]),
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 10
                    )
                )
                .frame(width: 16, height: 16)
                .shadow(color: Appearance.Color.playerGold.opacity(0.8), radius: 6, x: 0, y: 0)
                .overlay(
                    Diamond()
                        .fill(Appearance.Color.commonWhite.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .offset(x: -2, y: -2)
                )
            
            // 小さなダイヤモンド
            Diamond()
                .fill(Appearance.Color.playerGold)
                .frame(width: 8, height: 8)
                .shadow(color: Appearance.Color.playerGold.opacity(0.6), radius: 3, x: 0, y: 0)
            
            // 装飾的な円
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(0.8),
                            Appearance.Color.playerGold.opacity(0.6),
                            Color.orange.opacity(0.4)
                        ]),
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 6
                    )
                )
                .frame(width: 6, height: 6)
                .shadow(color: Appearance.Color.playerGold.opacity(0.5), radius: 2, x: 0, y: 0)
        }
    }
    
    @ViewBuilder
    private var sparkleOverlay: some View {
        if sparkleAnimation {
            ZStack {
                // 左上のスパークル（大）
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.commonWhite,
                                    Color.yellow.opacity(0.8),
                                    Appearance.Color.commonClear
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 6
                            )
                        )
                        .frame(width: 8, height: 8)
                    
                    Circle()
                        .fill(Appearance.Color.commonWhite)
                        .frame(width: 3, height: 3)
                }
                .offset(x: -90, y: -45)
                .opacity(sparkleAnimation ? 1.0 : 0.0)
                
                // 右上のスパークル（中）
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.playerGold,
                                    Color.orange.opacity(0.8),
                                    Appearance.Color.commonClear
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 8
                            )
                        )
                        .frame(width: 10, height: 10)
                    
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 4, height: 4)
                }
                .offset(x: 85, y: -35)
                .opacity(sparkleAnimation ? 1.0 : 0.0)
                
                // 左下のスパークル（小）
                ZStack {
                    Circle()
                        .fill(Appearance.Color.commonWhite.opacity(0.9))
                        .frame(width: 5, height: 5)
                    
                    Circle()
                        .fill(Appearance.Color.commonWhite)
                        .frame(width: 2, height: 2)
                }
                .offset(x: -70, y: 40)
                .opacity(sparkleAnimation ? 1.0 : 0.0)
                
                // 右下のスパークル（中）
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow,
                                    Appearance.Color.playerGold.opacity(0.8),
                                    Appearance.Color.commonClear
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 7
                            )
                        )
                        .frame(width: 9, height: 9)
                    
                    Circle()
                        .fill(Appearance.Color.commonWhite.opacity(0.8))
                        .frame(width: 3, height: 3)
                }
                .offset(x: 95, y: 30)
                .opacity(sparkleAnimation ? 1.0 : 0.0)
                
                // 追加の装飾スパークル
                Circle()
                    .fill(Appearance.Color.playerGold.opacity(0.7))
                    .frame(width: 4, height: 4)
                    .offset(x: -40, y: -20)
                    .opacity(sparkleAnimation ? 0.8 : 0.0)
                
                Circle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .offset(x: 50, y: 10)
                    .opacity(sparkleAnimation ? 0.9 : 0.0)
                
                Circle()
                    .fill(Appearance.Color.commonWhite.opacity(0.8))
                    .frame(width: 2, height: 2)
                    .offset(x: 20, y: -40)
                    .opacity(sparkleAnimation ? 1.0 : 0.0)
                
                Circle()
                    .fill(Appearance.Color.playerGold.opacity(0.5))
                    .frame(width: 3, height: 3)
                    .offset(x: -20, y: 25)
                    .opacity(sparkleAnimation ? 0.7 : 0.0)
            }
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: sparkleAnimation)
        }
    }
    
    // MARK: - Animation Properties
    
    private func offsetX(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        
        switch animationPhase {
        case .hidden:
            return screenWidth // 画面右端の外側
        case .entering:
            return 0 // 画面中央
        case .staying:
            return 0 // 画面中央で停止
        case .exiting:
            return -screenWidth // 画面左端の外側
        }
    }
    
    private var opacity: Double {
        switch animationPhase {
        case .hidden:
            return 0.0
        case .entering, .staying, .exiting:
            return 1.0
        }
    }
    
    // MARK: - Animation Control
    
    private func startAnimation() {
        // 初期状態: 画面右端の外側
        animationPhase = .hidden
        
        // フェーズ1: 右から中央へ移動（1秒）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 1.0)) {
                animationPhase = .entering
            }
        }
        
        // フェーズ2: 中央で停止（1秒間）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            animationPhase = .staying
        }
        
        // フェーズ3: 中央から左へ移動（1秒）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            withAnimation(.easeIn(duration: 1.0)) {
                animationPhase = .exiting
            }
        }
    }
    
    private func startContinuousAnimations() {
        // スパークルアニメーション開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            sparkleAnimation = true
        }
        
        // グローアニメーション開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private var luxuryAnnouncementBackground: some View {
        ZStack {
            // ベース背景（深いグラデーション）
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 0.05, green: 0.02, blue: 0.1), location: 0.0),
                            .init(color: Appearance.Color.commonBlack.opacity(0.98), location: 0.3),
                            .init(color: Color(red: 0.1, green: 0.05, blue: 0.2).opacity(0.95), location: 0.6),
                            .init(color: Appearance.Color.commonBlack.opacity(0.99), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
            
            // 金箔効果レイヤー
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.playerGold.opacity(0.15), location: 0.0),
                            .init(color: Color.yellow.opacity(0.08), location: 0.2),
                            .init(color: Appearance.Color.commonClear, location: 0.4),
                            .init(color: Color.orange.opacity(0.06), location: 0.6),
                            .init(color: Appearance.Color.playerGold.opacity(0.12), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(0.98)
            
            // 内側の光沢エフェクト
            RoundedRectangle(cornerRadius: 23)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.commonWhite.opacity(0.08), location: 0.0),
                            .init(color: Appearance.Color.commonClear, location: 0.3),
                            .init(color: Appearance.Color.playerGold.opacity(0.05), location: 0.7),
                            .init(color: Appearance.Color.commonClear, location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .scaleEffect(0.95)
            
            // 宝石風装飾パターン
            VStack {
                HStack {
                    luxuryCornerGem
                    Spacer()
                    luxuryCornerGem
                }
                Spacer()
                HStack {
                    luxuryCornerGem
                    Spacer()
                    luxuryCornerGem
                }
            }
            .padding(15)
        }
    }
    
    @ViewBuilder
    private var luxuryCornerGem: some View {
        ZStack {
            // 宝石のベース
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Color.yellow.opacity(0.8),
                            Appearance.Color.playerGold.opacity(0.6)
                        ]),
                        center: .topLeading,
                        startRadius: 2,
                        endRadius: 8
                    )
                )
                .frame(width: 8, height: 8)
            
            // 宝石の光沢
            Circle()
                .fill(Appearance.Color.commonWhite.opacity(0.6))
                .frame(width: 3, height: 3)
                .offset(x: -1, y: -1)
        }
        .shadow(color: Appearance.Color.playerGold.opacity(0.8), radius: 4, x: 0, y: 0)
    }
    
    @ViewBuilder
    private var luxuryAnnouncementBorder: some View {
        ZStack {
            // 最外側の太いゴールドボーダー（光沢効果付き）
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold.opacity(0.9),
                            Color.yellow,
                            Appearance.Color.playerGold,
                            Color.orange.opacity(0.8),
                            Appearance.Color.playerGold,
                            Color.yellow.opacity(0.9),
                            Appearance.Color.playerGold.opacity(0.8),
                            Color.orange,
                            Appearance.Color.playerGold
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
                .shadow(color: Appearance.Color.playerGold.opacity(0.6), radius: 8, x: 0, y: 0)
            
            // 中間のシルバーボーダー
            RoundedRectangle(cornerRadius: 23)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(0.8),
                            Color.gray.opacity(0.6),
                            Appearance.Color.commonWhite.opacity(0.9),
                            Color.gray.opacity(0.4),
                            Appearance.Color.commonWhite.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .scaleEffect(0.94)
            
            // 内側の細いゴールドボーダー
            RoundedRectangle(cornerRadius: 21)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold.opacity(0.6),
                            Color.yellow.opacity(0.4),
                            Appearance.Color.playerGold.opacity(0.8),
                            Color.orange.opacity(0.5),
                            Appearance.Color.playerGold.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .scaleEffect(0.88)
        }
    }
}

// MARK: - Diamond Shape
/// ダイヤモンド形状
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.closeSubpath()
        
        return path
    }
} 