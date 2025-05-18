import SwiftUI

struct GlobalNavigationView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject private var navigator: NavigationStateManager
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    navigator.popToRoot()
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(tab.title)
                            .font(Font(Appearance.Font.navigation))
                    }
                    .foregroundColor(selectedTab == tab ? Color(uiColor: Appearance.Color.goldenYellow) : .white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background {
            Rectangle()
                .fill(Color(uiColor: Appearance.Color.mossGreen))
                .shadow(color: .black.opacity(0.3), radius: 4, y: -2)
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
