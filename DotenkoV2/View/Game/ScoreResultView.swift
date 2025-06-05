import SwiftUI

// MARK: - Score Result View
/// スコア確定イベント表示画面
struct ScoreResultView: View {
    let winner: Player?
    let loser: Player?
    let deckBottomCard: Card?
    let consecutiveCards: [Card] // 連続特殊カードのリスト
    let winnerHand: [Card]
    let baseRate: Int
    let upRate: Int
    let finalMultiplier: Int
    let totalScore: Int
    let onOKAction: () -> Void
    
    // アニメーション状態
    @State private var isCardFlipped: Bool = false
    @State private var currentCardIndex: Int = 0
    @State private var cardsToReveal: [Card] = []
    @State private var showContinueButton: Bool = false
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Winner/Loser表示
                    winnerLoserSection
                    
                    // カード表示セクション
                    cardDisplaySection
                    
                    // スコア計算詳細
                    scoreCalculationSection
                    
                    // OKボタン
                    okButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // 広告エリア分の余白を追加
            }
        }
        .animation(.easeInOut(duration: 0.5), value: winner?.id)
    }
    
    // MARK: - Winner/Loser Section
    @ViewBuilder
    private var winnerLoserSection: some View {
        HStack(spacing: 60) {
            // Winner側
            VStack(spacing: 15) {
                Text("Winner")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.red)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
                
                Text(winner?.name ?? "不明")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
            }
            
            // Loser側
            VStack(spacing: 15) {
                Text("Loser")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.blue)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
                
                Text(loser?.name ?? "不明")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Card Display Section
    @ViewBuilder
    private var cardDisplaySection: some View {
        VStack(spacing: 20) {
            // デッキの裏カード
            if let deckCard = deckBottomCard {
                VStack(spacing: 10) {
                    Text("デッキの裏")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // カードフリップアニメーション
                    CardFlipView(
                        isFlipped: isCardFlipped,
                        duration: 0.8,
                        front: {
                            // 裏面（back-1画像）
                            Image("back-1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 168)
                                .cornerRadius(12)
                        },
                        back: {
                            // 表面カード
                            if currentCardIndex < cardsToReveal.count {
                                CardView(card: cardsToReveal[currentCardIndex], size: 120)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 120, height: 168)
                            }
                        }
                    )
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                    .onAppear {
                        setupCardsToReveal()
                        startCardFlipAnimation()
                    }
                    
                    // 連続めくりボタン
                    if showContinueButton && currentCardIndex < cardsToReveal.count - 1 {
                        Button(action: {
                            continueCardReveal()
                        }) {
                            Text("次のカードをめくる")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.red)
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
    }
    
    // MARK: - Score Calculation Section
    @ViewBuilder
    private var scoreCalculationSection: some View {
        VStack(spacing: 15) {
            // 計算式の各項目
            scoreCalculationRow(label: "初期レート", value: "\(baseRate)")
            scoreCalculationRow(label: "上昇レート", value: "×\(upRate)", valueColor: .yellow)
            scoreCalculationRow(label: "最終　数字", value: "×\(finalMultiplier)")
            
            // 区切り線
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 40)
            
            // 合計スコア
            HStack {
                Spacer()
                Text("=")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(totalScore)")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(Appearance.Color.playerGold)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Appearance.Color.playerGold.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    /// スコア計算の行表示
    private func scoreCalculationRow(label: String, value: String, valueColor: Color = .white) -> some View {
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
        .padding(.horizontal, 40)
    }
    
    // MARK: - OK Button
    @ViewBuilder
    private var okButton: some View {
        Button(action: onOKAction) {
            Text("OK")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 200, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Card Flip Animation
    
    /// めくるカードのリストを設定
    private func setupCardsToReveal() {
        guard let deckCard = deckBottomCard else { return }
        
        // 最初のカードを追加
        cardsToReveal = [deckCard]
        
        // 連続特殊カードがある場合は追加
        cardsToReveal.append(contentsOf: consecutiveCards)
    }
    

    
    /// カードフリップアニメーションを開始
    private func startCardFlipAnimation() {
        // 1秒後にフリップ開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            performCardFlip()
        }
    }
    
    /// カードフリップを実行
    private func performCardFlip() {
        // カードをフリップ
        withAnimation(.easeInOut(duration: 0.8)) {
            isCardFlipped = true
        }
        
        // フリップ完了後、特殊カードなら続行ボタンを表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if currentCardIndex < cardsToReveal.count - 1 {
                showContinueButton = true
            }
        }
    }
    
    /// 次のカードめくりを続行
    private func continueCardReveal() {
        showContinueButton = false
        currentCardIndex += 1
        
        // カードを裏面に戻してから次のカードをめくる
        withAnimation(.easeInOut(duration: 0.4)) {
            isCardFlipped = false
        }
        
        // 少し待ってから次のカードをめくる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performCardFlip()
        }
    }
}

// MARK: - Card Flip View
/// カードフリップアニメーション用View
struct CardFlipView<Front: View, Back: View>: View {
    var isFlipped: Bool
    @State var canShowBack: Bool
    let duration: Double
    let front: () -> Front
    let back: () -> Back
    
    init(isFlipped: Bool,
         duration: Double = 0.8,
         @ViewBuilder front: @escaping () -> Front,
         @ViewBuilder back: @escaping () -> Back) {
        self.isFlipped = isFlipped
        self._canShowBack = State(initialValue: isFlipped)
        self.duration = duration
        self.front = front
        self.back = back
    }
    
    var body: some View {
        ZStack {
            if self.canShowBack {
                back()
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
            } else {
                front()
            }
        }
        .onChange(of: isFlipped) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration/2.0) {
                self.canShowBack = value
            }
        }
        .rotation3DEffect(
            isFlipped ? Angle(degrees: 180) : Angle(degrees: 0),
            axis: (x: CGFloat(0), y: CGFloat(1), z: CGFloat(0)),
            anchor: .center,
            perspective: 0.3
        )
        .animation(.easeInOut(duration: duration), value: isFlipped)
    }
}

// MARK: - Preview
#Preview {
    ScoreResultView(
        winner: Player(id: "player", side: 0, name: "Lily", icon_url: nil, dtnk: false),
        loser: Player(id: "bot-1", side: 1, name: "Mac2 16pro", icon_url: nil, dtnk: false),
        deckBottomCard: Card(card: .whiteJoker, location: .deck),
        consecutiveCards: [
            Card(card: .spade1, location: .deck),
            Card(card: .heart2, location: .deck)
        ],
        winnerHand: [],
        baseRate: 100,
        upRate: 1,
        finalMultiplier: 11,
        totalScore: 1100,
        onOKAction: {}
    )
} 