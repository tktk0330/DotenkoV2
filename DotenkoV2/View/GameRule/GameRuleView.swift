import SwiftUI
import Foundation

/// ゲームルール設定画面のView
struct GameRuleView: View {
    // MARK: - Properties
    
    /// ゲームルール設定のViewModel
    @StateObject private var viewModel = GameRuleViewModel()
    
    /// 画面を閉じるための環境値
    @Environment(\.dismiss) private var dismiss
    
    /// 現在選択中の設定項目
    @State private var selectedSetting: GameSetting?
    
    // MARK: - View Body
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    
                    // 設定項目グリッド
                    VStack(spacing: 24) {
                        // 1段目: ゲーム数とジョーカー
                        HStack(spacing: 16) {
                            makeSettingCard(.roundCount)
                            makeSettingCard(.jokerCount)
                        }
                        
                        // 2段目: レートと最大掛け金
                        HStack(spacing: 16) {
                            makeSettingCard(.gameRate)
                            makeSettingCard(.maxScore)
                        }
                        
                        // 3段目: アップレートとデッキ
                        HStack(spacing: 16) {
                            makeSettingCard(.upRate)
                            makeSettingCard(.deckCycle)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.vertical, 20)
            }
        }
        .sheet(item: $selectedSetting) { setting in
            GameRuleSettingModal(
                title: setting.title,
                setting: setting,
                currentValue: getCurrentValue(for: setting)
            ) { newValue in
                updateValue(setting, with: newValue)
            }
            .presentationDetents([.height(400)])
        }
    }
    
    // MARK: - Helper Views
    
    /// 設定カードを生成
    /// - Parameter setting: 設定項目の種類
    /// - Returns: 設定カードのView
    private func makeSettingCard(_ setting: GameSetting) -> some View {
        CasinoSettingCard(
            icon: setting.icon,
            title: setting.title,
            value: getDisplayValue(for: setting),
            isEnabled: true,
            onTap: { selectedSetting = setting }
        )
    }
    
    // MARK: - Helper Methods
    
    /// 表示用の値を取得
    /// - Parameter setting: 設定項目の種類
    /// - Returns: 表示用に変換された値
    private func getDisplayValue(for setting: GameSetting) -> String {
        let value = getCurrentValue(for: setting)
        return viewModel.getDisplayValue(value, for: setting)
    }
    
    /// 現在の設定値を取得
    /// - Parameter setting: 設定項目の種類
    /// - Returns: 現在の設定値（オプショナルの場合はデフォルト値を使用）
    private func getCurrentValue(for setting: GameSetting) -> String {
        switch setting {
        case .roundCount: return viewModel.gameRule.roundCount
        case .jokerCount: return viewModel.gameRule.jokerCount
        case .gameRate: return viewModel.gameRule.gameRate
        case .maxScore: return viewModel.gameRule.maxScore ?? setting.defaultValue
        case .upRate: return viewModel.gameRule.upRate ?? setting.defaultValue
        case .deckCycle: return viewModel.gameRule.deckCycle ?? setting.defaultValue
        }
    }
    
    /// 設定値を更新
    /// - Parameters:
    ///   - setting: 設定項目の種類
    ///   - value: 新しい値
    private func updateValue(_ setting: GameSetting, with value: String) {
        switch setting {
        case .roundCount: viewModel.updateRoundCount(value)
        case .jokerCount: viewModel.updateJokerCount(value)
        case .gameRate: viewModel.updateGameRate(value)
        case .maxScore: viewModel.updateMaxScore(value)
        case .upRate: viewModel.updateUpRate(value)
        case .deckCycle: viewModel.updateDeckCycle(value)
        }
    }
}

// MARK: - Casino Setting Card
struct CasinoSettingCard: View {
    let icon: String
    let title: String
    let value: String
    let isEnabled: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 16) {
            // アイコンとタイトル
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.cyan,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // 値表示
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.yellow,
                            Color.orange
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding(16)
        .background(casinoCardBackground)
        .scaleEffect(isPressed ? 0.95 : (isGlowing ? 1.02 : 1.0))
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            isGlowing = true
        }
    }
    
    private var casinoCardBackground: some View {
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
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.cyan.opacity(0.6)
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
            .shadow(color: Color.blue.opacity(0.2), radius: 12, x: 0, y: 0)
    }
}

// MARK: - Legacy Support
struct SettingCard: View {
    let icon: String
    let title: String
    let value: String
    let isEnabled: Bool
    
    var body: some View {
        CasinoSettingCard(
            icon: icon,
            title: title,
            value: value,
            isEnabled: isEnabled,
            onTap: {}
        )
    }
}

