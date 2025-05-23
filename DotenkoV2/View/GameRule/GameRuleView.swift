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
        VStack(spacing: 24) {
            // 設定項目グリッド
            VStack(spacing: 20) {
                // 1段目: ゲーム数とジョーカー
                HStack(spacing: 20) {
                    makeSettingCard(.roundCount)
                    makeSettingCard(.jokerCount)
                }
                
                // 2段目: レートと最大掛け金
                HStack(spacing: 20) {
                    makeSettingCard(.gameRate)
                    makeSettingCard(.maxScore)
                }
                
                // 3段目: アップレートとデッキ
                HStack(spacing: 20) {
                    makeSettingCard(.upRate)
                    makeSettingCard(.deckCycle)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        SettingCard(
            icon: setting.icon,
            title: setting.title,
            value: getDisplayValue(for: setting),
            isEnabled: true
        )
        .onTapGesture { selectedSetting = setting }
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

struct SettingCard: View {
    let icon: String
    let title: String
    let value: String
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: Appearance.Color.mossGreen))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
        )
    }
}

