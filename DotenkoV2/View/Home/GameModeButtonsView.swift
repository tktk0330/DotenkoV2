import SwiftUI

struct GameModeButtonsView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    
    var body: some View {
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
    }
} 