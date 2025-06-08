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
                    // メインタイトル
                    Text(title)
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Appearance.Color.commonWhite)
                        .tracking(4.0)
                        .shadow(color: Appearance.Color.commonBlack, radius: 3, x: 0, y: 2)
                        .scaleEffect(glowAnimation ? 1.08 : 1.0)
                    
                    // サブタイトル
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.95))
                            .tracking(1.5)
                            .shadow(color: Appearance.Color.commonBlack, radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
                .background(luxuryAnnouncementBackground)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(luxuryAnnouncementBorder)

                .shadow(color: Appearance.Color.commonBlack.opacity(0.6), radius: 8, x: 0, y: 4)
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
                    glowAnimation = false
                }
            }
        }
    }
    
    // MARK: - Decorative Elements (削除済み)
    
    // MARK: - Animation Properties
    
    /// アニメーションフェーズに応じたX軸オフセットを計算
    /// - Parameter geometry: 画面サイズ情報
    /// - Returns: X軸オフセット値
    private func offsetX(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        
        switch animationPhase {
        case .hidden:
            // 画面右端の外側（定数で定義された余裕を持って）
            return screenWidth + LayoutConstants.AnnouncementAnimation.screenOffsetMargin
        case .entering:
            // 画面中央
            return 0
        case .staying:
            // 画面中央で停止
            return 0
        case .exiting:
            // 画面左端の外側（テキスト幅を考慮して完全に流れ切る）
            return -screenWidth - LayoutConstants.AnnouncementAnimation.textWidthMargin
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
    
    /// アナウンスアニメーションを開始（3フェーズ構成）
    /// フェーズ1: 右から中央へ高速移動 → フェーズ2: 中央で停止 → フェーズ3: 中央から左へ高速移動
    private func startAnimation() {
        // 初期状態: 画面右端の外側
        animationPhase = .hidden
        
        // フェーズ1: 右から中央へ移動（高速化: 0.8秒）
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.AnnouncementAnimation.startDelay) {
            withAnimation(.easeOut(duration: LayoutConstants.AnnouncementAnimation.enteringDuration)) {
                self.animationPhase = .entering
            }
        }
        
        // フェーズ2: 中央で停止（1.5秒間）
        let stayingStartTime = LayoutConstants.AnnouncementAnimation.startDelay + LayoutConstants.AnnouncementAnimation.enteringDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + stayingStartTime) {
            self.animationPhase = .staying
        }
        
        // フェーズ3: 中央から左へ完全に流れ切る（高速化: 1.2秒）
        let exitingStartTime = stayingStartTime + LayoutConstants.AnnouncementAnimation.stayingDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + exitingStartTime) {
            withAnimation(.easeIn(duration: LayoutConstants.AnnouncementAnimation.exitingDuration)) {
                self.animationPhase = .exiting
            }
        }
    }
    
    /// 継続的なアニメーション効果を開始（グロー効果）
    /// 中央停止フェーズで視覚的インパクトを最大化
    private func startContinuousAnimations() {
        // グローアニメーション開始（中央停止時に開始）
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.AnnouncementAnimation.glowStartDelay) {
            withAnimation(.easeInOut(duration: LayoutConstants.AnnouncementAnimation.glowDuration).repeatForever(autoreverses: true)) {
                self.glowAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private var luxuryAnnouncementBackground: some View {
        // キリッとしたシンプルな背景
        RoundedRectangle(cornerRadius: 25)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.95),
                        Appearance.Color.commonBlack.opacity(0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    

    
    @ViewBuilder
    private var luxuryAnnouncementBorder: some View {
        // キリッとしたシンプルなボーダー
        RoundedRectangle(cornerRadius: 25)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.playerGold,
                        Appearance.Color.playerGold.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
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