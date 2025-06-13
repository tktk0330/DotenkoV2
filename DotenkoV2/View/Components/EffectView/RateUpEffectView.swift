import SwiftUI

/// レートアップ時のオレンジ色矢印群エフェクト
struct RateUpEffectView: View {
    // MARK: - Properties
    let isVisible: Bool
    let multiplier: Int
    
    @State private var arrowAnimations: [ArrowAnimation] = []
    @State private var showMultiplierText: Bool = false
    
    // MARK: - Constants
    private enum EffectConstants {
        // MARK: 矢印のサイズ・配置設定
        static let arrowWidth: CGFloat = 35
        static let arrowHeight: CGFloat = 50
        static let arrowSpacing: CGFloat = 15
        
        // MARK: アニメーション速度調整 - ここを変更してスピードを調整
        static let waveCount: Int = 5                    // 矢印の発射回数（多いほど密集）
        static let waveInterval: Double = 0.3            // 各ウェーブ間の間隔（短いほど高速発射）
        static let animationDuration: Double = 1.5       // 矢印の移動時間（短いほど高速移動）
        static let fadeOutDuration: Double = 0.4         // フェードアウト時間
        static let fadeOutDelay: Double = 1.4            // フェードアウト開始タイミング
        
        // MARK: テキストアニメーション速度調整
        static let textShowDelay: Double = 0.1           // テキスト表示開始タイミング
        static let textHideDelay: Double = 1.5           // テキスト非表示開始タイミング
        static let textAnimationDuration: Double = 0.3   // テキストのフェード時間
        
        // MARK: エフェクトの強度設定
        static let maxOffsetY: CGFloat = 900             // 矢印の移動距離（大きいほど長距離移動）
        static let maxScale: CGFloat = 2.0               // 矢印の最大拡大率
        static let shadowRadius: CGFloat = 6
        static let glowRadius: CGFloat = 12
        static let zIndexValue: Double = 99998
    }
    
    // MARK: - Arrow Animation Model
    private struct ArrowAnimation: Identifiable {
        let id = UUID()
        var offsetY: CGFloat = 0
        var opacity: Double = 1.0
        var scale: CGFloat = 1.0
        let startX: CGFloat
        let delay: Double
    }
    
    // MARK: - Body
    var body: some View {
        if isVisible {
            GeometryReader { geometry in
                ZStack {
                    arrowsView
                    multiplierTextView(geometry: geometry)
                }
                .onAppear {
                    setupEffect(screenWidth: geometry.size.width)
                }
            }
            .allowsHitTesting(false)
            .zIndex(EffectConstants.zIndexValue)
            .onChange(of: isVisible) { _, visible in
                handleVisibilityChange(visible)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                handleOrientationChange()
            }
            .onDisappear {
                resetEffect()
            }
            .id(isVisible)
        }
    }
    
    // MARK: - View Components
    
    /// 矢印群のビュー
    private var arrowsView: some View {
        ForEach(arrowAnimations) { arrow in
            ArrowShape()
                .fill(arrowGradient)
                .frame(width: EffectConstants.arrowWidth, height: EffectConstants.arrowHeight)
                .shadow(color: Color.orange.opacity(0.7), radius: EffectConstants.shadowRadius, x: 0, y: 0)
                .shadow(color: Color.red.opacity(0.4), radius: 3, x: 0, y: 0)
                .scaleEffect(arrow.scale)
                .opacity(arrow.opacity)
                .position(x: arrow.startX, y: UIScreen.main.bounds.height - arrow.offsetY)
        }
    }
    
    /// レート倍率テキストのビュー
    private func multiplierTextView(geometry: GeometryProxy) -> some View {
        Group {
            if showMultiplierText {
                VStack(spacing: 8) {
                    rateUpText
                    multiplierText
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .scaleEffect(showMultiplierText ? 1.0 : 0.5)
                .opacity(showMultiplierText ? 1.0 : 0.0)
                .animation(.easeOut(duration: EffectConstants.textAnimationDuration), value: showMultiplierText)
            }
        }
    }
    
    /// "RATE UP"テキスト
    private var rateUpText: some View {
        Text("RATE UP")
            .font(.system(size: 36, weight: .black))
            .foregroundColor(Color.orange)
            .tracking(3.0)
            .shadow(color: Appearance.Color.commonBlack, radius: 4, x: 0, y: 3)
            .shadow(color: Color.orange.opacity(0.9), radius: EffectConstants.glowRadius, x: 0, y: 0)
            .shadow(color: Color.red.opacity(0.6), radius: 8, x: 0, y: 0)
    }
    
    /// 倍率テキスト
    private var multiplierText: some View {
        Text("×\(multiplier)")
            .font(.system(size: 48, weight: .black))
            .foregroundColor(Color.yellow)
            .tracking(2.0)
            .shadow(color: Appearance.Color.commonBlack, radius: 5, x: 0, y: 3)
            .shadow(color: Color.yellow.opacity(0.9), radius: 15, x: 0, y: 0)
            .shadow(color: Color.orange.opacity(0.7), radius: 10, x: 0, y: 0)
    }
    
    /// 矢印のグラデーション
    private var arrowGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.orange,
                Color.red.opacity(0.8),
                Color.yellow.opacity(0.9)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    // MARK: - Animation Methods
    
    /// エフェクトのセットアップ
    private func setupEffect(screenWidth: CGFloat) {
        generateArrows(screenWidth: screenWidth)
        startArrowAnimations()
    }
    
    /// 画面サイズに応じて矢印を生成
    private func generateArrows(screenWidth: CGFloat) {
        let arrowCount = calculateArrowCount(screenWidth: screenWidth)
        let actualSpacing = calculateActualSpacing(screenWidth: screenWidth, arrowCount: arrowCount)
        
        var allArrows: [ArrowAnimation] = []
        
        for wave in 0..<EffectConstants.waveCount {
            let waveArrows = createWaveArrows(
                waveIndex: wave,
                arrowCount: arrowCount,
                actualSpacing: actualSpacing
            )
            allArrows.append(contentsOf: waveArrows)
        }
        
        arrowAnimations = allArrows
    }
    
    /// 矢印の数を計算
    private func calculateArrowCount(screenWidth: CGFloat) -> Int {
        let totalArrowWidth = EffectConstants.arrowWidth + EffectConstants.arrowSpacing
        return Int(screenWidth / totalArrowWidth)
    }
    
    /// 実際の間隔を計算
    private func calculateActualSpacing(screenWidth: CGFloat, arrowCount: Int) -> CGFloat {
        let totalArrowWidth = CGFloat(arrowCount) * EffectConstants.arrowWidth
        return (screenWidth - totalArrowWidth) / CGFloat(arrowCount + 1)
    }
    
    /// ウェーブごとの矢印を作成
    private func createWaveArrows(waveIndex: Int, arrowCount: Int, actualSpacing: CGFloat) -> [ArrowAnimation] {
        let waveDelay = Double(waveIndex) * EffectConstants.waveInterval
        
        return (0..<arrowCount).map { index in
            ArrowAnimation(
                startX: calculateArrowStartX(index: index, actualSpacing: actualSpacing),
                delay: waveDelay + Double.random(in: 0.0...0.1)
            )
        }
    }
    
    /// 矢印の開始X座標を計算
    private func calculateArrowStartX(index: Int, actualSpacing: CGFloat) -> CGFloat {
        return actualSpacing + (CGFloat(index) * (EffectConstants.arrowWidth + actualSpacing)) + (EffectConstants.arrowWidth / 2)
    }
    
    /// 矢印のアニメーションを開始
    /// 【スピード調整ポイント】ここでアニメーション全体の流れを制御
    private func startArrowAnimations() {
        animateArrows()
        scheduleTextAnimations()
    }
    
    /// 矢印のアニメーション実行
    private func animateArrows() {
        for (index, _) in arrowAnimations.enumerated() {
            let delay = arrowAnimations[index].delay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard index < arrowAnimations.count else { return }
                animateArrow(at: index)
            }
        }
    }
    
    /// 個別の矢印をアニメーション
    /// 【スピード調整ポイント】animationDurationを変更すると矢印の移動速度が変わる
    private func animateArrow(at index: Int) {
        withAnimation(.linear(duration: EffectConstants.animationDuration)) {
            arrowAnimations[index].offsetY = EffectConstants.maxOffsetY
            arrowAnimations[index].scale = EffectConstants.maxScale
        }
        
        scheduleArrowFadeOut(at: index)
    }
    
    /// 矢印のフェードアウトをスケジュール
    private func scheduleArrowFadeOut(at index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.fadeOutDelay) {
            guard index < arrowAnimations.count else { return }
            withAnimation(.linear(duration: EffectConstants.fadeOutDuration)) {
                arrowAnimations[index].opacity = 0.0
            }
        }
    }
    
    /// テキストアニメーションをスケジュール
    private func scheduleTextAnimations() {
        // テキスト表示
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.textShowDelay) {
            showMultiplierText = true
        }
        
        // テキスト非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.textHideDelay) {
            withAnimation(.easeIn(duration: EffectConstants.textAnimationDuration)) {
                showMultiplierText = false
            }
        }
    }
    
    // MARK: - Event Handlers
    
    /// 表示状態変更の処理
    private func handleVisibilityChange(_ visible: Bool) {
        if !visible {
            resetEffect()
        }
    }
    
    /// 画面回転の処理
    private func handleOrientationChange() {
        if isVisible {
            resetEffect()
        }
    }
    
    /// エフェクトをリセット
    private func resetEffect() {
        arrowAnimations.removeAll()
        showMultiplierText = false
    }
}

// MARK: - Arrow Shape

/// 矢印の形状（太く迫力のあるデザイン）
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // 矢印の形状座標を定義
        let arrowPoints: [(CGFloat, CGFloat)] = [
            (0.5, 0),      // 先端
            (0.15, 0.35),  // 左の羽根
            (0.35, 0.35),  // 左の軸接続
            (0.35, 1),     // 左の軸下
            (0.65, 1),     // 右の軸下
            (0.65, 0.35),  // 右の軸接続
            (0.85, 0.35)   // 右の羽根
        ]
        
        // パスを構築
        for (index, point) in arrowPoints.enumerated() {
            let cgPoint = CGPoint(x: width * point.0, y: height * point.1)
            if index == 0 {
                path.move(to: cgPoint)
            } else {
                path.addLine(to: cgPoint)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        RateUpEffectView(isVisible: true, multiplier: 4)
    }
    .previewDisplayName("Rate Up Effect")
}

/*
 MARK: - アニメーションスピード調整ガイド
 
 【高速化したい場合】
 - waveInterval: 0.3 → 0.1-0.2 (ウェーブ間隔を短縮)
 - animationDuration: 1.8 → 1.0-1.5 (矢印移動を高速化)
 - textHideDelay: 1.5 → 1.0 (テキスト表示時間を短縮)
 
 【低速化したい場合】
 - waveInterval: 0.3 → 0.5-0.8 (ウェーブ間隔を延長)
 - animationDuration: 1.8 → 2.5-3.0 (矢印移動をゆっくり)
 - textHideDelay: 1.5 → 2.0-2.5 (テキスト表示時間を延長)
 
 【密度調整】
 - waveCount: 5 → 3-8 (矢印の発射回数)
 - arrowSpacing: 15 → 10-25 (矢印間の間隔)
 
 【エフェクト強度】
 - maxScale: 2.0 → 1.5-3.0 (矢印の拡大率)
 - maxOffsetY: 900 → 600-1200 (矢印の移動距離)
 */ 
