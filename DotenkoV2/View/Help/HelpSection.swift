import SwiftUI

// MARK: - Help Item Model
/// ヘルプアイテムモデル
struct HelpItem: Hashable {
    let type: RuleDetail
}

// MARK: - Help Section Enum
/// ヘルプセクション定義
enum HelpSection: CaseIterable {
    case basicRule      // 基本ルール
    case customRule     // カスタムルール
    case contact        // お問い合わせ
    case review         // アプリレビュー
    case privacy        // プライバシーポリシー・利用規約
    
    /// セクションタイトル
    var title: String {
        switch self {
        case .basicRule: return "基本ルール"
        case .customRule: return "カスタムルール"
        case .contact: return "お問い合わせ"
        case .review: return "アプリレビュー"
        case .privacy: return "プライバシーポリシー・利用規約"
        }
    }
    
    /// セクション説明文
    var description: String {
        switch self {
        case .basicRule: return "ドテンコの基本的なルールや操作方法を確認できます。"
        case .customRule: return "ゲーム設定の詳細な説明を確認できます。"
        case .contact: return "サポートチームへの問い合わせ方法を確認できます。"
        case .review: return "よろしければ評価・ご意見・感想等をお願いいたします。"
        case .privacy: return "本アプリのプライバシーポリシー・利用規約を確認できます。"
        }
    }
    
    /// セクション内のヘルプアイテム一覧
    var items: [HelpItem] {
        switch self {
        case .basicRule:
            return [
                HelpItem(type: .aboutDotenko),
                HelpItem(type: .flow),
                HelpItem(type: .operation),
                HelpItem(type: .event),
                HelpItem(type: .card),
            ]
        case .customRule:
            return [
                HelpItem(type: .roundCount),
                HelpItem(type: .jokerCount),
                HelpItem(type: .gameRate),
                HelpItem(type: .maxScore),
                HelpItem(type: .upRate),
                HelpItem(type: .deckCycle),
            ]
        case .contact:
            return [HelpItem(type: .contact)]
        case .review:
            return [HelpItem(type: .review)]
        case .privacy:
            return [
                HelpItem(type: .privacyPoricy),
                HelpItem(type: .poricy),
            ]
        }
    }
}

// MARK: - Rule Detail Enum
/// ルール詳細項目定義
enum RuleDetail {
    // 基本ルール関連
    case aboutDotenko   // どてんことは
    case flow          // ゲームの流れ
    case operation     // カードの出し方
    case event         // イベント
    case card          // カードについて
    
    // カスタムルール関連
    case roundCount    // ラウンド数
    case jokerCount    // ジョーカー枚数
    case gameRate      // ゲームレート
    case upRate        // 上昇レート
    case maxScore      // 最大スコア
    case deckCycle     // デッキサイクル
    
    // お問い合わせ関連
    case contact       // お問い合わせ
    
    // レビュー関連
    case review        // レビュー
    
    // プライバシー関連
    case privacyPoricy // プライバシーポリシー
    case poricy        // 利用規約
    
    /// 項目タイトル
    var title: String {
        switch self {
        case .aboutDotenko: return "どてんことは"
        case .flow: return "ゲームの流れ"
        case .operation: return "カードの出し方"
        case .event: return "イベント"
        case .card: return "カードについて"
        case .roundCount: return GameSetting.roundCount.title
        case .jokerCount: return GameSetting.jokerCount.title
        case .gameRate: return GameSetting.gameRate.title
        case .upRate: return GameSetting.upRate.title
        case .maxScore: return GameSetting.maxScore.title
        case .deckCycle: return GameSetting.deckCycle.title
        case .contact: return "お問い合わせ"
        case .review: return "レビュー"
        case .privacyPoricy: return "プライバシーポリシー"
        case .poricy: return "利用規約"
        }
    }
    
    /// 項目アイコン
    var icon: String {
        switch self {
        // 基本ルール関連のアイコン
        case .aboutDotenko: return "questionmark.circle.fill"
        case .flow: return "arrow.triangle.2.circlepath"
        case .operation: return "hand.point.up.left.fill"
        case .event: return "star.fill"
        case .card: return "rectangle.portrait.fill"
        
        // カスタムルール関連（GameSettingから取得）
        case .roundCount: return GameSetting.roundCount.icon
        case .jokerCount: return GameSetting.jokerCount.icon
        case .gameRate: return GameSetting.gameRate.icon
        case .upRate: return GameSetting.upRate.icon
        case .maxScore: return GameSetting.maxScore.icon
        case .deckCycle: return GameSetting.deckCycle.icon
        
        // その他のアイコン
        case .contact: return "envelope.fill"
        case .review: return "star.bubble.fill"
        case .privacyPoricy: return "lock.shield.fill"
        case .poricy: return "doc.text.fill"
        }
    }
}
