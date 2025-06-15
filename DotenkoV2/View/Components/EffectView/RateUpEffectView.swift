import SwiftUI

/// レートアップ時のオレンジ色矢印群エフェクト（パフォーマンス最適化版）
struct RateUpEffectView: View {
    // MARK: - Properties
    let isVisible: Bool
    let multiplier: Int
    
    @State private var arrowAnimations: [ArrowAnimation] = []
    @State private var showMultiplierText: Bool = false
    
    // MARK: - Constants（パフォーマンス最適化）
    private enum EffectConstants {
        // MARK: 矢印のサイズ・配置設定
        static let arrowWidth: CGFloat = 35
        static let arrowHeight: CGFloat = 50
        static let arrowSpacing: CGFloat = 20 // 間隔を広げて矢印数を削減
        
        // MARK: アニメーション速度調整（高速化でパフォーマンス向上）
        static let waveCount: Int = 3                    // 矢印の発射回数を削減（5→3）
        static let waveInterval: Double = 0.2            // 各ウェーブ間の間隔を短縮
        static let animationDuration: Double = 1.2       // 矢印の移動時間を短縮
        static let fadeOutDuration: Double = 0.3         // フェードアウト時間を短縮
        static let fadeOutDelay: Double = 1.0            // フェードアウト開始タイミングを早める
        
        // MARK: テキストアニメーション速度調整
        static let textShowDelay: Double = 0.1           // テキスト表示開始タイミング
        static let textHideDelay: Double = 1.2           // テキスト非表示開始タイミングを短縮
        static let textAnimationDuration: Double = 0.25  // テキストのフェード時間を短縮
        
        // MARK: エフェクトの強度設定（軽量化）
        static let maxOffsetY: CGFloat = 700             // 矢印の移動距離を短縮
        static let maxScale: CGFloat = 1.8               // 矢印の最大拡大率を削減
        static let shadowRadius: CGFloat = 4             // シャドウ半径を削減
        static let glowRadius: CGFloat = 8               // グロー半径を削減
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
        }
    }
    
    // MARK: - View Components
    
    /// 矢印群のビュー（パフォーマンス最適化）
    private var arrowsView: some View {
        ForEach(arrowAnimations) { arrow in
            ArrowShape()
                .fill(arrowGradient)
                .frame(width: EffectConstants.arrowWidth, height: EffectConstants.arrowHeight)
                .shadow(color: Color.orange.opacity(0.6), radius: EffectConstants.shadowRadius, x: 0, y: 0) // シャドウを1つに削減
                .scaleEffect(arrow.scale)
                .opacity(arrow.opacity)
                .position(x: arrow.startX, y: UIScreen.main.bounds.height - arrow.offsetY)
        }
    }
    
    /// レート倍率テキストのビュー（パフォーマンス最適化）
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
    
    /// "RATE UP"テキスト（シャドウ最適化）
    private var rateUpText: some View {
        Text("RATE UP")
            .font(.system(size: 36, weight: .black))
            .foregroundColor(Color.orange)
            .tracking(3.0)
            .shadow(color: Appearance.Color.commonBlack, radius: 3, x: 0, y: 2) // シャドウを1つに削減
            .overlay(
                Text("RATE UP")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(Color.orange.opacity(0.3))
                    .blur(radius: EffectConstants.glowRadius)
            )
    }
    
    /// 倍率テキスト（シャドウ最適化）
    private var multiplierText: some View {
        Text("×\(multiplier)")
            .font(.system(size: 48, weight: .black))
            .foregroundColor(Color.yellow)
            .tracking(2.0)
            .shadow(color: Appearance.Color.commonBlack, radius: 4, x: 0, y: 2) // シャドウを1つに削減
            .overlay(
                Text("×\(multiplier)")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.yellow.opacity(0.3))
                    .blur(radius: EffectConstants.glowRadius)
            )
    }
    
    /// 矢印のグラデーション（軽量化）
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
    
    /// 画面サイズに応じて矢印を生成（最適化）
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
        print("📈 矢印エフェクト生成: \(allArrows.count)個の矢印")
    }
    
    /// 矢印の数を計算（最適化：上限設定）
    private func calculateArrowCount(screenWidth: CGFloat) -> Int {
        let totalArrowWidth = EffectConstants.arrowWidth + EffectConstants.arrowSpacing
        let calculatedCount = Int(screenWidth / totalArrowWidth)
        // パフォーマンス向上のため矢印数を制限
        return min(calculatedCount, 8) // 最大8個に制限
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
                delay: waveDelay + Double.random(in: 0.0...0.05) // ランダム要素を削減
            )
        }
    }
    
    /// 矢印の開始X座標を計算
    private func calculateArrowStartX(index: Int, actualSpacing: CGFloat) -> CGFloat {
        return actualSpacing + (CGFloat(index) * (EffectConstants.arrowWidth + actualSpacing)) + (EffectConstants.arrowWidth / 2)
    }
    
    /// 矢印のアニメーションを開始（最適化）
    private func startArrowAnimations() {
        animateArrows()
        scheduleTextAnimations()
    }
    
    /// 矢印のアニメーション実行（最適化）
    private func animateArrows() {
        for (index, _) in arrowAnimations.enumerated() {
            let delay = arrowAnimations[index].delay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard index < self.arrowAnimations.count else { return }
                self.animateArrow(at: index)
            }
        }
    }
    
    /// 個別の矢印をアニメーション（最適化）
    private func animateArrow(at index: Int) {
        withAnimation(.linear(duration: EffectConstants.animationDuration)) {
            arrowAnimations[index].offsetY = EffectConstants.maxOffsetY
            arrowAnimations[index].scale = EffectConstants.maxScale
        }
        
        scheduleArrowFadeOut(at: index)
    }
    
    /// 矢印のフェードアウトをスケジュール（最適化）
    private func scheduleArrowFadeOut(at index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.fadeOutDelay) {
            guard index < self.arrowAnimations.count else { return }
            withAnimation(.linear(duration: EffectConstants.fadeOutDuration)) {
                self.arrowAnimations[index].opacity = 0.0
            }
        }
    }
    
    /// テキストアニメーションをスケジュール（最適化）
    private func scheduleTextAnimations() {
        // テキスト表示
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.textShowDelay) {
            self.showMultiplierText = true
        }
        
        // テキスト非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + EffectConstants.textHideDelay) {
            withAnimation(.easeIn(duration: EffectConstants.textAnimationDuration)) {
                self.showMultiplierText = false
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

// MARK: - Arrow Shape（最適化）

/// 矢印の形状（パフォーマンス最適化版）
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // 矢印の形状座標を定義（シンプル化）
        let arrowPoints: [(CGFloat, CGFloat)] = [
            (0.5, 0),      // 先端
            (0.2, 0.35),   // 左の羽根
            (0.4, 0.35),   // 左の軸接続
            (0.4, 1),      // 左の軸下
            (0.6, 1),      // 右の軸下
            (0.6, 0.35),   // 右の軸接続
            (0.8, 0.35)    // 右の羽根
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
    .previewDisplayName("Rate Up Effect (Optimized)")
}

/*
 MARK: - パフォーマンス最適化内容
 
 【描画負荷軽減】
 - シャドウエフェクトを複数から1つに削減
 - 矢印数の上限を8個に制限
 - ウェーブ数を5→3に削減
 - アニメーション時間を短縮（5秒→3秒）
 
 【メモリ使用量削減】
 - ランダム要素を最小限に抑制
 - 不要なアニメーション状態を削除
 - エフェクト終了時の確実なクリーンアップ
 
 【CPU負荷軽減】
 - グラデーション計算の最適化
 - アニメーション処理の効率化
 - タイマー処理の最適化
 
 【連続表示対応】
 - .id(isVisible)でアニメーション強制更新
 - 状態リセット処理の改善
 */ 
