/*
 * GameSetting.swift
 * 
 * ファイル概要:
 * ドテンコゲームの設定項目を定義する列挙型
 * - ゲームルールの各種設定項目
 * - 設定可能な値の定義
 * - デフォルト値の管理  
 * - UI表示用のプロパティ
 * - 設定値の検証機能
 * 
 * 主要機能:
 * - ラウンド数、ジョーカー枚数、レートなどの設定
 * - 設定項目の表示名、説明、例文の提供
 * - 設定値の配列とデフォルト値の管理
 * - SF Symbolsアイコンの定義
 * - 特殊値（無制限、なし）の処理
 * 
 * 設定項目:
 * - roundCount: ゲームラウンド数
 * - jokerCount: ジョーカー枚数
 * - gameRate: 基本レート
 * - upRate: 重ねレートアップ条件
 * - maxScore: スコア上限
 * - deckCycle: デッキサイクル制限
 * 
 * 作成日: 2024年12月
 */

import Foundation

/// ゲームルールの設定項目を定義する列挙型
/// ドテンコゲームで使用される各種設定項目とその値を管理
enum GameSetting: String, Identifiable {
    // MARK: - Cases
    
    /// ゲームの実施回数（1ゲームあたりのラウンド数）
    case roundCount
    /// ジョーカーの枚数（0-4枚）
    case jokerCount
    /// 1ゲームあたりのレート（基本倍率）
    case gameRate
    /// 重ねレートアップ条件（連続同一数字での倍率上昇）
    case upRate
    /// スコアの上限値（1ラウンドあたりの最大スコア）
    case maxScore
    /// デッキサイクル制限（1ラウンドでのデッキ周回数上限）
    case deckCycle
    
    // MARK: - Identifiable
    
    /// Identifiableプロトコルの要件を満たすためのID
    /// - Returns: 設定項目のraw value
    var id: String { rawValue }
    
    // MARK: - View Properties
    
    /// 設定項目の表示名
    /// - Returns: UI表示用の日本語タイトル
    var title: String {
        switch self {
        case .roundCount: return "ラウンド数"
        case .jokerCount: return "ジョーカー枚数"
        case .gameRate: return "ゲームレート"
        case .upRate: return "重ねレートアップ"
        case .maxScore: return "スコア上限"
        case .deckCycle: return "デッキサイクル"
        }
    }
    
    /// 設定項目の詳細説明
    /// - Returns: 設定項目の役割を説明するテキスト
    var detail: String {
        switch self {
        case .roundCount: return "１ゲームのラウンド数を決めます"
        case .jokerCount: return "利用するジョーカーの枚数を決めます"
        case .gameRate: return "ゲームの初期レートを決めます"
        case .upRate: return "場に同じカードが何枚重なった時、レートが上がるかを決めます"
        case .maxScore: return "１ラウンドのスコア上限を決めます"
        case .deckCycle: return "１ラウンドのデッキリミットを決めます"
        }
    }
    
    /// 設定項目の使用例
    /// - Returns: 具体的な使用例を示すテキスト
    var example: String {
        switch self {
        case .roundCount: return "例：１０ラウンドで１ゲーム終了"
        case .jokerCount: return "例：ジョーカー１枚利用"
        case .gameRate: return "例：レート１０なら、最後の数字に✖︎１０をする"
        case .upRate: return "例：３の場合、同じ数字が３枚連続で出た時にレートが✖︎２される"
        case .maxScore: return "例：１０００点の場合、ラウンドスコアで算出された数字が１５００点でも１０００点がやり取りされる"
        case .deckCycle: return "例：３の場合、デッキサイクルが３周すると勝敗がつかず、ラウンドが終了となる"
        }
    }
    
    /// 設定可能な値の配列
    /// - Note: 特殊な値として "なし" や "♾️"(無制限) が含まれる場合があります
    /// - Returns: 選択可能な値の文字列配列
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
    /// - Returns: 初期設定として使用される値
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
    /// - Returns: UI表示用のシステムアイコン名
    var icon: String {
        switch self {
        case .roundCount: return "chart.bar.fill"       // グラフアイコン
        case .jokerCount: return "crown.fill"           // 王冠アイコン
        case .gameRate: return "dollarsign.circle.fill" // ドル記号アイコン
        case .upRate: return "arrow.up.forward"         // 上向き矢印アイコン
        case .maxScore: return "hand.raised.fill"       // 手のアイコン
        case .deckCycle: return "rectangle.stack.fill"  // カードスタックアイコン
        }
    }
    
    // MARK: - Helper Methods
    
    /// 値が特殊な値（"なし"や"♾️"）かどうかを判定
    /// - Parameter value: 判定対象の値
    /// - Returns: 特殊な値の場合true、通常の数値の場合false
    func isSpecialValue(_ value: String) -> Bool {
        return value == "なし" || value == "♾️"
    }
    
    /// 表示用の値を取得（特殊な値の場合は日本語表示に変換）
    /// - Parameter value: 変換対象の値
    /// - Returns: UI表示用に変換された値
    func displayValue(for value: String) -> String {
        if value == "♾️" { return "無制限" }
        if value == "なし" { return "なし" }
        return value
    }
} 
