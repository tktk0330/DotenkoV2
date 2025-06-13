import SwiftUI

struct GlobalNavigationView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject private var navigator: NavigationStateManager
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    navigator.popToRoot()
                    selectedTab = tab
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(tab.title)
                            .font(Font(Appearance.Font.navigation))
                    }
                    .foregroundColor(selectedTab == tab ? Color.black : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(navigationButtonBackground(isSelected: selectedTab == tab))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Rectangle()
                .fill(Color(uiColor: Appearance.Color.mossGreen))
                .shadow(color: .black.opacity(0.3), radius: 4, y: -2)
        }
    }
    
    @ViewBuilder
    private func navigationButtonBackground(isSelected: Bool) -> some View {
        if isSelected {
            // 選択時のカジノ風背景
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(uiColor: Appearance.Color.goldenYellow),
                            Color(uiColor: Appearance.Color.goldenYellow).opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear,
                                    Color.white.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color(uiColor: Appearance.Color.goldenYellow).opacity(0.4), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
            // 非選択時の透明背景
            Color.clear
        }
    }
}

enum Tab: CaseIterable {
    case help
    case home
    case profile
    
    var title: String {
        switch self {
        case .help: return "HELP"
        case .home: return "HOME"
        case .profile: return "OPTION"
        }
    }
    
    var iconName: String {
        switch self {
        case .help: return "questionmark.circle"
        case .home: return "suit.spade.fill"
        case .profile: return "gearshape"
        }
    }
}
