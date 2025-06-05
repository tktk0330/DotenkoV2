import SwiftUI

/// 中間結果画面
/// ラウンド終了後にスコア変動を表示し、全プレイヤーの確認を待つ画面
struct InterimResultView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // スコア確定画面と同じ背景
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // タイトル
                    VStack(spacing: 10) {
                        Text("ラウンド \(viewModel.currentRound) 結果")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                        
                        Text("スコア変動")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // スコア表示エリア
                    VStack(spacing: 20) {
                        ForEach(viewModel.players, id: \.id) { player in
                            PlayerScoreCard(
                                player: player,
                                scoreChange: getScoreChange(for: player),
                                isCurrentPlayer: player.id == "player"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // OKボタンエリア
                    VStack(spacing: 15) {
                        if viewModel.isWaitingForOthers {
                            // 他プレイヤー待機中
                            VStack(spacing: 15) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text("他のプレイヤーを待機中...")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.vertical, 30)
                        } else {
                            // OKボタン
                            Button(action: {
                                handleOKButtonTapped()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24, weight: .bold))
                                    Text("OK")
                                        .font(.system(size: 24, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.green.opacity(0.9),
                                                    Color.green.opacity(0.7)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                                )
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        }
                    }
                    .padding(.bottom, 120) // 広告エリア分の余白を追加
                }
            }
        }
        .onAppear {
            print("📊 中間結果画面表示 - ラウンド \(viewModel.currentRound)")
        }
    }
    
    /// プレイヤーのスコア変動を取得
    private func getScoreChange(for player: Player) -> Int {
        // プレイヤーの順位に基づいてスコア変動を計算
        if player.rank == 1 {
            // 勝者：スコアを獲得
            return viewModel.lastRoundScore
        } else if player.rank == viewModel.players.count {
            // 敗者（最下位）：スコアを失う
            return -viewModel.lastRoundScore
        } else {
            // 中間順位：変動なし
            return 0
        }
    }
    
    /// OKボタンタップ処理
    private func handleOKButtonTapped() {
        print("✅ 中間結果画面 - OKボタンタップ")
        viewModel.handleInterimResultOK()
    }
}

/// プレイヤーのスコアカード
struct PlayerScoreCard: View {
    let player: Player
    let scoreChange: Int
    let isCurrentPlayer: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // プレイヤーアイコン
            ZStack {
                Circle()
                    .fill(isCurrentPlayer ? Appearance.Color.playerGold.opacity(0.3) : Color.gray.opacity(0.4))
                    .frame(width: 70, height: 70)
                
                if isCurrentPlayer {
                    Circle()
                        .stroke(Appearance.Color.playerGold, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
                
                Text(String(player.name.prefix(1)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
            }
            
            // プレイヤー情報
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                
                Text("現在のスコア: \(player.score)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // スコア変動
            VStack(alignment: .trailing, spacing: 5) {
                Text(scoreChange >= 0 ? "+\(scoreChange)" : "\(scoreChange)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(scoreChange >= 0 ? .green : .red)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
                
                Text("変動")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isCurrentPlayer ? Appearance.Color.playerGold.opacity(0.7) : Color.white.opacity(0.3), 
                            lineWidth: 2
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        )
    }
}

#Preview {
    InterimResultView(viewModel: GameViewModel())
} 