import SwiftUI

struct GameModeButtonsView: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    @State private var selectedMaxPlayers: Int = 3
    
    private let playerCountOptions = [2, 3, 4, 5]
    
    var body: some View {
        VStack(spacing: 24) {
            // プレイヤー数選択セクション
            CasinoPlayerCountSection(
                selectedMaxPlayers: $selectedMaxPlayers,
                playerCountOptions: playerCountOptions
            )
            
            // ゲームモードボタン
            VStack(spacing: 20) {
                // vs CPUボタン
                CasinoGameModeButton(
                    title: "vs CPU",
                    subtitle: "コンピューターと対戦",
                    icon: "desktopcomputer",
                    gradientColors: CasinoButtonConfig.cpuGradient,
                    action: { 
                        allViewNavigator.push(MatchingView(maxPlayers: selectedMaxPlayers, gameType: GameType.vsBot)) 
                    }
                )
                
                // vs Onlineボタン
                CasinoGameModeButton(
                    title: "vs Online",
                    subtitle: "友人とオンライン対戦",
                    icon: "wifi",
                    gradientColors: CasinoButtonConfig.onlineGradient,
                    action: { 
                        allViewNavigator.push(MatchingView(maxPlayers: selectedMaxPlayers, gameType: GameType.online))
                    }
                )
            }
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Casino Player Count Section
private struct CasinoPlayerCountSection: View {
    @Binding var selectedMaxPlayers: Int
    let playerCountOptions: [Int]
    
    var body: some View {
        VStack(spacing: 16) {
            // タイトル
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("プレイヤー数")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
            }
            
            // プレイヤー数ボタン
            HStack(spacing: 12) {
                ForEach(playerCountOptions, id: \.self) { count in
                    CasinoPlayerCountButton(
                        count: count,
                        isSelected: selectedMaxPlayers == count,
                        action: { selectedMaxPlayers = count }
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(casinoSectionBackground)
    }
    
    private var casinoSectionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.4),
                                Color.orange.opacity(0.4)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                // 内側の光る効果
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: Color.yellow.opacity(0.2), radius: 12, x: 0, y: 0)
    }
}

// MARK: - Casino Game Mode Button
private struct CasinoGameModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradientColors: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isGlowing = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン部分
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: gradientColors.first?.opacity(0.5) ?? Color.clear, radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // テキスト部分
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // 矢印アイコン
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(casinoButtonBackground)
            .scaleEffect(isPressed ? 0.95 : (isGlowing ? 1.02 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            isGlowing = true
        }
    }
    
    private var casinoButtonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.8),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors.map { $0.opacity(0.6) }),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                // 内側の光る効果
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: gradientColors.first?.opacity(0.2) ?? Color.clear, radius: 12, x: 0, y: 0)
    }
}

// MARK: - Casino Player Count Button
private struct CasinoPlayerCountButton: View {
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isGlowing = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow, Color.orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(width: 60, height: 60)
            .background(playerCountButtonBackground)
            .scaleEffect(isSelected ? 1.1 : (isGlowing ? 1.02 : 1.0))
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isGlowing = true
        }
    }
    
    private var playerCountButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: isSelected ? [
                        Color.black.opacity(0.9),
                        Color.black.opacity(0.7)
                    ] : [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? [
                                Color.yellow.opacity(0.8),
                                Color.orange.opacity(0.8)
                            ] : [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .overlay(
                // 内側の光る効果
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.white.opacity(isSelected ? 0.2 : 0.1),
                        lineWidth: 1
                    )
                    .padding(1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            .shadow(color: isSelected ? Color.yellow.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 0)
    }
}

// MARK: - Casino Button Configuration
private struct CasinoButtonConfig {
    static let cpuGradient: [Color] = [
        Color.blue,
        Color.cyan,
        Color.blue.opacity(0.8)
    ]
    
    static let onlineGradient: [Color] = [
        Color.green,
        Color.mint,
        Color.green.opacity(0.8)
    ]
} 
