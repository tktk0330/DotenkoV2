import SwiftUI

// MARK: - Common Animation Manager
/// 宣言ボタン共通のアニメーション管理
class DeclarationButtonAnimationManager: ObservableObject {
    @Published var isPressed = false
    @Published var isBlinking = false
    @Published var heartbeatAnimation = false
    
    private var isEnabled: Bool = false
    
    /// アニメーション開始
    func startAnimations(isEnabled: Bool) {
        self.isEnabled = isEnabled
        isBlinking = isEnabled
        if isEnabled {
            startHeartbeatAnimation()
        } else {
            heartbeatAnimation = false
        }
    }
    
    /// 押下状態更新
    func updatePressedState(_ pressed: Bool) {
        if isEnabled {
            isPressed = pressed
        }
    }
    
    /// 心臓の鼓動のようなリズムアニメーションを開始
    /// ドクン、ドクンという2回の拍動パターンを繰り返す
    private func startHeartbeatAnimation() {
        guard isEnabled else { return }
        
        // 心臓の鼓動パターン: ドクン（0.15秒）→ 休憩（0.1秒）→ ドクン（0.15秒）→ 長い休憩（0.8秒）
        func performHeartbeat() {
            // 1回目の鼓動
            withAnimation(.easeInOut(duration: 0.15)) {
                heartbeatAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.heartbeatAnimation = false
                }
                
                // 短い休憩後、2回目の鼓動
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        self.heartbeatAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.heartbeatAnimation = false
                        }
                        
                        // 長い休憩後、次のサイクル
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if self.isEnabled {
                                performHeartbeat()
                            }
                        }
                    }
                }
            }
        }
        
        performHeartbeat()
    }
}

// MARK: - Common Button Configuration
/// 宣言ボタンの共通設定
struct DeclarationButtonConfig {
    static let size: CGFloat = 100
    static let fontSize: CGFloat = 13
    static let dotenkoFontSize: CGFloat = 14
    static let tracking: CGFloat = 1.0
    static let dotenkoTracking: CGFloat = 1.2
    
    // アニメーション設定
    static let pressedScale: CGFloat = 0.88
    static let blinkingScale: CGFloat = 1.15
    static let heartbeatScale: CGFloat = 1.12
    static let pressAnimationDuration: Double = 0.1
    static let blinkAnimationDuration: Double = 0.5
}

// MARK: - Common Text Style
/// カジノ風立体テキストスタイル
struct CasinoTextStyle: View {
    let text: String
    let fontSize: CGFloat
    let tracking: CGFloat
    let gradient: LinearGradient
    let glowColor: Color
    
    var body: some View {
        ZStack {
            // テキストの深い影（立体感の基盤）
            Text(text)
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(Appearance.Color.commonBlack.opacity(0.8))
                .tracking(tracking)
                .offset(x: 2, y: 3)
            
            // メインテキスト（カジノ風グラデーション）
            Text(text)
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundStyle(gradient)
                .tracking(tracking)
                .shadow(color: Appearance.Color.commonBlack.opacity(0.9), radius: 2, x: 1, y: 2)
                .shadow(color: glowColor.opacity(0.8), radius: 4, x: 0, y: 0)
                .multilineTextAlignment(.center)
            
            // カジノ風の輝きエフェクト
            Text(text)
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                .tracking(tracking)
                .blur(radius: 1)
                .offset(x: -1, y: -1)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Common Circular Background
/// 円形パチンコボタン背景
struct CircularPachinkoBackground: View {
    let centerColor: Color
    let midColor: Color
    let outerColor: Color
    let edgeColor: Color
    let glowColor: Color
    let borderColors: [Color]
    let ringColors: [Color]
    let isEnabled: Bool
    
    var body: some View {
        ZStack {
            // 最下層: 深い影（立体感の基盤）
            Circle()
                .fill(Appearance.Color.commonBlack.opacity(0.9))
                .offset(x: 0, y: 8)
                .blur(radius: 6)
            
            // ベース背景（放射状グラデーション）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: centerColor, location: 0.0),
                            .init(color: midColor, location: 0.3),
                            .init(color: outerColor, location: 0.7),
                            .init(color: edgeColor, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .shadow(color: glowColor.opacity(0.9), radius: 15, x: 0, y: 0)
                .shadow(color: Appearance.Color.commonBlack.opacity(0.7), radius: 10, x: 0, y: 6)
            
            // 上部ハイライト（光沢感）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.commonWhite.opacity(0.6), location: 0.0),
                            .init(color: Appearance.Color.commonWhite.opacity(0.3), location: 0.4),
                            .init(color: Appearance.Color.commonClear, location: 0.8)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -8, y: -8)
            
            // 装飾枠線
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: borderColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4.0
                )
                .shadow(color: glowColor.opacity(0.8), radius: 3, x: 0, y: 0)
            
            // 内側の細い枠線
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.8 : 0.3),
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.4 : 0.1),
                            Appearance.Color.commonClear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    ),
                    lineWidth: 2.0
                )
                .scaleEffect(0.85)
            
            // 中央の光沢効果
            if isEnabled {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.4), location: 0.0),
                                .init(color: Appearance.Color.commonWhite.opacity(0.2), location: 0.3),
                                .init(color: Appearance.Color.commonWhite.opacity(0.1), location: 0.6),
                                .init(color: Appearance.Color.commonClear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.4),
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -5, y: -5)
            }
            
            // 外側のリング装飾
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: ringColors),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .scaleEffect(1.05)
                .opacity(isEnabled ? 0.7 : 0.3)
        }
    }
}

// MARK: - Base Declaration Button
/// 宣言ボタンの基底構造
struct BaseDeclarationButton: View {
    let text: String
    let fontSize: CGFloat
    let tracking: CGFloat
    let textGradient: LinearGradient
    let glowColor: Color
    let backgroundConfig: CircularPachinkoBackground
    let action: () -> Void
    let isEnabled: Bool
    
    @StateObject private var animationManager = DeclarationButtonAnimationManager()
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                // 背景
                backgroundConfig
                
                // テキスト
                CasinoTextStyle(
                    text: text,
                    fontSize: fontSize,
                    tracking: tracking,
                    gradient: textGradient,
                    glowColor: glowColor
                )
                
                // 押下時のオーバーレイ
                if animationManager.isPressed && isEnabled {
                    Circle()
                        .fill(Appearance.Color.commonBlack.opacity(0.4))
                        .scaleEffect(0.9)
                }
            }
            .frame(width: DeclarationButtonConfig.size, height: DeclarationButtonConfig.size)
            .scaleEffect(animationManager.isPressed && isEnabled ? DeclarationButtonConfig.pressedScale : 1.0)
            .scaleEffect(animationManager.isBlinking ? DeclarationButtonConfig.blinkingScale : 1.0)
            .scaleEffect(animationManager.heartbeatAnimation ? DeclarationButtonConfig.heartbeatScale : 1.0)
            .animation(.easeInOut(duration: DeclarationButtonConfig.pressAnimationDuration), value: animationManager.isPressed)
            .animation(.easeInOut(duration: DeclarationButtonConfig.blinkAnimationDuration).repeatForever(autoreverses: true), value: animationManager.isBlinking)
            .opacity(isEnabled ? 1.0 : 0.0)
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2000)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            animationManager.updatePressedState(pressing)
        }, perform: {})
        .disabled(!isEnabled)
        .onAppear {
            animationManager.startAnimations(isEnabled: isEnabled)
        }
        .onChange(of: isEnabled) { enabled in
            animationManager.startAnimations(isEnabled: enabled)
        }
    }
}

// MARK: - Dotenko Declaration Button
/// どてんこ宣言専用ボタンコンポーネント（円形パチンコ風赤ボタンデザイン）
struct DotenkoDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        BaseDeclarationButton(
            text: "DOTENKO",
            fontSize: DeclarationButtonConfig.dotenkoFontSize,
            tracking: DeclarationButtonConfig.dotenkoTracking,
            textGradient: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.3),  // 明るいゴールド
                    Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                    Color(red: 0.8, green: 0.6, blue: 0.0),  // 深いゴールド
                    Color(red: 1.0, green: 0.84, blue: 0.0)  // ゴールド
                ]),
                startPoint: .top,
                endPoint: .bottom
            ),
            glowColor: Color(red: 1.0, green: 0.84, blue: 0.0),
            backgroundConfig: CircularPachinkoBackground(
                centerColor: Color(red: 1.0, green: 0.2, blue: 0.2),
                midColor: Color(red: 0.9, green: 0.1, blue: 0.1),
                outerColor: Color(red: 0.7, green: 0.0, blue: 0.0),
                edgeColor: Color(red: 0.4, green: 0.0, blue: 0.0),
                glowColor: Appearance.Color.commonRed,
                borderColors: [
                    Color(red: 1.0, green: 0.84, blue: 0.0),
                    Color(red: 1.0, green: 0.6, blue: 0.0),
                    Color(red: 1.0, green: 0.9, blue: 0.2),
                    Color(red: 1.0, green: 0.84, blue: 0.0),
                    Color(red: 1.0, green: 0.6, blue: 0.0)
                ],
                ringColors: [
                    Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8),
                    Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.6),
                    Color(red: 1.0, green: 0.9, blue: 0.2).opacity(0.9),
                    Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8)
                ],
                isEnabled: isEnabled
            ),
            action: action,
            isEnabled: isEnabled
        )
    }
}

// MARK: - Revenge Declaration Button
/// リベンジ宣言専用ボタンコンポーネント（円形パチンコ風黄色ボタンデザイン）
struct RevengeDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        BaseDeclarationButton(
            text: "REVENGE",
            fontSize: DeclarationButtonConfig.fontSize,
            tracking: DeclarationButtonConfig.tracking,
            textGradient: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.1), // 明るい黄金
                    Color(red: 1.0, green: 0.7, blue: 0.0), // オレンジゴールド
                    Color(red: 0.8, green: 0.5, blue: 0.0), // 深いブロンズ
                    Color(red: 1.0, green: 0.7, blue: 0.0)  // オレンジゴールド
                ]),
                startPoint: .top,
                endPoint: .bottom
            ),
            glowColor: Color.orange,
            backgroundConfig: CircularPachinkoBackground(
                centerColor: Color(red: 1.0, green: 0.9, blue: 0.1),
                midColor: Color(red: 1.0, green: 0.7, blue: 0.0),
                outerColor: Color(red: 0.8, green: 0.5, blue: 0.0),
                edgeColor: Color(red: 0.6, green: 0.3, blue: 0.0),
                glowColor: Color.orange,
                borderColors: [
                    Color(red: 1.0, green: 0.7, blue: 0.0),
                    Color(red: 1.0, green: 0.9, blue: 0.1),
                    Color(red: 0.8, green: 0.5, blue: 0.0),
                    Color(red: 1.0, green: 0.7, blue: 0.0),
                    Color(red: 1.0, green: 0.9, blue: 0.1)
                ],
                ringColors: [
                    Color.orange.opacity(0.8),
                    Color.yellow.opacity(0.6),
                    Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.9),
                    Color.orange.opacity(0.8)
                ],
                isEnabled: isEnabled
            ),
            action: action,
            isEnabled: isEnabled
        )
    }
}

// MARK: - Shotenko Declaration Button
/// しょてんこ宣言専用ボタンコンポーネント（円形パチンコ風青ボタンデザイン）
struct ShotenkoDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        BaseDeclarationButton(
            text: "SHOTENKO",
            fontSize: DeclarationButtonConfig.fontSize,
            tracking: DeclarationButtonConfig.tracking,
            textGradient: LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 1.0), // 明るいシルバー
                    Color(red: 0.9, green: 0.9, blue: 0.9),   // シルバー
                    Color(red: 0.7, green: 0.7, blue: 0.8),   // 深いシルバー
                    Color(red: 0.9, green: 0.9, blue: 0.9)    // シルバー
                ]),
                startPoint: .top,
                endPoint: .bottom
            ),
            glowColor: Color.cyan,
            backgroundConfig: CircularPachinkoBackground(
                centerColor: Color(red: 0.2, green: 0.4, blue: 1.0),
                midColor: Color(red: 0.1, green: 0.3, blue: 0.9),
                outerColor: Color(red: 0.0, green: 0.2, blue: 0.7),
                edgeColor: Color(red: 0.0, green: 0.1, blue: 0.4),
                glowColor: Color.cyan,
                borderColors: [
                    Color(red: 0.9, green: 0.9, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 1.0),
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 0.9, green: 0.9, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 1.0)
                ],
                ringColors: [
                    Color.cyan.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.9),
                    Color.cyan.opacity(0.8)
                ],
                isEnabled: isEnabled
            ),
            action: action,
            isEnabled: isEnabled
        )
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

// MARK: - SwiftUI Previews
/// DOTENKOボタンのプレビュー（パチンコ風赤ボタンデザイン）
struct DotenkoDeclarationButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 有効状態のDOTENKOボタン
            VStack(spacing: 30) {
                Text("パチンコ風DOTENKOボタン")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                DotenkoDeclarationButton(
                    action: {
                        print("DOTENKO宣言！")
                    },
                    isEnabled: true
                )
                
                Text("有効状態 - 赤い立体ボタン")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("DOTENKO有効")
            
            // 無効状態のDOTENKOボタン
            VStack(spacing: 30) {
                Text("無効状態")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                DotenkoDeclarationButton(
                    action: {
                        print("無効状態")
                    },
                    isEnabled: false
                )
                
                Text("無効状態 - 非表示")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("DOTENKO無効")
            
            // 複数ボタン比較プレビュー
            VStack(spacing: 40) {
                Text("宣言ボタン比較")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 30) {
                    VStack(spacing: 10) {
                        DotenkoDeclarationButton(
                            action: { print("DOTENKO!") },
                            isEnabled: true
                        )
                        Text("DOTENKO")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        RevengeDeclarationButton(
                            action: { print("REVENGE!") },
                            isEnabled: true
                        )
                        Text("REVENGE")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        ShotenkoDeclarationButton(
                            action: { print("SHOTENKO!") },
                            isEnabled: true
                        )
                        Text("SHOTENKO")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("ボタン比較")
            
            // アニメーション確認用プレビュー
            AnimationPreviewView()
                .previewDisplayName("アニメーション確認")
        }
    }
}

/// アニメーション確認用プレビュー
struct AnimationPreviewView: View {
    @State private var isPressed = false
    @State private var showButton = true
    
    var body: some View {
        VStack(spacing: 40) {
            Text("アニメーション確認")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            DotenkoDeclarationButton(
                action: {
                    // ボタンを一時的に無効化してアニメーション確認
                    showButton = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showButton = true
                    }
                },
                isEnabled: showButton
            )
            
            VStack(spacing: 15) {
                Text("特徴:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 赤ベースの立体的デザイン")
                    Text("• パチンコボタン風の光沢感")
                    Text("• 金色装飾枠線")
                    Text("• 常時グローアニメーション")
                    Text("• 強い押し込み効果")
                    Text("• 赤いグロー効果")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Button("リセット") {
                showButton = true
            }
            .padding()
            .background(Color.blue.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.2, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
} 
