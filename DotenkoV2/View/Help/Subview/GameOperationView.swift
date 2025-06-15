/*
 * GameOperationView.swift
 * 
 * ファイル概要:
 * ドテンコゲームでのカードの出し方を説明するヘルプビュー
 * - カードの出し方のルールを視覚的に説明
 * - 実際のトランプ画像を使った具体例
 * - 中学生にもわかりやすい図解
 * - 複数枚出しのパターン説明
 * 
 * 主要機能:
 * - 1枚出しのルール説明
 * - 複数枚出しのルール説明
 * - ジョーカーの使い方説明
 * - 具体的なカード例の表示
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Game Operation View
/// カードの出し方説明ビュー
struct GameOperationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイトル
            operationTitleView
            
            // 基本ルール
            basicRulesView
            
            // 1枚で出す場合
            singleCardRulesView
            
            // 複数枚で出す場合
            multipleCardRulesView
            
            // ジョーカーの使い方
            jokerRulesView
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Operation Title View
    /// 操作タイトル表示
    private var operationTitleView: some View {
        HStack {
            Image(systemName: "hand.point.up.left.fill")
                .font(.helpLargeTitle)
                .foregroundColor(Appearance.Color.playerGold)
            
            Text("カードの出し方")
                .helpSectionTitleStyle()
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Basic Rules View
    /// 基本ルール表示
    private var basicRulesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.playerBlue)
                
                Text("基本ルール")
                    .helpSectionTitleStyle()
                
                Spacer()
            }
            
            Text("自分のターンでは、場のカードに対して以下の条件でカードを出すことができます。")
                .helpDescriptionStyle()
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerBlue)
    }
    
    // MARK: - Single Card Rules View
    /// 1枚出しルール表示
    private var singleCardRulesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            HStack {
                Image(systemName: "1.circle.fill")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.playerGreen)
                
                Text("1枚で出す場合")
                    .helpSectionTitleStyle()
                
                Spacer()
            }
            
            // 同じ数字の例
            cardExampleView(
                title: "同じ数字",
                description: "場のカードと同じ数字のカードを出せます",
                fieldCard: PlayCard.diamond13,
                playableCards: [PlayCard.spade13],
                unplayableCards: [PlayCard.heart7, PlayCard.club2]
            )
            
            // 同じスートの例
            cardExampleView(
                title: "同じスート（マーク）",
                description: "場のカードと同じスートのカードを出せます",
                fieldCard: PlayCard.diamond13,
                playableCards: [PlayCard.diamond5],
                unplayableCards: [PlayCard.spade5, PlayCard.heart10]
            )
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerGreen)
    }
    
    // MARK: - Multiple Card Rules View
    /// 複数枚出しルール表示
    private var multipleCardRulesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            HStack {
                Image(systemName: "2.circle.fill")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.playerPurple)
                
                Text("複数枚で出す場合")
                    .helpSectionTitleStyle()
                
                Spacer()
            }
            
            // 合計が同じ例
            multipleCardExampleView(
                title: "合計が同じ",
                description: "場のカードの数字と出すカードの数字の合計が同じ",
                fieldCard: PlayCard.diamond13,
                playableCards: [PlayCard.diamond6, PlayCard.spade7],
                calculation: "6 + 7 = 13"
            )
            
            // 全て同じ数字の例
            multipleCardExampleView(
                title: "全て同じ数字",
                description: "場のカードと出すカードの数字が全て同じ",
                fieldCard: PlayCard.diamond13,
                playableCards: [PlayCard.spade13, PlayCard.club13, PlayCard.heart13],
                calculation: "13 = 13 = 13 = 13"
            )
            
            // 同じスート + 同じ数字の例
            multipleCardExampleView(
                title: "同じスート + 同じ数字",
                description: "一番下のカードが場と同じスート、出すカードが全て同じ数字",
                fieldCard: PlayCard.diamond13,
                playableCards: [PlayCard.diamond5, PlayCard.club5, PlayCard.heart5],
                calculation: "♦5が場と同じスート"
            )
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerPurple)
    }
    
    // MARK: - Joker Rules View
    /// ジョーカールール表示
    private var jokerRulesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            HStack {
                Image(systemName: "crown.fill")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.playerGold)
                
                Text("ジョーカーの使い方")
                    .helpSectionTitleStyle()
                
                Spacer()
            }
            
            // ジョーカーの説明
            VStack(alignment: .leading, spacing: 12) {
                Text("ジョーカーは万能カード！どんなカードとしても使えます。")
                    .helpDescriptionStyle()
                
                // ジョーカー例
                jokerExampleView()
            }
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerGold)
    }
    
    // MARK: - Card Example View
    /// カード例表示
    private func cardExampleView(
        title: String,
        description: String,
        fieldCard: PlayCard,
        playableCards: [PlayCard],
        unplayableCards: [PlayCard]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // タイトルと説明
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.helpSubheadline)
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Text(description)
                    .helpDescriptionStyle(color: Appearance.Color.commonWhite.opacity(0.8))
            }
            
            // カード表示
            HStack(spacing: 16) {
                // 場のカード
                VStack(spacing: 8) {
                    Text("場")
                        .helpCaptionStyle(color: Appearance.Color.commonWhite.opacity(0.7))
                    
                    RuleCardView(cardName: fieldCard.rawValue)
                }
                
                // 矢印
                Image(systemName: "arrow.right")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                
                // 出せるカード
                VStack(spacing: 8) {
                    Text("出せる")
                        .helpCaptionStyle(color: Appearance.Color.playerGreen)
                    
                    HStack(spacing: -10) {
                        ForEach(playableCards, id: \.self) { card in
                            RuleCardView(cardName: card.rawValue)
                        }
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Appearance.Color.playerGreen, lineWidth: 2)
                    )
                }
                
                Spacer()
                
                // 出せないカード
                VStack(spacing: 8) {
                    Text("出せない")
                        .helpCaptionStyle(color: Appearance.Color.playerRed)
                    
                    HStack(spacing: -10) {
                        ForEach(unplayableCards, id: \.self) { card in
                            RuleCardView(cardName: card.rawValue)
                                .opacity(0.6)
                        }
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Appearance.Color.playerRed, lineWidth: 2)
                    )
                }
            }
        }
    }
    
    // MARK: - Multiple Card Example View
    /// 複数枚カード例表示
    private func multipleCardExampleView(
        title: String,
        description: String,
        fieldCard: PlayCard,
        playableCards: [PlayCard],
        calculation: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // タイトルと説明
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.helpSubheadline)
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Text(description)
                    .helpDescriptionStyle(color: Appearance.Color.commonWhite.opacity(0.8))
            }
            
            // カード表示
            HStack(spacing: 16) {
                // 場のカード
                VStack(spacing: 8) {
                    Text("場")
                        .helpCaptionStyle(color: Appearance.Color.commonWhite.opacity(0.7))
                    
                    RuleCardView(cardName: fieldCard.rawValue)
                }
                
                // 矢印
                Image(systemName: "arrow.right")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                
                // 出せるカード
                VStack(spacing: 8) {
                    Text("出せる")
                        .helpCaptionStyle(color: Appearance.Color.playerGreen)
                    
                    HStack(spacing: -10) {
                        ForEach(playableCards, id: \.self) { card in
                            RuleCardView(cardName: card.rawValue)
                        }
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Appearance.Color.playerGreen, lineWidth: 2)
                    )
                    
                    // 計算式
                    Text(calculation)
                        .font(.helpCaption2)
                        .foregroundColor(Appearance.Color.playerGreen)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Joker Example View
    /// ジョーカー例表示
    private func jokerExampleView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("例：場が♦13の時、ジョーカーは以下のように使えます")
                .helpDescriptionStyle(color: Appearance.Color.commonWhite.opacity(0.8))
            
            HStack(spacing: 16) {
                // 場のカード
                VStack(spacing: 8) {
                    Text("場")
                        .helpCaptionStyle(color: Appearance.Color.commonWhite.opacity(0.7))
                    
                    RuleCardView(cardName: PlayCard.diamond13.rawValue)
                }
                
                // 矢印
                Image(systemName: "arrow.right")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                
                // ジョーカー
                VStack(spacing: 8) {
                    Text("ジョーカー")
                        .helpCaptionStyle(color: Appearance.Color.playerGold)
                    
                    RuleCardView(cardName: PlayCard.blackJoker.rawValue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Appearance.Color.playerGold, lineWidth: 2)
                        )
                    
                    Text("何でもOK！")
                        .font(.helpCaption2)
                        .foregroundColor(Appearance.Color.playerGold)
                }
                
                Spacer()
            }
        }
    }
    

}

// MARK: - Rule Card View
/// ルール説明用カードビュー
struct RuleCardView: View {
    let cardName: String
    
    var body: some View {
        Image(cardName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 2, x: 0, y: 1)
    }
} 