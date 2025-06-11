import SwiftUI

// MARK: - Challenge Zone Participation Modal
/// チャレンジゾーン参加可否選択モーダル
/// 
/// 機能:
/// - プレイヤー別の選択肢表示（参加する/参加しない/リベンジ）
/// - タイムアウト5秒、デフォルト「参加する」
/// - BOT自動選択（1-3秒遅延）
/// - 待機中のローディング表示
/// - 参加条件を満たさないプレイヤーには「参加しない」のみ表示（非活性）
struct ChallengeZoneParticipationModal: View {
    
    // MARK: - Properties
    let players: [Player]
    let revengeEligiblePlayers: [String]
    let dotenkoWinnerId: String?
    let fieldCardValue: Int // 場のカード数字を追加
    let calculateHandTotals: ([Card]) -> [Int] // 手札合計計算関数を追加
    let onPlayerChoice: (String, ParticipationChoice) -> Void
    let onTimeout: () -> Void
    
    @State private var playerChoices: [String: ParticipationChoice] = [:]
    @State private var timeRemaining: Int = 5
    @State private var isVisible: Bool = false
    @State private var timer: Timer?
    
    // MARK: - Participation Choice
    enum ParticipationChoice {
        case participate    // 参加する
        case decline       // 参加しない
        case revenge       // リベンジ
        
        var displayText: String {
            switch self {
            case .participate: return "参加する"
            case .decline: return "参加しない"
            case .revenge: return "リベンジ"
            }
        }
        
        var buttonColor: Color {
            switch self {
            case .participate: return .blue
            case .decline: return .gray
            case .revenge: return .red
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景オーバーレイ
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // 背景タップでは何もしない（強制選択）
                }
            
            // メインモーダル
            VStack(spacing: 16) {
                // タイトル
                titleSection
                
                // タイマー表示
                timerSection
                
                // プレイヤー選択エリア
                playersSection
                
                // 説明テキスト
                descriptionSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 400))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.2, blue: 0.1),
                                Color(red: 0.05, green: 0.15, blue: 0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.cyan.opacity(0.6),
                                        Color.blue.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: Color.cyan.opacity(0.3), radius: 10, x: 0, y: 0)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        }
        .onAppear {
            startModal()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("チャレンジゾーン")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 0, y: 1)
            
            Text("参加しますか？")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black, radius: 1, x: 0, y: 1)
        }
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundColor(.orange)
                .font(.system(size: 14, weight: .medium))
            
            Text("\(timeRemaining)秒")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .shadow(color: .black, radius: 1, x: 0, y: 1)
            
            Text("（自動選択: 参加する）")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    // MARK: - Players Section
    private var playersSection: some View {
        VStack(spacing: 8) {
            ForEach(players, id: \.id) { player in
                playerRow(for: player)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Player Row
    private func playerRow(for player: Player) -> some View {
        HStack(spacing: 12) {
            // プレイヤー名
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                // プレイヤー状態表示
                Text(getPlayerStatus(player))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(getPlayerStatusColor(player))
            }
            .frame(minWidth: 60, alignment: .leading)
            
            Spacer()
            
            // 選択ボタンまたは状態表示
            if player.id == "player" {
                // 人間プレイヤー: 選択ボタン
                humanPlayerButtons(for: player)
            } else {
                // BOTプレイヤー: 回答状況のみ表示
                botPlayerAnswerStatus(for: player)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Human Player Buttons
    private func humanPlayerButtons(for player: Player) -> some View {
        HStack(spacing: 6) {
            if let choice = playerChoices[player.id] {
                // 選択済み表示
                Text(choice.displayText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(choice.buttonColor)
                    )
            } else {
                // 選択ボタン
                let availableChoices = getAvailableChoices(for: player)
                let canParticipate = canPlayerParticipate(player)
                
                ForEach(availableChoices, id: \.self) { choice in
                    Button(action: {
                        selectChoice(for: player.id, choice: choice)
                    }) {
                        Text(choice.displayText)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        // 参加条件を満たさない場合の「参加しない」ボタンは非活性色
                                        (!canParticipate && choice == .decline) ? 
                                        Color.gray.opacity(0.5) : choice.buttonColor
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!canParticipate && choice == .participate) // 参加条件を満たさない場合は「参加する」を無効化
                }
            }
        }
        .frame(maxWidth: 120, alignment: .trailing)
    }
    
    // MARK: - BOT Player Answer Status
    private func botPlayerAnswerStatus(for player: Player) -> some View {
        HStack(spacing: 6) {
            if playerChoices[player.id] != nil {
                // BOT回答済み（選択内容は非表示）
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("回答済み")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                }
            } else {
                // BOT思考中
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    
                    Text("思考中...")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.cyan)
                }
            }
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(spacing: 3) {
            Text("チャレンジゾーンでは手札を公開してカードを引き続けます")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("参加条件: 手札合計 < 場のカード数字")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    
    /// プレイヤーの状態テキストを取得
    private func getPlayerStatus(_ player: Player) -> String {
        if player.id == dotenkoWinnerId {
            return "どてんこ勝者"
        } else if revengeEligiblePlayers.contains(player.id) {
            return "リベンジ可能"
        } else if !canPlayerParticipate(player) {
            return "参加条件不適合"
        } else {
            return "通常参加"
        }
    }
    
    /// プレイヤーの状態色を取得
    private func getPlayerStatusColor(_ player: Player) -> Color {
        if player.id == dotenkoWinnerId {
            return .yellow
        } else if revengeEligiblePlayers.contains(player.id) {
            return .red
        } else if !canPlayerParticipate(player) {
            return .gray
        } else {
            return .cyan
        }
    }
    
    /// プレイヤーが選択可能な選択肢を取得
    private func getAvailableChoices(for player: Player) -> [ParticipationChoice] {
        if player.id == dotenkoWinnerId {
            // どてんこ勝者は参加強制（参加するのみ）
            return [.participate]
        } else if revengeEligiblePlayers.contains(player.id) {
            // リベンジ可能プレイヤー
            return [.revenge, .decline]
        } else {
            // 通常プレイヤー: 参加条件をチェック
            let handTotals = calculateHandTotals(player.hand)
            let minHandTotal = handTotals.min() ?? 0
            
            if minHandTotal < fieldCardValue {
                // 参加条件を満たす場合
                return [.participate, .decline]
            } else {
                // 参加条件を満たさない場合は「参加しない」のみ
                return [.decline]
            }
        }
    }
    
    /// プレイヤーが参加条件を満たすかチェック
    private func canPlayerParticipate(_ player: Player) -> Bool {
        if player.id == dotenkoWinnerId {
            return true // どてんこ勝者は常に参加可能
        }
        
        let handTotals = calculateHandTotals(player.hand)
        let minHandTotal = handTotals.min() ?? 0
        return minHandTotal < fieldCardValue
    }
    
    /// 選択を処理
    private func selectChoice(for playerId: String, choice: ParticipationChoice) {
        playerChoices[playerId] = choice
        onPlayerChoice(playerId, choice)
        
        // 全プレイヤーが選択完了したかチェック
        checkAllPlayersSelected()
    }
    
    /// 全プレイヤーが選択完了したかチェック
    private func checkAllPlayersSelected() {
        if playerChoices.count >= players.count {
            // 全員選択完了
            stopTimer()
        }
    }
    
    /// モーダル開始処理
    private func startModal() {
        isVisible = true
        startTimer()
        scheduleBotChoices()
    }
    
    /// タイマー開始
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            
            if timeRemaining <= 0 {
                handleTimeout()
            }
        }
    }
    
    /// タイマー停止
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// タイムアウト処理
    private func handleTimeout() {
        stopTimer()
        
        // 未選択のプレイヤーにデフォルト選択を適用
        for player in players {
            if playerChoices[player.id] == nil {
                let defaultChoice: ParticipationChoice
                if revengeEligiblePlayers.contains(player.id) {
                    defaultChoice = .revenge
                } else if player.id == dotenkoWinnerId {
                    defaultChoice = .decline
                } else {
                    defaultChoice = .participate
                }
                playerChoices[player.id] = defaultChoice
                onPlayerChoice(player.id, defaultChoice)
            }
        }
        
        onTimeout()
    }
    
    /// BOT選択をスケジュール
    private func scheduleBotChoices() {
        for player in players {
            if player.id != "player" {
                let delay = Double.random(in: 1.0...3.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if playerChoices[player.id] == nil {
                        let choice = getBotChoice(for: player)
                        selectChoice(for: player.id, choice: choice)
                    }
                }
            }
        }
    }
    
    /// BOTの選択を決定
    private func getBotChoice(for player: Player) -> ParticipationChoice {
        if revengeEligiblePlayers.contains(player.id) {
            // リベンジ可能時は必ずリベンジ
            return .revenge
        } else if player.id == dotenkoWinnerId {
            // どてんこ勝者は参加する
            return .participate
        } else if canPlayerParticipate(player) {
            // 参加条件を満たす場合は参加する
            return .participate
        } else {
            // 参加条件を満たさない場合は参加しない
            return .decline
        }
    }
}

// MARK: - Preview
struct ChallengeZoneParticipationModal_Previews: PreviewProvider {
    static var previews: some View {
        let samplePlayers = [
            Player(id: "player", side: 0, name: "あなた", icon_url: nil, dtnk: false),
            Player(id: "bot1", side: 1, name: "BOT-A", icon_url: nil, dtnk: true),
            Player(id: "bot2", side: 2, name: "BOT-B", icon_url: nil, dtnk: false),
            Player(id: "bot3", side: 3, name: "BOT-C", icon_url: nil, dtnk: false),
            Player(id: "bot4", side: 4, name: "BOT-D", icon_url: nil, dtnk: false)
        ]
        
        Group {
            // 通常表示
            ChallengeZoneParticipationModal(
                players: samplePlayers,
                revengeEligiblePlayers: ["bot2"],
                dotenkoWinnerId: "bot1",
                fieldCardValue: 7,
                calculateHandTotals: { cards in
                    // サンプル用の簡単な計算（実際のジョーカー計算は省略）
                    let total = cards.reduce(0) { sum, card in
                        sum + (card.card.handValue().first ?? 0)
                    }
                    return [total]
                },
                onPlayerChoice: { playerId, choice in
                    print("Player \(playerId) chose \(choice)")
                },
                onTimeout: {
                    print("Modal timeout")
                }
            )
            .previewDisplayName("通常表示")
            
            // 小さい画面での表示確認
            ChallengeZoneParticipationModal(
                players: Array(samplePlayers.prefix(3)),
                revengeEligiblePlayers: ["bot2"],
                dotenkoWinnerId: nil,
                fieldCardValue: 5,
                calculateHandTotals: { cards in
                    // サンプル用の簡単な計算（実際のジョーカー計算は省略）
                    let total = cards.reduce(0) { sum, card in
                        sum + (card.card.handValue().first ?? 0)
                    }
                    return [total]
                },
                onPlayerChoice: { playerId, choice in
                    print("Player \(playerId) chose \(choice)")
                },
                onTimeout: {
                    print("Modal timeout")
                }
            )
            .previewDisplayName("小画面")
        }
    }
} 