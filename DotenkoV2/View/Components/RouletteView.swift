/*
 * RouletteView.swift
 * 
 * ファイル概要:
 * ルーレットビュー（プレイヤー選択用）
 * - カジノ風デザインによるプレイヤー選択ルーレット
 * - ターン開始プレイヤーの決定
 * - リアルタイムスピンアニメーション
 * - 統一されたカジノテーマカラーパレット使用
 * 
 * 主要機能:
 * - 2-5人対応の動的セグメント生成
 * - スムーズなスピンアニメーション
 * - 結果表示とコールバック処理
 * - カジノ風グラデーション・エフェクト
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

/// ルーレットビュー（プレイヤー選択用）
struct RouletteView: View {
    // MARK: - Properties
    let players: [Player]
    let onFinish: (String) -> Void
    
    // MARK: - Animation States
    @State private var rotationDegrees: Double = 0
    @State private var isSpinning: Bool = false
    @State private var showResult: Bool = false
    @State private var finalAngle: Double = 0
    @State private var wheelGlowAnimation = false // ルーレット全体のグローアニメーション
    @State private var titleGlowAnimation = false // タイトルのグローアニメーション
    
    // MARK: - Constants
    private let spinDuration: Double = 3.0 // スピン時間（固定）
    private let resultDisplayDelay: Double = 1.0 // 停止後の結果表示までの待機時間
    private let autoStartDelay: Double = 1.0 // 自動開始までの待機時間
    private let spinDecelerationFactor: Double = 0.85 // 減速係数
    
    // レスポンシブ対応の動的サイズ計算
    private func wheelDiameter(for size: CGSize) -> CGFloat {
        let minDimension = min(size.width, size.height)
        let baseDiameter: CGFloat = min(280, minDimension * 0.7)
        return max(200, baseDiameter) // 最小200px、最大は画面の70%
    }
    
    private func indicatorHeight(for wheelSize: CGFloat) -> CGFloat {
        return wheelSize * 0.14 // ルーレットサイズの14%
    }
    
    private func titleFontSize(for size: CGSize) -> CGFloat {
        let baseSize: CGFloat = 28
        let scaleFactor = min(size.width, size.height) / 400
        return max(20, min(32, baseSize * scaleFactor))
    }
    
    private func resultFontSize(for size: CGSize) -> CGFloat {
        let baseSize: CGFloat = 20
        let scaleFactor = min(size.width, size.height) / 400
        return max(16, min(24, baseSize * scaleFactor))
    }
    
    // 参加プレイヤー数の2倍のセグメント数
    private var segmentCount: Int {
        return players.count * 2
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 半透明背景
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // タイトル
                    titleView(geometry.size)
                    
                    // ルーレット本体
                    ZStack {
                        // ルーレット背景
                        wheelBackgroundView(geometry.size)
                        
                        // プレイヤーセグメント
                        wheelSegmentsView(geometry.size)
                            .rotationEffect(.degrees(rotationDegrees))
                        
                        // インジケーター（針）- ルーレット内部に配置
                        indicatorView(geometry.size)
                        
                        // 中央の円
                        centerCircleView(for: geometry.size)
                    }
                    .frame(width: wheelDiameter(for: geometry.size), height: wheelDiameter(for: geometry.size))
                    .scaleEffect(wheelGlowAnimation ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: wheelGlowAnimation)
                    .padding(.vertical, 20)
                    
                    // 結果表示（選択完了時）
                    if showResult {
                        resultView(geometry.size)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // 初期表示時に自動スピン開始
            DispatchQueue.main.asyncAfter(deadline: .now() + autoStartDelay) {
                startSpin()
            }
            
            // グローアニメーション開始
            wheelGlowAnimation = true
            titleGlowAnimation = true
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    
    /// タイトル表示
    private func titleView(_ size: CGSize) -> some View {
        Text("ターン開始プレイヤー")
            .font(.system(size: titleFontSize(for: size), weight: .bold, design: .rounded))
            .foregroundColor(Appearance.Color.primaryText)
            .padding(.top, 20)
            .shadow(color: Appearance.Color.casinoGoldGlow.opacity(0.5), radius: 5, x: 0, y: 0)
            .scaleEffect(titleGlowAnimation ? 1.01 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: titleGlowAnimation)
    }
    
    /// ルーレット背景ビュー
    private func wheelBackgroundView(_ size: CGSize) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.casinoBackgroundTop,
                        Appearance.Color.casinoBackgroundBottom
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: wheelDiameter(for: size)/2
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.accent.opacity(0.8),
                                Appearance.Color.homeButtonDarkGold.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
            )
            .overlay(
                // 内側の光る効果
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.primaryText.opacity(0.1),
                                Appearance.Color.commonClear,
                                Appearance.Color.primaryText.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .padding(2)
            )
            .shadow(color: Appearance.Color.commonBlack.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: Appearance.Color.casinoGoldGlow.opacity(0.3), radius: 16, x: 0, y: 0)
            .shadow(color: Appearance.Color.accent.opacity(0.2), radius: 20, x: 0, y: 0)
            .frame(width: wheelDiameter(for: size), height: wheelDiameter(for: size))
    }
    
    /// ルーレットセグメントビュー
    private func wheelSegmentsView(_ size: CGSize) -> some View {
        ZStack {
            ForEach(0..<segmentCount, id: \.self) { index in
                wheelSegment(for: index, size: size)
            }
        }
        .frame(width: wheelDiameter(for: size), height: wheelDiameter(for: size))
    }
    
    /// 個別のルーレットセグメント
    private func wheelSegment(for index: Int, size: CGSize) -> some View {
        let playerIndex = index % players.count
        let player = players[playerIndex]
        let segmentAngle = 360.0 / Double(segmentCount)
        let startAngle = Double(index) * segmentAngle
        
        return ZStack {
            // セグメントの背景
            segmentBackgroundView(
                startAngle: startAngle,
                segmentAngle: segmentAngle,
                size: size,
                playerIndex: playerIndex
            )
            
            // プレイヤー名テキスト
            SegmentTextView(
                text: player.name,
                angle: startAngle + segmentAngle/2,
                wheelRadius: wheelDiameter(for: size)/2
            )
        }
        .frame(width: wheelDiameter(for: size), height: wheelDiameter(for: size))
    }
    
    /// セグメントの背景ビュー
    private func segmentBackgroundView(
        startAngle: Double,
        segmentAngle: Double,
        size: CGSize,
        playerIndex: Int
    ) -> some View {
        ZStack {
            // メインの背景パス
            segmentPath(startAngle: startAngle, segmentAngle: segmentAngle, size: size)
                .fill(segmentColor(for: playerIndex))
            
            // 境界線
            segmentPath(startAngle: startAngle, segmentAngle: segmentAngle, size: size)
                .stroke(Appearance.Color.primaryText.opacity(0.3), lineWidth: 1)
        }
    }
    
    /// セグメントのパス
    private func segmentPath(startAngle: Double, segmentAngle: Double, size: CGSize) -> Path {
        Path { path in
            let center = CGPoint(x: wheelDiameter(for: size)/2, y: wheelDiameter(for: size)/2)
            let radius = wheelDiameter(for: size)/2
            let innerRadius = radius * 0.3
            
            // 角度をラジアンに変換
            let startAngleRadians = startAngle * .pi / 180
            let endAngleRadians = (startAngle + segmentAngle) * .pi / 180
            
            path.addArc(center: center, radius: radius, startAngle: .degrees(startAngle), endAngle: .degrees(startAngle + segmentAngle), clockwise: false)
            path.addLine(to: CGPoint(x: center.x + cos(endAngleRadians) * innerRadius, y: center.y + sin(endAngleRadians) * innerRadius))
            path.addArc(center: center, radius: innerRadius, startAngle: .degrees(startAngle + segmentAngle), endAngle: .degrees(startAngle), clockwise: true)
            path.closeSubpath()
        }
    }
    
    /// セグメントの色を取得
    private func segmentColor(for playerIndex: Int) -> LinearGradient {
        // プレイヤーごとの専用色を使用
        let playerColors = [
            Appearance.Color.playerGold,    // プレイヤー1: ゴールド
            Appearance.Color.playerBlue,    // プレイヤー2: ブルー
            Appearance.Color.playerGreen,   // プレイヤー3: グリーン
            Appearance.Color.playerOrange,  // プレイヤー4: オレンジ
            Appearance.Color.playerPurple   // プレイヤー5: パープル
        ]
        
        // プレイヤーインデックスに応じた色を選択（配列の範囲外の場合はサイクル）
        let baseColor = playerColors[playerIndex % playerColors.count]
        
        // より暗いグラデーション効果で深みを演出
        return LinearGradient(
            gradient: Gradient(colors: [
                baseColor.opacity(0.6),
                baseColor.opacity(0.4),
                baseColor.opacity(0.2)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// セグメント内のテキスト表示用ビュー
    struct SegmentTextView: View {
        let text: String
        let angle: Double
        let wheelRadius: CGFloat
        
        var body: some View {
            GeometryReader { _ in
                Text(text)
                    .font(.system(size: segmentTextSize, weight: .bold))
                    .foregroundColor(Appearance.Color.primaryText)
                    .shadow(color: Appearance.Color.commonBlack.opacity(0.8), radius: 2, x: 0, y: 1)
                    .fixedSize()
                    .position(
                        x: wheelRadius,
                        y: wheelRadius - wheelRadius * 0.65
                    )
                    .rotationEffect(.degrees(angle))
            }
            .frame(width: wheelRadius * 2, height: wheelRadius * 2)
        }
        
        private var segmentTextSize: CGFloat {
            let baseSize: CGFloat = 11
            let scaleFactor = wheelRadius / 140 // 280直径時のradius140を基準
            return max(8, min(14, baseSize * scaleFactor))
        }
    }
    
    /// インジケータービュー（針）
    private func indicatorView(_ size: CGSize) -> some View {
        let wheelRadius = wheelDiameter(for: size) / 2
        let needleLength = wheelRadius * 0.7 // ルーレットの70%の長さ
        let needleWidth: CGFloat = 6 // 針の幅
        
        return ZStack {
            // 針の本体（細長い長方形）
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.accent,
                            Appearance.Color.homeButtonDarkGold,
                            Appearance.Color.accent.opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: needleWidth, height: needleLength)
                .offset(y: -needleLength/2) // 中央から上向きに配置
            
            // 針の中央の円（軸）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.accent,
                            Appearance.Color.homeButtonDarkGold,
                            Appearance.Color.accent.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 16, height: 16)
        }
        .overlay(
            // 全体の境界線
            ZStack {
                Rectangle()
                    .stroke(Appearance.Color.primaryText.opacity(0.8), lineWidth: 1)
                    .frame(width: needleWidth, height: needleLength)
                    .offset(y: -needleLength/2)
                
                Circle()
                    .stroke(Appearance.Color.primaryText.opacity(0.8), lineWidth: 1)
                    .frame(width: 16, height: 16)
            }
        )
        .shadow(color: Appearance.Color.commonBlack.opacity(0.6), radius: 8, x: 0, y: 4)
        .shadow(color: Appearance.Color.casinoGoldGlow.opacity(0.6), radius: 12, x: 0, y: 0)
        .shadow(color: Appearance.Color.accent.opacity(0.4), radius: 15, x: 0, y: 0)
    }
    
    /// 中央の円ビュー
    private func centerCircleView(for size: CGSize) -> some View {
        let centerSize = wheelDiameter(for: size) * 0.21 // ルーレットサイズの21%
        return Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.cardBackground.opacity(0.8),
                        Appearance.Color.cardBackground
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: centerSize/2
                )
            )
            .frame(width: centerSize, height: centerSize)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.accent,
                                Appearance.Color.homeButtonDarkGold
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                // 内側の光る効果
                Circle()
                    .stroke(Appearance.Color.primaryText.opacity(0.1), lineWidth: 1)
                    .padding(1)
            )
            .shadow(color: Appearance.Color.commonBlack.opacity(0.4), radius: 4, x: 0, y: 2)
            .shadow(color: Appearance.Color.casinoGoldGlow.opacity(0.5), radius: 6, x: 0, y: 0)
            .shadow(color: Appearance.Color.accent.opacity(0.3), radius: 8, x: 0, y: 0)
    }
    
    /// 結果表示ビュー
    private func resultView(_ size: CGSize) -> some View {
        let selectedPlayer = getWinningPlayer()
        let iconSize = min(50, wheelDiameter(for: size) * 0.18)
        
        return VStack(spacing: 12) {
            
            // 結果テキスト
            Text("\(selectedPlayer.name)からスタート！")
                .font(.system(size: resultFontSize(for: size), weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.accent,
                            Appearance.Color.homeButtonDarkGold
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: max(100, wheelDiameter(for: size) * 0.35))
        .padding(16)
        .background(casinoResultBackground)
        .transition(.scale.combined(with: .opacity))
    }
    
    /// カジノ風結果表示背景
    private var casinoResultBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.cardBackground.opacity(0.8),
                        Appearance.Color.cardBackground.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.accent.opacity(0.6),
                                Appearance.Color.homeButtonDarkGold.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                // 内側の光る効果
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.primaryText.opacity(0.1),
                                Appearance.Color.commonClear,
                                Appearance.Color.primaryText.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            )
            .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: Appearance.Color.casinoGoldGlow.opacity(0.2), radius: 12, x: 0, y: 0)
    }
    
    // MARK: - Helper Methods
    
    /// 勝者のプレイヤーを取得
    private func getWinningPlayer() -> Player {
        let segmentAngle = 360.0 / Double(segmentCount)
        // インジケーターは上にあるので、回転方向と逆の角度計算が必要
        // 角度を正規化（0-360度の範囲に収める）
        let negativeAngle = -finalAngle
        let remainderAngle = negativeAngle.truncatingRemainder(dividingBy: 360)
        let normalizedAngle = (remainderAngle + 360).truncatingRemainder(dividingBy: 360)
        let winningSegmentIndex = Int((normalizedAngle / segmentAngle).rounded(.down))
        let winningPlayerIndex = winningSegmentIndex % players.count
        return players[winningPlayerIndex]
    }
    
    /// スピン開始
    private func startSpin() {
        guard !isSpinning else { return }
        
        showResult = false
        isSpinning = true
        
        // ランダムな回転数と角度を設定
        let spins = Double.random(in: 3...5) // 3〜5回転
        let extraAngle = Double.random(in: 0...360) // 追加の角度
        finalAngle = rotationDegrees + (360 * spins) + extraAngle
        
        // アニメーションの実行
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotationDegrees = finalAngle
        }
        
        // スピン終了後の処理
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {
            finishSpin()
        }
    }
    
    /// スピン終了
    private func finishSpin() {
        isSpinning = false
        
        // 結果表示アニメーション
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showResult = true
        }
        
        // 選ばれたプレイヤーの情報を返す（遅延を長く）
        let selectedPlayer = getWinningPlayer()
        
        // 結果表示のための遅延
        DispatchQueue.main.asyncAfter(deadline: .now() + resultDisplayDelay) {
            onFinish(selectedPlayer.id)
        }
    }
}

// MARK: - Preview
struct RouletteView_Previews: PreviewProvider {
    static var previews: some View {
        RouletteView(
            players: [
                Player(id: "player", side: 0, name: "あなた", icon_url: nil, dtnk: false),
                Player(id: "bot1", side: 1, name: "ボット1", icon_url: nil, dtnk: false),
                Player(id: "bot2", side: 2, name: "ボット2", icon_url: nil, dtnk: false),
                Player(id: "bot3", side: 3, name: "ボット3", icon_url: nil, dtnk: false)
            ],
            onFinish: { _ in }
        )
    }
} 
