import SwiftUI
import Foundation

// MARK: - Game Card Validation Manager
/// カード出し判定システムを管理するクラス
/// GameViewModelから分離された独立したバリデーション機能を提供
class GameCardValidationManager: ObservableObject {
    
    // MARK: - Public Methods
    
    /// 選択されたカードが出せるかチェック
    /// - Parameters:
    ///   - selectedCards: 選択されたカード配列
    ///   - fieldCard: 場のカード
    /// - Returns: 出せるかどうかの判定結果と理由
    func canPlaySelectedCards(selectedCards: [Card], fieldCard: Card) -> (canPlay: Bool, reason: String) {
        // カードが選択されているかチェック
        if selectedCards.isEmpty {
            return (false, "カードが選択されていません")
        }
        
        // カード出しルールの検証
        return validateCardPlayRules(selectedCards: selectedCards, fieldCard: fieldCard)
    }
    
    /// カード出し判定結果の表示用メッセージを取得
    /// - Parameters:
    ///   - selectedCards: 選択されたカード配列
    ///   - fieldCard: 場のカード
    /// - Returns: 判定結果のメッセージ
    func getCardPlayValidationMessage(selectedCards: [Card], fieldCard: Card) -> String {
        let validation = canPlaySelectedCards(selectedCards: selectedCards, fieldCard: fieldCard)
        return validation.reason
    }
    
    /// 手札の合計値を計算（ジョーカー対応）
    /// - Parameter cards: 計算対象のカード配列
    /// - Returns: 可能な合計値の配列
    func calculateHandTotals(cards: [Card]) -> [Int] {
        // ジョーカーと通常カードを分離
        let jokers = cards.filter { $0.card.suit() == .joker }
        let normalCards = cards.filter { $0.card.suit() != .joker }
        
        // 通常カードの合計値
        let normalSum = normalCards.reduce(0) { sum, card in
            sum + (card.card.handValue().first ?? 0)
        }
        
        // ジョーカーがない場合
        if jokers.isEmpty {
            return [normalSum]
        }
        
        // ジョーカーがある場合の全パターン計算
        return calculateJokerHandCombinations(jokers: jokers, normalSum: normalSum)
    }
    
    // MARK: - Private Methods
    
    /// カード出しルールの検証
    /// - Parameters:
    ///   - selectedCards: 選択されたカード配列
    ///   - fieldCard: 場のカード
    /// - Returns: 検証結果と理由
    private func validateCardPlayRules(selectedCards: [Card], fieldCard: Card) -> (canPlay: Bool, reason: String) {
        let fieldCardValue = fieldCard.card.handValue().first ?? 0
        let fieldCardSuit = fieldCard.card.suit()
        
        print("🔍 カード出し判定開始")
        print("   場のカード: \(fieldCard.card.rawValue) (数字:\(fieldCardValue), スート:\(fieldCardSuit.rawValue))")
        print("   選択カード: \(selectedCards.map { "\($0.card.rawValue)" }.joined(separator: ", "))")
        
        // ルール1: 同じ数字（1枚）
        if selectedCards.count == 1 {
            let selectedCard = selectedCards[0]
            print("   ルール1チェック: 1枚のカード")
            
            // ジョーカーの場合は常に出せる
            if selectedCard.card.suit() == .joker {
                print("   ✅ ジョーカーのため出せます")
                return (true, "ジョーカーは任意のカードとして出せます")
            }
            
            // 同じ数字チェック
            if selectedCard.card.handValue().contains(fieldCardValue) {
                print("   ✅ 同じ数字のため出せます")
                return (true, "同じ数字のカードです")
            }
            
            // 同じスートチェック
            if selectedCard.card.suit() == fieldCardSuit {
                print("   ✅ 同じスートのため出せます")
                return (true, "同じスートのカードです")
            }
            
            print("   ❌ ルール1: 条件に合いません")
        }
        
        // 複数枚の場合のルールチェック
        if selectedCards.count > 1 {
            print("   複数枚のカードチェック")
            
            // ルール2: 同じ数字で複数（スート関係なし）
            let allSameNumber = selectedCards.allSatisfy { card in
                card.card.suit() == .joker || card.card.handValue().contains(fieldCardValue)
            }
            
            print("   ルール2チェック: 全て同じ数字? \(allSameNumber)")
            if allSameNumber {
                print("   ✅ 全て同じ数字のため出せます")
                return (true, "全て同じ数字のカードです")
            }
            
            // ルール4: 同じスートで複数（場と同じスートが最初に選択必須 + 全て同じ数字）
            let firstCard = selectedCards[0]
            print("   ルール4チェック: 最初のカード \(firstCard.card.rawValue)")
            
            // 最初のカードが場と同じスートまたはジョーカー
            if firstCard.card.suit() == fieldCardSuit || firstCard.card.suit() == .joker {
                print("   ルール4: 最初のカードが場と同じスートまたはジョーカー")
                
                // 全てのカードが同じ数字かチェック（ジョーカー除く）
                let nonJokerCards = selectedCards.filter { $0.card.suit() != .joker }
                print("   ルール4: ジョーカー以外のカード \(nonJokerCards.map { $0.card.rawValue })")
                
                if !nonJokerCards.isEmpty {
                    // ジョーカー以外のカードが全て同じ数字かチェック
                    let firstNonJokerValue = nonJokerCards[0].card.handValue().first ?? 0
                    let allSameNumberInSuit = nonJokerCards.allSatisfy { card in
                        card.card.handValue().contains(firstNonJokerValue)
                    }
                    
                    print("   ルール4: 最初の数字 \(firstNonJokerValue), 全て同じ数字? \(allSameNumberInSuit)")
                    
                    if allSameNumberInSuit {
                        print("   ✅ 場と同じスートから始まる同じ数字のため出せます")
                        return (true, "場と同じスートから始まる同じ数字のカードです")
                    }
                }
            } else {
                print("   ルール4: 最初のカードが場と異なるスート")
            }
            
            // ルール5: 合計が同じ（ジョーカー対応）
            print("   ルール5チェック: 合計値判定")
            let totalValidation = validateTotalSum(selectedCards: selectedCards, targetSum: fieldCardValue)
            if totalValidation.canPlay {
                print("   ✅ 合計値が一致するため出せます")
                return totalValidation
            }
        }
        
        print("   ❌ どのルールにも該当しません")
        return (false, "出せるカードの組み合わせではありません")
    }
    
    /// 合計値の検証（ジョーカー対応）
    /// - Parameters:
    ///   - selectedCards: 選択されたカード配列
    ///   - targetSum: 目標合計値
    /// - Returns: 検証結果と理由
    private func validateTotalSum(selectedCards: [Card], targetSum: Int) -> (canPlay: Bool, reason: String) {
        // ジョーカーと通常カードを分離
        let jokers = selectedCards.filter { $0.card.suit() == .joker }
        let normalCards = selectedCards.filter { $0.card.suit() != .joker }
        
        // 通常カードの合計値
        let normalSum = normalCards.reduce(0) { sum, card in
            sum + (card.card.handValue().first ?? 0)
        }
        
        // ジョーカーがない場合
        if jokers.isEmpty {
            if normalSum == targetSum {
                return (true, "合計値が一致します")
            }
            return (false, "合計値が一致しません")
        }
        
        // ジョーカーがある場合の全パターンチェック
        return checkJokerCombinations(jokers: jokers, normalSum: normalSum, targetSum: targetSum)
    }
    
    /// ジョーカーの組み合わせをチェック
    /// - Parameters:
    ///   - jokers: ジョーカーカード配列
    ///   - normalSum: 通常カードの合計値
    ///   - targetSum: 目標合計値
    /// - Returns: 検証結果と理由
    private func checkJokerCombinations(jokers: [Card], normalSum: Int, targetSum: Int) -> (canPlay: Bool, reason: String) {
        let jokerCount = jokers.count
        
        // ジョーカーの可能な値の組み合わせを生成（-1, 0, 1）
        func generateJokerCombinations(count: Int) -> [[Int]] {
            if count == 0 { return [[]] }
            if count == 1 { return [[-1], [0], [1]] }
            
            let subCombinations = generateJokerCombinations(count: count - 1)
            var combinations: [[Int]] = []
            
            for value in [-1, 0, 1] {
                for subCombination in subCombinations {
                    combinations.append([value] + subCombination)
                }
            }
            
            return combinations
        }
        
        let combinations = generateJokerCombinations(count: jokerCount)
        
        for combination in combinations {
            let jokerSum = combination.reduce(0, +)
            let totalSum = normalSum + jokerSum
            
            if totalSum == targetSum {
                let jokerDescription = combination.map { "\($0)" }.joined(separator: ", ")
                return (true, "ジョーカーを[\(jokerDescription)]として計算すると合計値が一致します")
            }
        }
        
        return (false, "ジョーカーを含めても合計値が一致しません")
    }
    
    /// ジョーカーを含む手札の全パターンを計算
    /// - Parameters:
    ///   - jokers: ジョーカーカード配列
    ///   - normalSum: 通常カードの合計値
    /// - Returns: 可能な合計値の配列
    private func calculateJokerHandCombinations(jokers: [Card], normalSum: Int) -> [Int] {
        let jokerCount = jokers.count
        
        // ジョーカーの可能な値の組み合わせを生成（-1, 0, 1）
        func generateJokerCombinations(count: Int) -> [[Int]] {
            if count == 0 { return [[]] }
            if count == 1 { return [[-1], [0], [1]] }
            
            let subCombinations = generateJokerCombinations(count: count - 1)
            var combinations: [[Int]] = []
            
            for value in [-1, 0, 1] {
                for subCombination in subCombinations {
                    combinations.append([value] + subCombination)
                }
            }
            
            return combinations
        }
        
        let combinations = generateJokerCombinations(count: jokerCount)
        var totals: [Int] = []
        
        for combination in combinations {
            let jokerSum = combination.reduce(0, +)
            let totalSum = normalSum + jokerSum
            totals.append(totalSum)
        }
        
        // 重複を除去してソート
        return Array(Set(totals)).sorted()
    }
} 