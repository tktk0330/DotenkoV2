import Foundation
import SwiftUI

/// ゲームルール設定画面のビジネスロジックを管理するViewModel
class GameRuleViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// ゲームルールの設定値
    @Published var gameRule = GameRuleModel()
    
    // MARK: - Update Methods
    
    /// ゲーム数を更新
    /// - Parameter value: 新しいゲーム数の値
    func updateRoundCount(_ value: String) {
        gameRule.roundCount = value
    }
    
    /// ジョーカーの枚数を更新
    /// - Parameter value: 新しいジョーカー枚数の値
    func updateJokerCount(_ value: String) {
        gameRule.jokerCount = value
    }
    
    /// レートを更新
    /// - Parameter value: 新しいレートの値
    func updateGameRate(_ value: String) {
        gameRule.gameRate = value
    }
    
    /// 最大掛け金を更新
    /// - Parameter value: 新しい最大掛け金の値
    func updateMaxScore(_ value: String) {
        gameRule.maxScore = value
    }
    
    /// アップレートを更新
    /// - Parameter value: 新しいアップレートの値
    func updateUpRate(_ value: String) {
        gameRule.upRate = value
    }
    
    /// デッキサイクルを更新
    /// - Parameter value: 新しいデッキサイクルの値
    func updateDeckCycle(_ value: String) {
        gameRule.deckCycle = value
    }
    
    // MARK: - Helper Methods
    
    /// 設定値が有効かどうかを確認
    /// - Parameters:
    ///   - value: 確認する値
    ///   - setting: 設定項目の種類
    /// - Returns: 値が有効な場合はtrue
    func isValidValue(_ value: String, for setting: GameSetting) -> Bool {
        setting.values.contains(value)
    }
    
    /// 表示用の値を取得
    /// - Parameters:
    ///   - value: 元の値
    ///   - setting: 設定項目の種類
    /// - Returns: 表示用に変換された値
    func getDisplayValue(_ value: String, for setting: GameSetting) -> String {
        switch setting {
        case .maxScore, .upRate, .deckCycle:
            return value == "♾️" ? "無制限" : value
        default:
            return value
        }
    }
    
    /// 全ての設定値が有効かどうかを確認
    var isValid: Bool {
        isValidValue(gameRule.roundCount, for: .roundCount) &&
        isValidValue(gameRule.jokerCount, for: .jokerCount) &&
        isValidValue(gameRule.gameRate, for: .gameRate) &&
        (gameRule.maxScore.map { isValidValue($0, for: .maxScore) } ?? true) &&
        (gameRule.upRate.map { isValidValue($0, for: .upRate) } ?? true) &&
        (gameRule.deckCycle.map { isValidValue($0, for: .deckCycle) } ?? true)
    }
}

