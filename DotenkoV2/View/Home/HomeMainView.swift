import SwiftUI

struct HomeMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @StateObject private var profileVM = UserProfileViewModel()
    
    var body: some View {
        ZStack {
            // メインコンテンツ
            VStack(spacing: 16) {
                
                Spacer().frame(height: 200)
                
                // ゲームモード選択ボタン
                VStack(spacing: 16) {
                    // 個人戦ボタン
                    GameModeButton(
                        title: "個人戦",
                        backgroundImage: Appearance.Image.GameMode.singlePlayButton,
                        action: { navigator.push(Menu1View()) }
                    )
                    
                    // 友人戦ボタン
                    GameModeButton(
                        title: "友人戦",
                        backgroundImage: Appearance.Image.GameMode.friendPlayButton,
                        action: { navigator.push(GameRuleView()) }
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 40)
            }
            
        }
    }
}

// ゲームモードボタン
struct GameModeButton: View {
    let title: String
    let backgroundImage: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // ボタンの背景
                if let image = backgroundImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: Appearance.Color.mossGreen))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: Appearance.Color.goldenYellow), lineWidth: 2)
                        )
                }
                
                // ボタンのテキスト
                Text(title)
                    .font(Font(Appearance.Font.casinoDisplay))
                    .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            }
        }
        .frame(height: 70)
    }
}

// プレビュー用のダミービュー
struct SinglePlayView: View {
    var body: some View {
        Text("個人戦")
    }
}

struct FriendPlayView: View {
    var body: some View {
        Text("友人戦")
    }
}
