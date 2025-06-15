import SwiftUI

// MARK: - Animation Types
/// どてんこアニメーションの種類
enum DotenkoAnimationType {
    case dotenko    // どてんこ（赤・オレンジ・黄色）
    case shotenko   // しょてんこ（青・シアン・緑）
    case revenge    // リベンジ（紫・ピンク・マゼンタ）
    case burst      // バースト（赤・黒・ダークレッド）
}

// MARK: - Dotenko Logo Animation View
/// どてんこ宣言時のロゴアニメーション表示コンポーネント
/// TOP画面のロゴアニメーションと同じシステムを使用
struct DotenkoLogoAnimationView: View {
    let title: String
    let subtitle: String
    let isVisible: Bool
    let colorType: DotenkoAnimationType
    let onComplete: (() -> Void)?
    
    @State private var logoAnimationState = DotenkoLogoAnimationState()
    
    var body: some View {
        if isVisible {
            // メインコンテンツ（カード吹雪削除）
            VStack(spacing: 20) {
                // DOTENKOロゴ
                DotenkoLogoView(animationState: logoAnimationState, title: title, colorType: colorType)
                
                // サブタイトル
                if !subtitle.isEmpty {
                    DotenkoSubtitleView(animationState: logoAnimationState, subtitle: subtitle, colorType: colorType)
                }
            }
            .allowsHitTesting(false) // タッチイベントを完全に無効化
            .zIndex(99999) // 確実に最前面に表示
            .onAppear {
                startDotenkoAnimation()
            }
            .onChange(of: isVisible) { visible in
                if visible {
                    startDotenkoAnimation()
                } else {
                    resetAnimation()
                }
            }
        }
    }
    
    // MARK: - Animation Control
    
    /// どてんこアニメーションを開始
    private func startDotenkoAnimation() {
        DotenkoLogoAnimationController.startAnimations(state: $logoAnimationState)
        
        // アニメーション完了後にコールバック実行
        let totalDuration = DotenkoAnimationConfig.Logo.totalAnimationDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            onComplete?()
        }
    }
    
    /// アニメーションをリセット
    private func resetAnimation() {
        logoAnimationState = DotenkoLogoAnimationState()
    }
}

// MARK: - Dotenko Logo Animation State
struct DotenkoLogoAnimationState {
    var isGlowing = false
    var colorShift = false
    var scale: CGFloat = DotenkoAnimationConfig.Logo.initialScale
    var opacity: Double = DotenkoAnimationConfig.Logo.initialOpacity
    var rotation: Double = DotenkoAnimationConfig.Logo.initialRotation
    var offset: CGSize = DotenkoAnimationConfig.Logo.initialOffset
}

// MARK: - Dotenko Logo View
struct DotenkoLogoView: View {
    let animationState: DotenkoLogoAnimationState
    let title: String
    let colorType: DotenkoAnimationType
    
    var body: some View {
        Text(title)
            .font(.system(
                size: DotenkoAnimationConfig.Logo.fontSize,
                weight: .black,
                design: .rounded
            ))
            .foregroundStyle(logoGradient)
            .shadow(
                color: .black,
                radius: DotenkoAnimationConfig.Logo.shadowRadius,
                x: DotenkoAnimationConfig.Logo.shadowOffset.x,
                y: DotenkoAnimationConfig.Logo.shadowOffset.y
            )
            .scaleEffect(animationState.scale * (animationState.isGlowing ? DotenkoAnimationConfig.Logo.glowScale : 1.0))
            .rotationEffect(.degrees(animationState.rotation))
            .offset(animationState.offset)
            .opacity(animationState.opacity)
            .animation(
                .easeInOut(duration: DotenkoAnimationConfig.Logo.glowDuration)
                .repeatForever(autoreverses: true),
                value: animationState.isGlowing
            )
            .animation(
                .easeInOut(duration: DotenkoAnimationConfig.Logo.colorShiftDuration)
                .repeatForever(autoreverses: true),
                value: animationState.colorShift
            )
    }
    
    private var logoGradient: LinearGradient {
        let colors = DotenkoAnimationConfig.Color.getColors(for: colorType)
        return LinearGradient(
            gradient: Gradient(colors: animationState.colorShift ? 
                colors.alternate : 
                colors.primary
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Dotenko Subtitle View
struct DotenkoSubtitleView: View {
    let animationState: DotenkoLogoAnimationState
    let subtitle: String
    let colorType: DotenkoAnimationType
    
    var body: some View {
        Text(subtitle)
            .font(.system(
                size: DotenkoAnimationConfig.Subtitle.fontSize,
                weight: .bold,
                design: .rounded
            ))
            .foregroundStyle(subtitleGradient)
            .shadow(
                color: .black,
                radius: DotenkoAnimationConfig.Subtitle.shadowRadius,
                x: DotenkoAnimationConfig.Subtitle.shadowOffset.x,
                y: DotenkoAnimationConfig.Subtitle.shadowOffset.y
            )
            .scaleEffect(animationState.isGlowing ? DotenkoAnimationConfig.Subtitle.glowScale : 1.0)
            .opacity(animationState.opacity)
            .animation(
                .easeInOut(duration: DotenkoAnimationConfig.Subtitle.glowDuration)
                .repeatForever(autoreverses: true),
                value: animationState.isGlowing
            )
    }
    
    private var subtitleGradient: LinearGradient {
        let colors = DotenkoAnimationConfig.Color.getColors(for: colorType)
        return LinearGradient(
            gradient: Gradient(colors: animationState.colorShift ? 
                colors.alternate : 
                colors.primary
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}



// MARK: - Animation Controllers

/// どてんこロゴアニメーション制御
struct DotenkoLogoAnimationController {
    static func startAnimations(state: Binding<DotenkoLogoAnimationState>) {
        startLogoEntranceAnimation(state: state)
    }
    
    private static func startLogoEntranceAnimation(state: Binding<DotenkoLogoAnimationState>) {
        // フェーズ1: 斜めから迫ってくる
        withAnimation(.easeOut(duration: DotenkoAnimationConfig.Logo.entranceDuration)) {
            state.wrappedValue.scale = 1.0
            state.wrappedValue.opacity = 1.0
            state.wrappedValue.rotation = 0.0
            state.wrappedValue.offset = .zero
        }
        
        // フェーズ2: 巨大バウンス
        DispatchQueue.main.asyncAfter(deadline: .now() + DotenkoAnimationConfig.Logo.entranceDuration * 0.7) {
            withAnimation(.easeInOut(duration: DotenkoAnimationConfig.Logo.bounceDuration)) {
                state.wrappedValue.scale = DotenkoAnimationConfig.Logo.bounceScale
                state.wrappedValue.rotation = DotenkoAnimationConfig.Logo.bounceRotation
            }
            
            // フェーズ3: 最終位置に落ち着く
            DispatchQueue.main.asyncAfter(deadline: .now() + DotenkoAnimationConfig.Logo.bounceDuration) {
                withAnimation(.easeOut(duration: DotenkoAnimationConfig.Logo.settleDuration)) {
                    state.wrappedValue.scale = 1.0
                    state.wrappedValue.rotation = 0.0
                }
                
                // フェーズ4: 通常アニメーション開始
                DispatchQueue.main.asyncAfter(deadline: .now() + DotenkoAnimationConfig.Logo.settleDuration) {
                    state.wrappedValue.isGlowing = true
                    state.wrappedValue.colorShift = true
                }
            }
        }
    }
}



// MARK: - Configuration

/// どてんこアニメーション全体の設定
struct DotenkoAnimationConfig {
    
    struct Logo {
        static let fontSize: CGFloat = 64
        static let shadowRadius: CGFloat = 6
        static let shadowOffset = (x: CGFloat(3), y: CGFloat(3))
        static let glowScale: CGFloat = 1.08
        static let glowDuration: Double = 1.2
        static let colorShiftDuration: Double = 2.5
        
        // 初期状態
        static let initialScale: CGFloat = 0.01
        static let initialOpacity: Double = 0.0
        static let initialRotation: Double = -45.0
        static let initialOffset = CGSize(width: -200, height: 200)
        
        // 登場アニメーション
        static let entranceDuration: Double = 1.0
        static let bounceDuration: Double = 0.25
        static let settleDuration: Double = 0.3
        static let bounceScale: CGFloat = 6.75
        static let bounceRotation: Double = 15.0
        static let entranceDelay: Double = 0.6
        
        // 総アニメーション時間
        static let totalAnimationDuration: Double = entranceDuration + bounceDuration + settleDuration + 2.0 // グロー表示時間
    }
    
    struct Subtitle {
        static let fontSize: CGFloat = 24
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = (x: CGFloat(2), y: CGFloat(2))
        static let glowScale: CGFloat = 1.05
        static let glowDuration: Double = 1.2
    }
    
    struct Color {
        // どてんこ用（赤・オレンジ・黄色）
        static let dotenkoPrimaryColors: [SwiftUI.Color] = [.red, .orange, .yellow, .orange, .red]
        static let dotenkoAlternateColors: [SwiftUI.Color] = [.yellow, .orange, .red, .orange, .yellow]
        
        // しょてんこ用（青・シアン・緑）
        static let shotenkoPrimaryColors: [SwiftUI.Color] = [.blue, .cyan, .green, .cyan, .blue]
        static let shotenkoAlternateColors: [SwiftUI.Color] = [.green, .cyan, .blue, .cyan, .green]
        
        // リベンジ用（紫・ピンク・マゼンタ）
        static let revengePrimaryColors: [SwiftUI.Color] = [.purple, .pink, .pink, .purple]
        static let revengeAlternateColors: [SwiftUI.Color] = [.pink, .purple, .pink]
        
        // バースト用（赤・黒・ダークレッド）
        static let burstPrimaryColors: [SwiftUI.Color] = [.red, .black, .red.opacity(0.8), .black, .red]
        static let burstAlternateColors: [SwiftUI.Color] = [.black, .red, .black, .red.opacity(0.6), .black]
        
        /// アニメーションタイプに応じた色を取得
        static func getColors(for type: DotenkoAnimationType) -> (primary: [SwiftUI.Color], alternate: [SwiftUI.Color]) {
            switch type {
            case .dotenko:
                return (primary: dotenkoPrimaryColors, alternate: dotenkoAlternateColors)
            case .shotenko:
                return (primary: shotenkoPrimaryColors, alternate: shotenkoAlternateColors)
            case .revenge:
                return (primary: revengePrimaryColors, alternate: revengeAlternateColors)
            case .burst:
                return (primary: burstPrimaryColors, alternate: burstAlternateColors)
            }
        }
    }
    
}

// MARK: - Preview
#if DEBUG
struct DotenkoLogoAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color.black.ignoresSafeArea()
                
                DotenkoLogoAnimationView(
                    title: "どてんこ！",
                    subtitle: "プレイヤーの勝利宣言",
                    isVisible: true,
                    colorType: .dotenko,
                    onComplete: {
                        print("アニメーション完了")
                    }
                )
            }
            .previewDisplayName("どてんこアニメーション")
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                DotenkoLogoAnimationView(
                    title: "バースト！",
                    subtitle: "プレイヤーの手札上限敗北",
                    isVisible: true,
                    colorType: .burst,
                    onComplete: {
                        print("バーストアニメーション完了")
                    }
                )
            }
            .previewDisplayName("バーストアニメーション")
        }
    }
}
#endif 
