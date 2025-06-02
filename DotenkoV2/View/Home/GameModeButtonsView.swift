import SwiftUI

struct GameModeButtonsView: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    @State private var selectedMaxPlayers: Int = 5
    
    private let playerCountOptions = [2, 3, 4, 5]
    
    var body: some View {
        VStack(spacing: 24) {
            // プレイヤー数選択セクション
            VStack(spacing: 12) {
                Text("プレイヤー数")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                HStack(spacing: 12) {
                    ForEach(playerCountOptions, id: \.self) { count in
                        PlayerCountButton(
                            count: count,
                            isSelected: selectedMaxPlayers == count,
                            action: { selectedMaxPlayers = count }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Appearance.Color.commonBlack.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Appearance.Color.commonWhite.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // ゲームモードボタン
            VStack(spacing: 16) {
                // 個人戦ボタン
                GameModeButton(
                    title: "個人戦",
                    backgroundImage: Appearance.Image.GameMode.singlePlayButton,
                    action: { 
                        allViewNavigator.push(MatchingView(maxPlayers: selectedMaxPlayers, gameType: GameType.vsBot)) 
                    }
                )
                
                // 友人戦ボタン
                GameModeButton(
                    title: "友人戦",
                    backgroundImage: Appearance.Image.GameMode.friendPlayButton,
                    action: { 
                        allViewNavigator.push(MatchingView(maxPlayers: selectedMaxPlayers, gameType: GameType.online))
                    }
                )
            }
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Player Count Button
private struct PlayerCountButton: View {
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(count)人")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Appearance.Color.commonBlack : Appearance.Color.commonWhite)
                .frame(width: 60, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Appearance.Color.commonWhite : Appearance.Color.commonBlack.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isSelected ? Appearance.Color.commonWhite : Appearance.Color.commonWhite.opacity(0.3), 
                                    lineWidth: 1
                                )
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
} 
