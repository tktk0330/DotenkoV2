import SwiftUI

// MARK: - Score Result View
/// スコア確定イベント表示画面
struct ScoreResultView: View {
    
    // MARK: - Constants
    private enum ViewConstants {
        static let backgroundOpacity: Double = 0.95
        static let cardSpacing: CGFloat = 15
        static let sectionSpacing: CGFloat = 25
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 110 // 広告エリア分の余白
        static let deckHeight: CGFloat = 200
        static let cardWidth: CGFloat = 120
        static let cardHeight: CGFloat = 168
        static let revealedCardWidth: CGFloat = 80
        static let revealedCardHeight: CGFloat = 112
        static let cardUpwardOffset: CGFloat = -300
        static let cornerRadius: CGFloat = 12
        static let revealedCardCornerRadius: CGFloat = 8
    }
    
    // MARK: - Input Properties
    let winners: [Player] // 勝者配列
    let losers: [Player] // 敗者配列
    let deckBottomCard: Card?
    let consecutiveCards: [Card]
    let baseRate: Int
    let upRate: Int
    let finalMultiplier: Int
    let totalScore: Int
    let isShotenkoRound: Bool
    let isBurstRound: Bool
    let shotenkoWinnerId: String?
    let burstPlayerId: String?
    let onOKAction: () -> Void
    
    // MARK: - State
    @StateObject private var viewModel: ScoreResultViewModel
    
    // MARK: - Initialization
    init(winners: [Player] = [], losers: [Player] = [], deckBottomCard: Card?, consecutiveCards: [Card], 
         baseRate: Int, upRate: Int, finalMultiplier: Int, totalScore: Int,
         isShotenkoRound: Bool = false, isBurstRound: Bool = false,
         shotenkoWinnerId: String? = nil, burstPlayerId: String? = nil,
         onOKAction: @escaping () -> Void) {
        
        self.winners = winners
        self.losers = losers
        self.deckBottomCard = deckBottomCard
        self.consecutiveCards = consecutiveCards
        self.baseRate = baseRate
        self.upRate = upRate
        self.finalMultiplier = finalMultiplier
        self.totalScore = totalScore
        self.isShotenkoRound = isShotenkoRound
        self.isBurstRound = isBurstRound
        self.shotenkoWinnerId = shotenkoWinnerId
        self.burstPlayerId = burstPlayerId
        self.onOKAction = onOKAction
        
        self._viewModel = StateObject(wrappedValue: ScoreResultViewModel(
            winners: winners,
            losers: losers,
            deckBottomCard: deckBottomCard,
            consecutiveCards: consecutiveCards,
            baseRate: baseRate,
            upRate: upRate,
            finalMultiplier: finalMultiplier,
            totalScore: totalScore,
            isShotenkoRound: isShotenkoRound,
            isBurstRound: isBurstRound,
            shotenkoWinnerId: shotenkoWinnerId,
            burstPlayerId: burstPlayerId
        ))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentWinner?.id)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Color.black.opacity(ViewConstants.backgroundOpacity)
            .ignoresSafeArea()
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: ViewConstants.sectionSpacing) {
                // Winner/Loser表示
                winnerLoserSection
                
                // 逆転アニメーション表示
                if viewModel.showReversalAnimation {
                    reversalAnimationView
                }
                
                // デッキとカード表示セクション
                deckAndCardsSection
                
                // スコア計算詳細
                scoreCalculationSection
                
                // OKボタン
                okButton
            }
            .padding(.horizontal, ViewConstants.horizontalPadding)
            .padding(.top, ViewConstants.topPadding)
            .padding(.bottom, ViewConstants.bottomPadding) // 広告エリア分の余白を追加
        }
    }
    
    // MARK: - Winner/Loser Section
    @ViewBuilder
    private var winnerLoserSection: some View {
        HStack(spacing: 60) {
            // しょてんこの場合：Winnerのみ表示
            if isShotenkoRound {
                winnerView
            }
            // バーストの場合：Loserのみ表示
            else if isBurstRound {
                loserView
            }
            // 通常のどてんこの場合：Winner/Loser両方表示
            else {
                winnerView
                loserView
            }
        }
        .padding(.top, ViewConstants.topPadding)
        .animation(.easeInOut(duration: 1.0), value: viewModel.reversalAnimationPhase)
    }
    
    @ViewBuilder
    private var winnerView: some View {
        VStack(spacing: 10) {
            Text("WINNER")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Color.yellow,
                            Appearance.Color.playerGold
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black, radius: 4, x: 0, y: 3)
            
            Text(viewModel.currentWinner?.name ?? "不明")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 15)
        .rotation3DEffect(
            Angle(degrees: viewModel.reversalAnimationPhase == 1 ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(viewModel.reversalAnimationPhase == 1 ? 0.3 : 1.0)
    }
    
    @ViewBuilder
    private var loserView: some View {
        VStack(spacing: 10) {
            Text("LOSER")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.cyan,
                            Color.blue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black, radius: 4, x: 0, y: 3)
            
            Text(viewModel.currentLoser?.name ?? "不明")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 15)
        .rotation3DEffect(
            Angle(degrees: viewModel.reversalAnimationPhase == 1 ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(viewModel.reversalAnimationPhase == 1 ? 0.3 : 1.0)
    }
    
    // MARK: - Reversal Animation Section
    @ViewBuilder
    private var reversalAnimationView: some View {
        VStack(spacing: ViewConstants.topPadding) {
            reversalEffectText
            reversalDescriptionText
        }
        .padding(.vertical, ViewConstants.topPadding)
        .background(reversalBackground)
        .padding(.horizontal, ViewConstants.topPadding)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: viewModel.reversalAnimationPhase)
    }
    
    @ViewBuilder
    private var reversalEffectText: some View {
        Text("勝敗逆転！")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.red)
            .shadow(color: .black, radius: 4, x: 0, y: 2)
            .scaleEffect(viewModel.reversalAnimationPhase == 1 ? 1.2 : 1.0)
            .opacity(viewModel.reversalAnimationPhase == 1 ? 1.0 : 0.8)
    }
    
    @ViewBuilder
    private var reversalDescriptionText: some View {
        Text("スペード・クローバーの3で逆転効果発動！")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.yellow)
            .shadow(color: .black, radius: 2, x: 0, y: 1)
            .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var reversalBackground: some View {
        RoundedRectangle(cornerRadius: ViewConstants.cardSpacing)
            .fill(Color.red.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: ViewConstants.cardSpacing)
                    .stroke(Color.red, lineWidth: 2)
            )
    }
    
    // MARK: - Deck and Cards Section
    @ViewBuilder
    private var deckAndCardsSection: some View {
        VStack(spacing: viewModel.showDeck || viewModel.showFloatingCard ? 30 : 15) {
            // デッキ表示エリア
            if viewModel.showDeck || viewModel.showFloatingCard {
                deckDisplayArea
            }
            
            // めくられたカード表示エリア
            revealedCardsArea
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.showDeck)
        .animation(.easeInOut(duration: 0.5), value: viewModel.showFloatingCard)
    }
    
    // MARK: - Deck Display Area
    @ViewBuilder
    private var deckDisplayArea: some View {
        ZStack {
            // デッキの山札表示（ZStackで重ねる）
            if viewModel.showDeck {
                ForEach(0..<min(viewModel.deckCards.count, 5), id: \.self) { index in
                    Image("back-1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: ViewConstants.cardWidth, height: ViewConstants.cardHeight)
                        .cornerRadius(ViewConstants.cornerRadius)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            
            // 浮上中のカード（FlipCardを使用）
            if viewModel.showFloatingCard, let floatingCard = viewModel.floatingCard {
                FlipCard(
                    isFront: viewModel.isCardFlipped,
                    duration: viewModel.animationSpeed * 0.6,
                    front: {
                        // 表面カード
                        if let cardImage = floatingCard.card.image() {
                            Image(uiImage: cardImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: ViewConstants.cardWidth, height: ViewConstants.cardHeight)
                                .cornerRadius(ViewConstants.cornerRadius)
                        }
                    },
                    back: {
                        // 裏面カード
                        Image("back-1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: ViewConstants.cardWidth, height: ViewConstants.cardHeight)
                            .cornerRadius(ViewConstants.cornerRadius)
                    }
                )
                .offset(y: viewModel.isCardMoving ? ViewConstants.cardUpwardOffset : 0) // 上に飛ばす
                .opacity(viewModel.isCardMoving ? 0 : 1) // フェードアウト
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: viewModel.animationSpeed * 0.8), value: viewModel.isCardMoving)
                .zIndex(10) // 最前面に表示
            }
        }
        .frame(height: viewModel.showDeck || viewModel.showFloatingCard ? ViewConstants.deckHeight : 0)
        .animation(.easeInOut(duration: 0.5), value: viewModel.showDeck)
        .animation(.easeInOut(duration: 0.5), value: viewModel.showFloatingCard)
    }
    
    // MARK: - Revealed Cards Area
    @ViewBuilder
    private var revealedCardsArea: some View {
        if !viewModel.revealedCards.isEmpty {
            VStack(spacing: ViewConstants.cardSpacing) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ViewConstants.cardSpacing) {
                        ForEach(viewModel.revealedCards.indices, id: \.self) { index in
                            VStack(spacing: ViewConstants.cardSpacing) {
                                if let cardImage = viewModel.revealedCards[index].card.image() {
                                    Image(uiImage: cardImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: ViewConstants.revealedCardWidth, height: ViewConstants.revealedCardHeight)
                                        .cornerRadius(ViewConstants.revealedCardCornerRadius)
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                                }
                                
                                // カード効果表示
                                let effectText = viewModel.getCardEffectText(viewModel.revealedCards[index])
                                if !effectText.isEmpty {
                                    Text(effectText)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(viewModel.getCardEffectColor(viewModel.revealedCards[index]))
                                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.black.opacity(0.7))
                                        )
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal, ViewConstants.horizontalPadding)
                }
            }
            .padding(.vertical, ViewConstants.cardSpacing)
            .background(
                RoundedRectangle(cornerRadius: ViewConstants.cornerRadius)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: ViewConstants.cornerRadius)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, ViewConstants.horizontalPadding)
        }
    }
    
    // MARK: - Score Calculation Section
    @ViewBuilder
    private var scoreCalculationSection: some View {
        if viewModel.showCalculation {
            VStack(spacing: ViewConstants.cardSpacing) {
                // 計算式の各項目（アニメーション付き）
                if viewModel.showBaseRate {
                    animatedScoreCalculationRow(
                        label: "初期レート", 
                        value: "\(viewModel.animatedBaseRate)",
                        isVisible: viewModel.showBaseRate
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                if viewModel.showUpRate {
                    animatedScoreCalculationRow(
                        label: "上昇レート", 
                        value: "×\(viewModel.animatedUpRate)", 
                        valueColor: .yellow,
                        isVisible: viewModel.showUpRate
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                if viewModel.showFinalMultiplier {
                    animatedScoreCalculationRow(
                        label: "最終　数字", 
                        value: "×\(viewModel.animatedFinalMultiplier)",
                        isVisible: viewModel.showFinalMultiplier
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                // 区切り線
                if viewModel.showFinalMultiplier {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, ViewConstants.horizontalPadding)
                        .transition(.opacity)
                }
                
                // 合計スコア
                if viewModel.showTotalScore {
                    HStack {
                        Spacer()
                        Text("=")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.animatedTotalScore)")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(Appearance.Color.playerGold)
                            .shadow(color: .black, radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal, ViewConstants.horizontalPadding)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .padding(.vertical, ViewConstants.cardSpacing)
            .background(
                RoundedRectangle(cornerRadius: ViewConstants.cornerRadius)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: ViewConstants.cornerRadius)
                            .stroke(Appearance.Color.playerGold.opacity(0.5), lineWidth: 1)
                    )
            )
            .padding(.horizontal, ViewConstants.horizontalPadding)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    /// アニメーション対応スコア計算の行表示
    private func animatedScoreCalculationRow(label: String, value: String, valueColor: Color = .white, isVisible: Bool) -> some View {
        HStack {
            Text(label + "：")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(valueColor)
                .shadow(color: .black, radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, ViewConstants.horizontalPadding)
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.8)
    }
    
    // MARK: - OK Button
    @ViewBuilder
    private var okButton: some View {
        if viewModel.showOKButton {
            CasinoUnifiedButton.ok(action: onOKAction)
                .padding(.bottom, 20)
                .scaleEffect(viewModel.showOKButton ? 1.0 : 0.8)
                .opacity(viewModel.showOKButton ? 1.0 : 0.0)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
        }
    }
}
