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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // 参加人数表示
                    Text("\(viewModel.players.count)/\(maxPlayers)が参加中")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
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
                    Button(action: {
                        // ゲーム開始処理
                        viewModel.startGame()
                    }) {
                        Text("ゲームを開始")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
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
                    if let imageUrl = player.image {
                        if player.id.hasPrefix("bot-") {
                            // Botの場合は内部の画像を使用
                            if let image = UIImage(named: imageUrl) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            }
                        } else {
                            // ユーザーの場合はURLから読み込み
                            if let uiImage = imageLoader.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ProgressView()
                                    .onAppear {
                                        imageLoader.loadImage(from: imageUrl)
                                    }
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundColor(.gray)
                    }
                } else {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.black.opacity(0.3))
            .clipShape(Circle())
            
            // プレイヤー名
            if let player = player {
                Text(player.name)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            } else {
                Text("募集中")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

// 画像ローダー
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellables = Set<AnyCancellable>()
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
            .store(in: &cancellables)
    }
}

// 配列の安全なインデックスアクセスのための拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// プレイヤーモデル
struct Player: Identifiable {
    let id: String
    let name: String
    var image: String?
}

// ビューモデル
class MatchingViewModel: ObservableObject {
    @Published var players: [Player] = []
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
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
                    id: profile.id.stringValue,
                    name: profile.rmUserName,
                    image: profile.rmIconUrl
                )
                players = [currentPlayer]
            } else {
                // Fallback to default if profile fetch fails
                players = [Player(id: "current", name: "あなた")]
            }
            
            // Add bots with delay
            let bots = botList.getBotPlayer().shuffled().prefix(maxPlayers - 1)
            for (index, bot) in bots.enumerated() {
                loadingIndexes.insert(index + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.5) { [weak self] in
                    guard let self = self else { return }
                    let botPlayer = Player(
                        id: bot.id,
                        name: bot.name,
                        image: bot.icon_url
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
    
    func startGame() {
        // ゲーム開始時の処理を実装
        allViewNavigator.push(GameMainView())
    }
}

