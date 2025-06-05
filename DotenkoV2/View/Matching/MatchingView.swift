import SwiftUI
import Combine

struct MatchingView: View {
    let maxPlayers: Int
    let gameType: GameType
    
    @StateObject private var viewModel: MatchingViewModel
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    
    init(maxPlayers: Int, gameType: GameType) {
        self.maxPlayers = maxPlayers
        self.gameType = gameType
        _viewModel = StateObject(wrappedValue: MatchingViewModel(gameType: gameType))
    }
    
    var body: some View {
        BaseLayout {
            VStack(spacing: 24) {
                // 戻るボタンと参加人数
                HStack {
                    Button(action: { allViewNavigator.pop() }) {
                        Image(systemName: Appearance.Icon.chevronLeft)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite)
                    }
                    
                    Spacer()
                    
                    // 参加人数表示
                    Text("\(viewModel.players.count)/\(maxPlayers)が参加中")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Appearance.Color.commonWhite)
                }
                .padding(.horizontal, 20)
                
                // プレイヤースロット
                VStack(spacing: 16) {
                    ForEach(0..<maxPlayers, id: \.self) { index in
                        PlayerSlotView(
                            player: viewModel.players[safe: index],
                            isLoading: viewModel.isLoadingAtIndex(index)
                        )
                    }
                }
                .padding(.vertical, 32)
                
                Spacer()
                
                // スタートボタン（全員揃った場合のみ表示）
                if viewModel.players.count == maxPlayers {
                    Button(action: startGame) {
                        Text("ゲームを開始")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Appearance.Color.commonGreen)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            viewModel.startMatching(maxPlayers: maxPlayers)
        }
    }
    
    private func startGame() {
        // ゲーム開始時の処理を実装
        allViewNavigator.push(GameMainView(
            players: viewModel.players,
            maxPlayers: maxPlayers,
            gameType: gameType
        ))
    }
}

// プレイヤースロットのビュー
struct PlayerSlotView: View {
    let player: Player?
    let isLoading: Bool
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        HStack(spacing: 16) {
            // プレイヤーアイコン
            ZStack {
                if let player = player {
                    if let imageUrl = player.icon_url, !imageUrl.isEmpty {
                        if player.id.hasPrefix("bot-") {
                            // Botの場合は内部の画像を使用
                            if let image = UIImage(named: imageUrl) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // ローカル画像が見つからない場合はデフォルトアイコン
                                Image(systemName: Appearance.Icon.personFill)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(Appearance.Color.commonGray)
                            }
                        } else if imageUrl.hasPrefix("http") {
                            // ユーザーの場合でHTTP/HTTPSのURLの場合はURLから読み込み
                            if let uiImage = imageLoader.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else if imageLoader.isLoading {
                                ProgressView()
                                    .onAppear {
                                        imageLoader.loadImage(from: imageUrl)
                                    }
                            } else {
                                // ロードに失敗した場合はデフォルトアイコン
                                Image(systemName: Appearance.Icon.personFill)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(Appearance.Color.commonGray)
                                    .onAppear {
                                        // まだロードを試していない場合は開始
                                        if imageLoader.image == nil && !imageLoader.isLoading {
                                            imageLoader.loadImage(from: imageUrl)
                                        }
                                    }
                            }
                        } else {
                            // URLではないがローカル画像名の可能性がある場合
                            if let image = UIImage(named: imageUrl) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // ローカル画像も見つからない場合はデフォルトアイコン
                                Image(systemName: Appearance.Icon.personFill)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .foregroundColor(Appearance.Color.commonGray)
                            }
                        }
                    } else {
                        Image(systemName: Appearance.Icon.personFill)
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundColor(Appearance.Color.commonGray)
                    }
                } else {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: Appearance.Icon.personFill)
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundColor(Appearance.Color.commonGray)
                    }
                }
            }
            .frame(width: 50, height: 50)
            .background(Appearance.Color.commonBlack.opacity(0.2))
            .clipShape(Circle())
            
            // プレイヤー名
            if let player = player {
                Text(player.name)
                    .font(.system(size: 16))
                    .foregroundColor(Appearance.Color.commonWhite)
            } else {
                Text("募集中")
                    .font(.system(size: 16))
                    .foregroundColor(Appearance.Color.commonGray)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Appearance.Color.commonBlack.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

// 画像ローダー（キャッシュ機能付き）
// ImageLoader is now defined in Utility/ImageCacheManager.swift

// 配列の安全なインデックスアクセスのための拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// ビューモデル
class MatchingViewModel: ObservableObject {
    @Published var players: [Player] = []
    private var gameType: GameType
    private var botList = BotPlayerList()
    private var loadingIndexes: Set<Int> = []
    private let userProfileRepository = UserProfileRepository.shared
    
    init(gameType: GameType) {
        self.gameType = gameType
    }
    
    func startMatching(maxPlayers: Int) {
        if gameType == .vsBot {
            // Add current player with profile info
            if case .success(let profile) = userProfileRepository.getOrCreateProfile() {
                print(profile.rmIconUrl)
                let currentPlayer = Player(
                    id: "player",
                    side: 0,
                    name: profile.rmUserName,
                    icon_url: profile.rmIconUrl,
                    dtnk: false
                )
                players = [currentPlayer]
            } else {
                // Fallback to default if profile fetch fails
                players = [Player(id: "player", side: 0, name: "あなた", icon_url: nil, dtnk: false)]
            }
            
            // Add bots with delay
            let bots = botList.getBotPlayer().shuffled().prefix(maxPlayers - 1)
            for (index, bot) in bots.enumerated() {
                loadingIndexes.insert(index + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.5) { [weak self] in
                    guard let self = self else { return }
                    let botPlayer = Player(
                        id: bot.id,
                        side: index + 1,
                        name: bot.name,
                        icon_url: bot.icon_url,
                        dtnk: false
                    )
                    self.players.append(botPlayer)
                    self.loadingIndexes.remove(index + 1)
                }
            }
        }
    }
    
    func isLoadingAtIndex(_ index: Int) -> Bool {
        return loadingIndexes.contains(index)
    }
}


