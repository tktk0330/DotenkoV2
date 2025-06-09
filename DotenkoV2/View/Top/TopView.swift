import SwiftUI

// MARK: - Main View
struct TopView: View {
    
    @ObservedObject var navigator: NavigationStateManager
    
    // MARK: - Animation States
    @State private var logoAnimationState = LogoAnimationState()
    @State private var cardAnimations: [CardAnimation] = []
    
    var body: some View {
        ZStack {
            // 背景カードアニメーション
            CardAnimationLayer(cardAnimations: cardAnimations)
            
            // メインコンテンツ
            MainContentView(
                navigator: navigator,
                logoAnimationState: $logoAnimationState
            )
        }
        .onAppear {
            LogoAnimationController.startAnimations(state: $logoAnimationState) {
                CardAnimationController.startCardAnimations(cardAnimations: $cardAnimations)
            }
        }
    }
}

// MARK: - Logo Animation State
struct LogoAnimationState {
    var isGlowing = false
    var colorShift = false
    var scale: CGFloat = TopViewConfig.Logo.initialScale
    var opacity: Double = TopViewConfig.Logo.initialOpacity
    var rotation: Double = TopViewConfig.Logo.initialRotation
    var offset: CGSize = TopViewConfig.Logo.initialOffset
}

// MARK: - Card Animation Layer
struct CardAnimationLayer: View {
    let cardAnimations: [CardAnimation]
    
    var body: some View {
        ForEach(cardAnimations, id: \.id) { cardAnim in
            CardView(card: cardAnim.card, size: TopViewConfig.Card.size)
                .position(cardAnim.position)
                .rotationEffect(.degrees(cardAnim.rotation))
                .opacity(cardAnim.opacity)
                .animation(.linear(duration: cardAnim.duration), value: cardAnim.position)
                .animation(.linear(duration: cardAnim.duration), value: cardAnim.rotation)
                .animation(.linear(duration: cardAnim.duration), value: cardAnim.opacity)
        }
    }
}

// MARK: - Main Content View
struct MainContentView: View {
    let navigator: NavigationStateManager
    @Binding var logoAnimationState: LogoAnimationState
    
    var body: some View {
        VStack(spacing: TopViewConfig.Layout.verticalSpacing) {
            Spacer()
            
            // DOTENKOロゴ
            LogoView(animationState: logoAnimationState)
            
            Spacer()
            
            // Startボタン
            StartButtonView(
                navigator: navigator,
                animationState: logoAnimationState
            )
            
            Spacer().frame(height: TopViewConfig.Layout.bottomSpacing)
        }
        .padding()
    }
}

// MARK: - Logo View
struct LogoView: View {
    let animationState: LogoAnimationState
    
    var body: some View {
        Text("DOTENKO")
            .font(.system(
                size: TopViewConfig.Logo.fontSize,
                weight: .black,
                design: .rounded
            ))
            .foregroundStyle(logoGradient)
            .shadow(
                color: .black,
                radius: TopViewConfig.Logo.shadowRadius,
                x: TopViewConfig.Logo.shadowOffset.x,
                y: TopViewConfig.Logo.shadowOffset.y
            )
            .scaleEffect(animationState.scale * (animationState.isGlowing ? TopViewConfig.Logo.glowScale : 1.0))
            .rotationEffect(.degrees(animationState.rotation))
            .offset(animationState.offset)
            .opacity(animationState.opacity)
            .animation(
                .easeInOut(duration: TopViewConfig.Logo.glowDuration)
                .repeatForever(autoreverses: true),
                value: animationState.isGlowing
            )
            .animation(
                .easeInOut(duration: TopViewConfig.Logo.colorShiftDuration)
                .repeatForever(autoreverses: true),
                value: animationState.colorShift
            )
    }
    
    private var logoGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: animationState.colorShift ? 
                TopViewConfig.Color.alternateColors : 
                TopViewConfig.Color.primaryColors
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Start Button View
struct StartButtonView: View {
    let navigator: NavigationStateManager
    let animationState: LogoAnimationState
    
    var body: some View {
        Button(action: {
            navigator.push(
                AnyView(ContentView(bannerHeight: CGFloat(Constant.BANNER_HEIGHT)))
            )
        }) {
            Text("START")
                .font(.system(
                    size: TopViewConfig.Button.fontSize,
                    weight: .black,
                    design: .rounded
                ))
                .foregroundStyle(buttonGradient)
                .shadow(
                    color: .black,
                    radius: TopViewConfig.Button.shadowRadius,
                    x: TopViewConfig.Button.shadowOffset.x,
                    y: TopViewConfig.Button.shadowOffset.y
                )
                .scaleEffect(animationState.isGlowing ? TopViewConfig.Button.glowScale : 1.0)
                .animation(
                    .easeInOut(duration: TopViewConfig.Button.glowDuration)
                    .repeatForever(autoreverses: true),
                    value: animationState.isGlowing
                )
                .animation(
                    .easeInOut(duration: TopViewConfig.Button.colorShiftDuration)
                    .repeatForever(autoreverses: true),
                    value: animationState.colorShift
                )
                .padding(.horizontal, TopViewConfig.Button.horizontalPadding)
                .padding(.vertical, TopViewConfig.Button.verticalPadding)
                .background(buttonBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(animationState.opacity)
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: animationState.colorShift ? 
                TopViewConfig.Color.alternateColors : 
                TopViewConfig.Color.primaryColors
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: TopViewConfig.Button.cornerRadius)
            .fill(Color.black.opacity(TopViewConfig.Button.backgroundOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: TopViewConfig.Button.cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: TopViewConfig.Color.borderColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: TopViewConfig.Button.borderWidth
                    )
            )
    }
}

// MARK: - Animation Controllers

/// ロゴアニメーション制御
struct LogoAnimationController {
    static func startAnimations(
        state: Binding<LogoAnimationState>,
        onComplete: @escaping () -> Void
    ) {
        startLogoEntranceAnimation(state: state)
        
        // カードアニメーション開始（ロゴ登場後）
        DispatchQueue.main.asyncAfter(deadline: .now() + TopViewConfig.Logo.entranceDelay) {
            onComplete()
        }
    }
    
    private static func startLogoEntranceAnimation(state: Binding<LogoAnimationState>) {
        // フェーズ1: 斜めから迫ってくる
        withAnimation(.easeOut(duration: TopViewConfig.Logo.entranceDuration)) {
            state.wrappedValue.scale = 1.0
            state.wrappedValue.opacity = 1.0
            state.wrappedValue.rotation = 0.0
            state.wrappedValue.offset = .zero
        }
        
        // フェーズ2: 巨大バウンス
        DispatchQueue.main.asyncAfter(deadline: .now() + TopViewConfig.Logo.entranceDuration * 0.7) {
            withAnimation(.easeInOut(duration: TopViewConfig.Logo.bounceDuration)) {
                state.wrappedValue.scale = TopViewConfig.Logo.bounceScale
                state.wrappedValue.rotation = TopViewConfig.Logo.bounceRotation
            }
            
            // フェーズ3: 最終位置に落ち着く
            DispatchQueue.main.asyncAfter(deadline: .now() + TopViewConfig.Logo.bounceDuration) {
                withAnimation(.easeOut(duration: TopViewConfig.Logo.settleDuration)) {
                    state.wrappedValue.scale = 1.0
                    state.wrappedValue.rotation = 0.0
                }
                
                // フェーズ4: 通常アニメーション開始
                DispatchQueue.main.asyncAfter(deadline: .now() + TopViewConfig.Logo.settleDuration) {
                    state.wrappedValue.isGlowing = true
                    state.wrappedValue.colorShift = true
                }
            }
        }
    }
}

/// カードアニメーション制御
struct CardAnimationController {
    static func startCardAnimations(cardAnimations: Binding<[CardAnimation]>) {
        Timer.scheduledTimer(withTimeInterval: TopViewConfig.Card.spawnInterval, repeats: true) { _ in
            generateCards(cardAnimations: cardAnimations)
        }
    }
    
    private static func generateCards(cardAnimations: Binding<[CardAnimation]>) {
        DispatchQueue.global(qos: .userInteractive).async {
            let cardGroup = DispatchGroup()
            
            for _ in 0..<TopViewConfig.Card.cardsPerSpawn {
                cardGroup.enter()
                DispatchQueue.main.async {
                    CardGenerator.addRandomCard(to: cardAnimations)
                    cardGroup.leave()
                }
            }
        }
    }
}

/// カード生成器
struct CardGenerator {
    static func addRandomCard(to cardAnimations: Binding<[CardAnimation]>) {
        let randomPlayCard = TopViewConfig.Card.availableCards.randomElement() ?? .spade1
        let screenBounds = UIScreen.main.bounds
        let startPosition = PositionCalculator.generateRandomStartPosition(screenBounds: screenBounds)
        let endPosition = PositionCalculator.generateRandomEndPosition(from: startPosition, screenBounds: screenBounds)
        
        let newCard = CardAnimation(
            id: UUID(),
            card: Card(card: randomPlayCard, location: .deck),
            position: startPosition,
            rotation: Double.random(in: TopViewConfig.Card.rotationRange),
            opacity: TopViewConfig.Card.initialOpacity,
            duration: Double.random(in: TopViewConfig.Card.durationRange)
        )
        
        cardAnimations.wrappedValue.append(newCard)
        
        // アニメーション開始
        DispatchQueue.main.asyncAfter(deadline: .now() + TopViewConfig.Card.animationDelay) {
            CardAnimator.animateCard(cardId: newCard.id, to: endPosition, in: cardAnimations)
        }
        
        // アニメーション終了後に削除
        DispatchQueue.main.asyncAfter(deadline: .now() + newCard.duration + TopViewConfig.Card.cleanupDelay) {
            CardAnimator.removeCard(cardId: newCard.id, from: cardAnimations)
        }
    }
}

/// 位置計算器
struct PositionCalculator {
    static func generateRandomStartPosition(screenBounds: CGRect) -> CGPoint {
        let side = TopViewConfig.Card.SpawnSide.allCases.randomElement() ?? .left
        
        switch side {
        case .left:
            return CGPoint(x: -TopViewConfig.Card.offscreenOffset, y: Double.random(in: 0...screenBounds.height))
        case .right:
            return CGPoint(x: screenBounds.width + TopViewConfig.Card.offscreenOffset, y: Double.random(in: 0...screenBounds.height))
        case .top:
            return CGPoint(x: Double.random(in: 0...screenBounds.width), y: -TopViewConfig.Card.offscreenOffset)
        case .bottom:
            return CGPoint(x: Double.random(in: 0...screenBounds.width), y: screenBounds.height + TopViewConfig.Card.offscreenOffset)
        }
    }
    
    static func generateRandomEndPosition(from startPosition: CGPoint, screenBounds: CGRect) -> CGPoint {
        if startPosition.x < 0 {
            return CGPoint(x: screenBounds.width + TopViewConfig.Card.offscreenOffset, y: Double.random(in: 0...screenBounds.height))
        } else if startPosition.x > screenBounds.width {
            return CGPoint(x: -TopViewConfig.Card.offscreenOffset, y: Double.random(in: 0...screenBounds.height))
        } else if startPosition.y < 0 {
            return CGPoint(x: Double.random(in: 0...screenBounds.width), y: screenBounds.height + TopViewConfig.Card.offscreenOffset)
        } else {
            return CGPoint(x: Double.random(in: 0...screenBounds.width), y: -TopViewConfig.Card.offscreenOffset)
        }
    }
}

/// カードアニメーター
struct CardAnimator {
    static func animateCard(cardId: UUID, to endPosition: CGPoint, in cardAnimations: Binding<[CardAnimation]>) {
        if let index = cardAnimations.wrappedValue.firstIndex(where: { $0.id == cardId }) {
            cardAnimations.wrappedValue[index].position = endPosition
            cardAnimations.wrappedValue[index].rotation += TopViewConfig.Card.totalRotation
            cardAnimations.wrappedValue[index].opacity = TopViewConfig.Card.finalOpacity
        }
    }
    
    static func removeCard(cardId: UUID, from cardAnimations: Binding<[CardAnimation]>) {
        cardAnimations.wrappedValue.removeAll { $0.id == cardId }
    }
}

// MARK: - Configuration

/// TopView全体の設定
struct TopViewConfig {
    
    struct Layout {
        static let verticalSpacing: CGFloat = 80
        static let bottomSpacing: CGFloat = 80
    }
    
    struct Logo {
        static let fontSize: CGFloat = 72
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
    }
    
    struct Button {
        static let fontSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 60
        static let verticalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 25
        static let backgroundOpacity: Double = 0.3
        static let borderWidth: CGFloat = 3
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = (x: CGFloat(2), y: CGFloat(2))
        static let glowScale: CGFloat = 1.05
        static let glowDuration: Double = 1.2
        static let colorShiftDuration: Double = 2.5
    }
    
    struct Color {
        static let primaryColors: [SwiftUI.Color] = [.red, .orange, .yellow, .orange, .red]
        static let alternateColors: [SwiftUI.Color] = [.yellow, .orange, .red, .orange, .yellow]
        static let borderColors: [SwiftUI.Color] = [.yellow, .orange, .red]
    }
    
    struct Card {
        static let spawnInterval: Double = 1.0
        static let cardsPerSpawn: Int = 8
        static let size: CGFloat = 40
        static let initialOpacity: Double = 0.8
        static let finalOpacity: Double = 0.0
        static let durationRange: ClosedRange<Double> = 3...6
        static let rotationRange: ClosedRange<Double> = 0...360
        static let totalRotation: Double = 1080
        static let offscreenOffset: Double = 80
        static let animationDelay: Double = 0.05
        static let cleanupDelay: Double = 0.8
        
        static let availableCards: [PlayCard] = [
            .spade1, .spade2, .spade3, .spade4, .spade5, .spade6, .spade7, .spade8, .spade9, .spade10, .spade11, .spade12, .spade13,
            .heart1, .heart2, .heart3, .heart4, .heart5, .heart6, .heart7, .heart8, .heart9, .heart10, .heart11, .heart12, .heart13,
            .diamond1, .diamond2, .diamond3, .diamond4, .diamond5, .diamond6, .diamond7, .diamond8, .diamond9, .diamond10, .diamond11, .diamond12, .diamond13,
            .club1, .club2, .club3, .club4, .club5, .club6, .club7, .club8, .club9, .club10, .club11, .club12, .club13,
            .back, .blackJoker, .whiteJoker
        ]
        
        enum SpawnSide: CaseIterable {
            case left, right, top, bottom
        }
    }
}

// MARK: - Models

/// カードアニメーションモデル
struct CardAnimation {
    let id: UUID
    let card: Card
    var position: CGPoint
    var rotation: Double
    var opacity: Double
    let duration: Double
}
