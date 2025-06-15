/*
 * GameDetailRuleCommonView.swift
 * 
 * ファイル概要:
 * ドテンコゲームのカスタムルール詳細説明ビュー
 * - GameSettingの各項目の詳細説明
 * - 中学生にもわかりやすい視覚的な表現
 * - 設定値の影響と具体例の説明
 * - 設定可能な値の一覧表示
 * 
 * 主要機能:
 * - ラウンド数、ジョーカー枚数などの設定説明
 * - 各設定値の影響説明
 * - 具体的な計算例の表示
 * - 推奨設定の提案
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Game Detail Rule Common View
/// カスタムルール詳細説明ビュー
struct GameDetailRuleCommonView: View {
    let type: GameSetting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイトル
            ruleDetailTitleView
            
            // 基本説明
            basicDescriptionView
            
            // 設定値一覧
            settingValuesView
            
            // 具体例
            exampleView
            
            // 推奨設定
            recommendationView
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Rule Detail Title View
    /// ルール詳細タイトル表示
    private var ruleDetailTitleView: some View {
        HStack {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
            
            Text(type.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Appearance.Color.commonWhite)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Basic Description View
    /// 基本説明表示
    private var basicDescriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerBlue)
                
                Text("基本説明")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            Text(type.detail)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(ruleBackground(color: Appearance.Color.playerBlue))
    }
    
    // MARK: - Setting Values View
    /// 設定値一覧表示
    private var settingValuesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGreen)
                
                Text("設定可能な値")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            // 設定値グリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(type.values, id: \.self) { value in
                    settingValueItem(value: value)
                }
            }
        }
        .padding(16)
        .background(ruleBackground(color: Appearance.Color.playerGreen))
    }
    
    // MARK: - Example View
    /// 具体例表示
    private var exampleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerOrange)
                
                Text("具体例")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            Text(type.example)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // 設定別の詳細例
            detailedExampleView
        }
        .padding(16)
        .background(ruleBackground(color: Appearance.Color.playerOrange))
    }
    
    // MARK: - Recommendation View
    /// 推奨設定表示
    private var recommendationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                
                Text("推奨設定")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                recommendationItem(
                    title: "デフォルト値",
                    value: type.defaultValue,
                    description: getDefaultDescription()
                )
                
                if let customRecommendation = getCustomRecommendation() {
                    recommendationItem(
                        title: customRecommendation.title,
                        value: customRecommendation.value,
                        description: customRecommendation.description
                    )
                }
            }
        }
        .padding(16)
        .background(ruleBackground(color: Appearance.Color.playerGold))
    }
    
    // MARK: - Setting Value Item
    /// 設定値アイテム表示
    private func settingValueItem(value: String) -> some View {
        VStack(spacing: 4) {
            Text(type.displayValue(for: value))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(value == type.defaultValue ? Appearance.Color.playerGold : Appearance.Color.commonWhite)
            
            if value == type.defaultValue {
                Text("デフォルト")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Appearance.Color.playerGold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    value == type.defaultValue ?
                    Appearance.Color.playerGold.opacity(0.2) :
                    Appearance.Color.commonWhite.opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            value == type.defaultValue ?
                            Appearance.Color.playerGold.opacity(0.6) :
                            Appearance.Color.commonWhite.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Detailed Example View
    /// 詳細例表示
    private var detailedExampleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch type {
            case .roundCount:
                roundCountExamples
            case .jokerCount:
                jokerCountExamples
            case .gameRate:
                gameRateExamples
            case .upRate:
                upRateExamples
            case .maxScore:
                maxScoreExamples
            case .deckCycle:
                deckCycleExamples
            }
        }
    }
    
    // MARK: - Round Count Examples
    /// ラウンド数例
    private var roundCountExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("1ラウンド", "短時間でサクッと勝負", Appearance.Color.playerCyan)
            exampleItem("5ラウンド", "バランスの良いゲーム時間", Appearance.Color.playerGreen)
            exampleItem("20ラウンド", "じっくり長時間プレイ", Appearance.Color.playerPurple)
        }
    }
    
    // MARK: - Joker Count Examples
    /// ジョーカー枚数例
    private var jokerCountExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("0枚", "純粋な運と戦略勝負", Appearance.Color.playerRed)
            exampleItem("2枚", "適度な戦略性", Appearance.Color.playerGreen)
            exampleItem("4枚", "戦略重視のゲーム", Appearance.Color.playerBlue)
        }
    }
    
    // MARK: - Game Rate Examples
    /// ゲームレート例
    private var gameRateExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("1", "低リスク・低リターン", Appearance.Color.playerGreen)
            exampleItem("10", "標準的なスコア", Appearance.Color.playerBlue)
            exampleItem("100", "ハイリスク・ハイリターン", Appearance.Color.playerRed)
        }
    }
    
    // MARK: - Up Rate Examples
    /// 重ねレートアップ例
    private var upRateExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("なし", "レートアップなし", Appearance.Color.playerGray)
            exampleItem("3", "3枚連続で×2倍", Appearance.Color.playerOrange)
            exampleItem("4", "4枚連続で×2倍（発生しにくい）", Appearance.Color.playerRed)
        }
    }
    
    // MARK: - Max Score Examples
    /// 最大スコア例
    private var maxScoreExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("1000", "安定したスコア制限", Appearance.Color.playerGreen)
            exampleItem("5000", "大きなスコア変動", Appearance.Color.playerOrange)
            exampleItem("無制限", "青天井のスコア", Appearance.Color.playerRed)
        }
    }
    
    // MARK: - Deck Cycle Examples
    /// デッキサイクル例
    private var deckCycleExamples: some View {
        VStack(alignment: .leading, spacing: 6) {
            exampleItem("1", "短期決戦", Appearance.Color.playerRed)
            exampleItem("3", "適度な長さ", Appearance.Color.playerGreen)
            exampleItem("無制限", "決着がつくまで", Appearance.Color.playerBlue)
        }
    }
    
    // MARK: - Example Item
    /// 例アイテム表示
    private func exampleItem(_ value: String, _ description: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Recommendation Item
    /// 推奨アイテム表示
    private func recommendationItem(title: String, value: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                
                Text(type.displayValue(for: value))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Appearance.Color.playerGold.opacity(0.2))
                    )
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Rule Background
    /// ルール背景
    private func ruleBackground(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.1),
                        color.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        color.opacity(0.3),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Helper Methods
    
    /// デフォルト値の説明を取得
    private func getDefaultDescription() -> String {
        switch type {
        case .roundCount:
            return "初心者から上級者まで楽しめるバランスの良い設定です"
        case .jokerCount:
            return "戦略性と運のバランスが取れた標準設定です"
        case .gameRate:
            return "スコアの変動が穏やかで安定したゲームができます"
        case .upRate:
            return "適度にレートアップが発生する設定です"
        case .maxScore:
            return "大きすぎないスコア変動で安定したゲームができます"
        case .deckCycle:
            return "適度な長さでゲームが進行する設定です"
        }
    }
    
    /// カスタム推奨設定を取得
    private func getCustomRecommendation() -> (title: String, value: String, description: String)? {
        switch type {
        case .roundCount:
            return ("短時間プレイ", "3", "忙しい時や初心者におすすめ")
        case .jokerCount:
            return ("戦略重視", "4", "より戦略的なゲームを楽しみたい方におすすめ")
        case .gameRate:
            return ("エキサイティング", "50", "大きなスコア変動を楽しみたい方におすすめ")
        case .upRate:
            return ("シンプル", "なし", "レートアップなしのシンプルなゲーム")
        case .maxScore:
            return ("ハイリスク", "10000", "大きなスコア変動を楽しみたい方におすすめ")
        case .deckCycle:
            return ("短期決戦", "1", "素早く決着をつけたい方におすすめ")
        }
    }
} 