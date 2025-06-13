/*
 * GameRuleModel.swift
 * 
 * ファイル概要:
 * ドテンコゲームのルール設定を管理するデータモデル
 * - ゲーム設定値の保持
 * - UserProfileRepositoryからのデフォルト値取得
 * - ゲーム初期化時の設定値提供
 * - 可変的なゲームルール管理
 * 
 * 主要機能:
 * - ラウンド数、ジョーカー枚数の管理
 * - レート、スコア上限の設定
 * - デッキサイクル制限の管理
 * - Optional値による制限なし設定対応
 * - 柔軟な初期化オプション
 * 
 * データ構造:
 * - String型による設定値保存
 * - Optional型による制限なし表現
 * - UserProfileRepositoryとの連携
 * 
 * 作成日: 2024年12月
 */

import Foundation

// MARK: - Game Rule Model
/// ゲームルールの設定値を保持するデータモデル
/// ドテンコゲームの各種ルール設定を管理し、ゲーム初期化時に使用される
struct GameRuleModel {
    
    // MARK: - Properties
    
    /// ゲーム数の設定値（1ゲームあたりのラウンド数）
    /// - Note: デフォルト値は5ゲーム
    /// - Note: UserProfileRepositoryから取得
    var roundCount: String = UserProfileRepository.shared.roundCount
    
    /// ジョーカーの枚数（0-4枚）
    /// - Note: デフォルト値は2枚
    /// - Note: UserProfileRepositoryから取得
    var jokerCount: String = UserProfileRepository.shared.jokerCount
    
    /// 1ゲームあたりのレート（基本倍率）
    /// - Note: デフォルト値は1ポイント
    /// - Note: UserProfileRepositoryから取得
    var gameRate: String = UserProfileRepository.shared.gameRate
    
    /// 最大掛け金（1ラウンドのスコア上限）
    /// - Note: デフォルト値は1000ポイント
    /// - Note: nilの場合は制限なし
    /// - Note: UserProfileRepositoryから取得
    var maxScore: String? = UserProfileRepository.shared.maxScore
    
    /// アップレート（重ねレートアップ条件）
    /// - Note: デフォルト値は3倍
    /// - Note: nilの場合は制限なし（レートアップなし）
    /// - Note: UserProfileRepositoryから取得
    var upRate: String? = UserProfileRepository.shared.upRate
    
    /// デッキサイクル（1ラウンドでのデッキ周回数上限）
    /// - Note: デフォルト値は3回
    /// - Note: nilの場合は制限なし
    /// - Note: UserProfileRepositoryから取得
    var deckCycle: String? = UserProfileRepository.shared.deckCycle
    
    // MARK: - Initialization
    
    /// デフォルト値で初期化
    /// UserProfileRepositoryの現在の設定値を使用して初期化
    init() {}
    
    /// 指定された値で初期化
    /// - Parameters:
    ///   - roundCount: ラウンド数
    ///   - jokerCount: ジョーカー枚数
    ///   - gameRate: ゲームレート
    ///   - maxScore: 最大スコア（Optional）
    ///   - upRate: 重ねレートアップ条件（Optional）
    ///   - deckCycle: デッキサイクル制限（Optional）
    init(
        roundCount: String = UserProfileRepository.shared.roundCount,
        jokerCount: String = UserProfileRepository.shared.jokerCount,
        gameRate: String = UserProfileRepository.shared.gameRate,
        maxScore: String? = UserProfileRepository.shared.maxScore,
        upRate: String? = UserProfileRepository.shared.upRate,
        deckCycle: String? = UserProfileRepository.shared.deckCycle
    ) {
        self.roundCount = roundCount
        self.jokerCount = jokerCount
        self.gameRate = gameRate
        self.maxScore = maxScore
        self.upRate = upRate
        self.deckCycle = deckCycle
    }
}
