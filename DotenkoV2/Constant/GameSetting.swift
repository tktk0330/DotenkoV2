import Foundation

/// ゲームルールの設定項目を定義する列挙型
enum GameSetting: String, Identifiable {
    // MARK: - Cases
    
    /// ゲームの実施回数
    case roundCount
    /// ジョーカーの枚数
    case jokerCount
    /// 1ゲームあたりのレート
    case gameRate
    /// スコアの上限値
    case upRate
    /// 重ねレートの上限値
    case maxScore
    /// デッキの種類
    case deckCycle
    
    // MARK: - Identifiable
    
    /// Identifiableプロトコルの要件を満たすためのID
    var id: String { rawValue }
    
    // MARK: - View Properties
    
    /// 設定項目の表示名
    var title: String {
        switch self {
        case .roundCount: return "ゲーム数"
        case .jokerCount: return "ジョーカー"
        case .gameRate: return "レート"
        case .upRate: return "重ねレートアップ"
        case .maxScore: return "スコア上限"
        case .deckCycle: return "デッキ"
        }
    }
    
    /// 設定可能な値の配列
    /// - Note: 特殊な値として "なし" や "♾️"(無制限) が含まれる場合があります
    var values: [String] {
        switch self {
        case .roundCount:
            // 1ゲーム、2ゲーム、3ゲーム、5ゲーム、10ゲーム、20ゲーム
            return ["1", "2", "3", "5", "10", "20"]
        case .jokerCount:
            // ジョーカーなし(0枚)から最大4枚まで
            return ["0", "1", "2", "3", "4"]
        case .gameRate:
            // 1ポイント、5ポイント、10ポイント、50ポイント、100ポイント
            return ["1", "5", "10", "50", "100"]
        case .upRate:
            // なし、3倍、4倍
            return ["なし", "3", "4"]
        case .maxScore:
            // 1000ポイント、3000ポイント、5000ポイント、10000ポイント、無制限
            return ["1000", "3000", "5000", "10000", "♾️"]
        case .deckCycle:
            // 1回から10回まで、および無制限
            return ["1", "2", "3", "4", "5", "10", "♾️"]
        }
    }
    
    /// 各設定項目のデフォルト値
    var defaultValue: String {
        switch self {
        case .roundCount: return "5"    // 5ゲーム
        case .jokerCount: return "2"    // ジョーカー2枚
        case .gameRate: return "1"      // 1ポイント
        case .upRate: return "3"        // 3倍
        case .maxScore: return "1000"   // 1000ポイント
        case .deckCycle: return "3"     // 3回
        }
    }
    
    /// 各設定項目のアイコン（SF Symbols）
    var icon: String {
        switch self {
        case .roundCount: return "chart.bar.fill"       // グラフアイコン
        case .jokerCount: return "crown.fill"           // 王冠アイコン
        case .gameRate: return "dollarsign.circle.fill" // ドル記号アイコン
        case .upRate: return "hand.raised.fill"         // 手のアイコン
        case .maxScore: return "arrow.up.forward"       // 上向き矢印アイコン
        case .deckCycle: return "rectangle.stack.fill"  // カードスタックアイコン
        }
    }
    
    // MARK: - Helper Methods
    
    /// 値が特殊な値（"なし"や"♾️"）かどうかを判定
    func isSpecialValue(_ value: String) -> Bool {
        return value == "なし" || value == "♾️"
    }
    
    /// 表示用の値を取得（特殊な値の場合は日本語表示に変換）
    func displayValue(for value: String) -> String {
        if value == "♾️" { return "無制限" }
        if value == "なし" { return "なし" }
        return value
    }
} 
