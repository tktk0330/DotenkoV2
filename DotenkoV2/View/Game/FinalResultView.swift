import SwiftUI

/// 最終結果画面
/// 全ラウンド終了後に最終スコアと順位を表示する画面
struct FinalResultView: View {
    @ObservedObject var viewModel: GameViewModel
    let onOKAction: () -> Void
    
    // 順位別の色設定
    private let rankColors: [Color] = [
        Color.yellow,      // 1位: ゴールド
        Color.gray,        // 2位: シルバー
        Color.orange,      // 3位: ブロンズ
        Color.gray,        // 4位: グレー
        Color.gray         // 5位: グレー
    ]
    
    var body: some View {
        ZStack {
            // 背景（中間結果画面と同じ）
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // タイトル
                    titleSection
                    
                    // 順位表示エリア
                    rankingSection
                    
                    // OKボタン
                    okButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 120) // 広告エリア分の余白
            }
        }
        .onAppear {
            print("🏆 最終結果画面表示")
        }
    }
    
    // MARK: - Title Section
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 15) {
            Text("最終結果")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // 区切り線
            Rectangle()
                .fill(Appearance.Color.playerGold.opacity(0.6))
                .frame(height: 2)
                .frame(maxWidth: 200)
        }
    }
    
    // MARK: - Ranking Section
    @ViewBuilder
    private var rankingSection: some View {
        VStack(spacing: 15) {
            ForEach(sortedPlayers.indices, id: \.self) { index in
                let player = sortedPlayers[index]
                let rank = index + 1
                
                FinalPlayerRankCard(
                    player: player,
                    rank: rank,
                    rankColor: getRankColor(for: rank),
                    isCurrentPlayer: player.id == "player"
                )
            }
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - OK Button
    @ViewBuilder
    private var okButton: some View {
        Button(action: onOKAction) {
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.system(size: 24, weight: .bold))
                Text("ホームに戻る")
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
                                Appearance.Color.playerGold.opacity(0.9),
                                Appearance.Color.playerGold.opacity(0.7)
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
    
    // MARK: - Helper Methods
    
    /// スコア順にソートされたプレイヤーリスト
    private var sortedPlayers: [Player] {
        return viewModel.players.sorted { $0.score > $1.score }
    }
    
    /// 順位に応じた色を取得
    private func getRankColor(for rank: Int) -> Color {
        let index = rank - 1
        if index < rankColors.count {
            return rankColors[index]
        } else {
            return Color.gray // 6位以降はグレー
        }
    }
}

/// 最終結果のプレイヤーランクカード
struct FinalPlayerRankCard: View {
    let player: Player
    let rank: Int
    let rankColor: Color
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // 一行目：順位・アイコン・名前
            HStack(spacing: 20) {
                // 順位表示
                ZStack {
                    Circle()
                        .fill(rankColor.opacity(0.8))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .stroke(rankColor, lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Text("\(rank)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                }
                
                // プレイヤーアイコン
                ZStack {
                    Circle()
                        .fill(isCurrentPlayer ? Appearance.Color.playerGold.opacity(0.3) : rankColor.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .stroke(rankColor, lineWidth: 3)
                        .frame(width: 70, height: 70)
                    
                    Text(String(player.name.prefix(1)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
                
                // プレイヤー名前
                Text(player.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 0, y: 1)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // 二行目：スコア表示
            HStack {
                Spacer()
                
                VStack(spacing: 5) {
                    Text("\(player.score)")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(rankColor)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("スコア")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            rankColor.opacity(0.15),
                            rankColor.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    rankColor.opacity(0.8),
                                    rankColor.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: rankColor.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(rank == 1 ? 1.05 : 1.0) // 1位のみ少し大きく
        .animation(.easeInOut(duration: 0.3), value: rank)
    }
}
