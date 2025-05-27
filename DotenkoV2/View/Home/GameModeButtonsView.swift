import SwiftUI

struct GameModeButtonsView: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    
    var body: some View {
        VStack(spacing: 16) {
            // 個人戦ボタン
            GameModeButton(
                title: "個人戦",
                backgroundImage: Appearance.Image.GameMode.singlePlayButton,
                action: { allViewNavigator.push(MatchingView(maxPlayers: 5, gameType: GameType.vsBot)) }
            )
            
            // 友人戦ボタン
            GameModeButton(
                title: "友人戦",
                backgroundImage: Appearance.Image.GameMode.friendPlayButton,
                action: { allViewNavigator.push(MatchingView(maxPlayers: 5, gameType: GameType.vsFriend)) }
            )
        }
        .padding(.horizontal, 30)
    }
} 
