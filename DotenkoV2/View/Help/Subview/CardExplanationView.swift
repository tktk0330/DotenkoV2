/*
 * CardExplanationView.swift
 * 
 * ファイル概要:
 * ドテンコゲームでのカードの特殊効果を説明するヘルプビュー
 * - ジョーカー、1・2、3の特殊効果説明
 * - 実際のトランプ画像を使った視覚的な説明
 * - 中学生にもわかりやすい図解
 * - 手札での価値とゲーム効果の説明
 * 
 * 主要機能:
 * - ジョーカーの万能性説明
 * - 1・2のレート倍増効果説明
 * - 3の特殊効果説明（逆転・30倍）
 * - 各カードの具体的な使用例
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Card Explanation View
/// カード特殊効果説明ビュー
struct CardExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイトル
            cardTitleView
            
            // ジョーカーの説明
            jokerExplanationView
            
            // 1・2の説明
            oneAndTwoExplanationView
            
            // 3の説明
            threeExplanationView
            
            // その他のカード
            otherCardsExplanationView
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Card Title View
    /// カードタイトル表示
    private var cardTitleView: some View {
        HStack {
            Image(systemName: "rectangle.portrait.fill")
                .helpBoldLargeTitleStyle(color: Appearance.Color.playerGold)
            
            Text("カードについて")
                .helpSectionTitleStyle()
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Joker Explanation View
    /// ジョーカー説明表示
    private var jokerExplanationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            cardSectionTitle(
                title: "ジョーカー",
                icon: "crown.fill",
                color: Appearance.Color.playerGold
            )
            
            // ジョーカーカード表示
            HStack(spacing: 16) {
                RuleCardView(cardName: PlayCard.blackJoker.rawValue)
                RuleCardView(cardName: PlayCard.whiteJoker.rawValue)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("万能カード！")
                        .helpBoldHeadlineStyle(color: Appearance.Color.playerGold)
                    
                    Text("どんなカードとしても使えます")
                        .helpDescriptionStyle()
                }
                
                Spacer()
            }
            
            // 手札での価値
            cardEffectSection(
                title: "手札での価値",
                icon: "hand.raised.fill",
                color: Appearance.Color.playerBlue,
                description: "-1、0、1のいずれかとして扱うことができます"
            )
            
            // ジョーカー例
            jokerHandExampleView()
            
            // ゲーム効果
            VStack(alignment: .leading, spacing: 8) {
                cardEffectSection(
                    title: "ゲーム効果",
                    icon: "sparkles",
                    color: Appearance.Color.playerOrange,
                    description: "ゲーム開始時・点数計算時にレートを×2します"
                )
                
                effectExampleView(
                    phase: "ゲーム開始",
                    effect: "最初のカードがジョーカー → レート×2",
                    color: Appearance.Color.playerOrange
                )
                
                effectExampleView(
                    phase: "点数計算",
                    effect: "山札の底がジョーカー → レート×2",
                    color: Appearance.Color.playerOrange
                )
            }
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerGold)
    }
    
    // MARK: - One And Two Explanation View
    /// 1・2の説明表示
    private var oneAndTwoExplanationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            cardSectionTitle(
                title: "1・2のカード",
                icon: "1.circle.fill",
                color: Appearance.Color.playerBlue
            )
            
            // 1・2カード表示
            HStack(spacing: 8) {
                RuleCardView(cardName: PlayCard.spade1.rawValue)
                RuleCardView(cardName: PlayCard.heart1.rawValue)
                RuleCardView(cardName: PlayCard.diamond2.rawValue)
                RuleCardView(cardName: PlayCard.club2.rawValue)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("レート倍増カード")
                        .helpBoldHeadlineStyle(color: Appearance.Color.playerBlue)
                    
                    Text("特別な効果があります")
                        .helpDescriptionStyle()
                }
                
                Spacer()
            }
            
            // 手札での価値
            cardEffectSection(
                title: "手札での価値",
                icon: "hand.raised.fill",
                color: Appearance.Color.playerGreen,
                description: "そのままの数字として扱います（1は1、2は2）"
            )
            
            // ゲーム効果
            VStack(alignment: .leading, spacing: 8) {
                cardEffectSection(
                    title: "ゲーム効果",
                    icon: "arrow.up.circle.fill",
                    color: Appearance.Color.playerBlue,
                    description: "ゲーム開始時・点数計算時にレートを×2します"
                )
                
                effectExampleView(
                    phase: "ゲーム開始",
                    effect: "最初のカードが1または2 → レート×2",
                    color: Appearance.Color.playerBlue
                )
                
                effectExampleView(
                    phase: "点数計算",
                    effect: "山札の底が1または2 → レート×2",
                    color: Appearance.Color.playerBlue
                )
            }
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerBlue)
    }
    
    // MARK: - Three Explanation View
    /// 3の説明表示
    private var threeExplanationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            cardSectionTitle(
                title: "3のカード",
                icon: "3.circle.fill",
                color: Appearance.Color.playerPurple
            )
            
            // 手札での価値
            cardEffectSection(
                title: "手札での価値",
                icon: "hand.raised.fill",
                color: Appearance.Color.playerGreen,
                description: "すべて3として扱います"
            )
            
            // スペード・クラブの3
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    RuleCardView(cardName: PlayCard.spade3.rawValue)
                    RuleCardView(cardName: PlayCard.club3.rawValue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("♠3・♣3")
                            .helpBoldHeadlineStyle(color: Appearance.Color.playerPurple)
                        
                        Text("逆転カード")
                            .helpBoldSubheadlineStyle(color: Appearance.Color.playerRed)
                    }
                    
                    Spacer()
                }
                
                cardEffectSection(
                    title: "特殊効果",
                    icon: "arrow.clockwise.circle.fill",
                    color: Appearance.Color.playerRed,
                    description: "点数計算時に勝敗を無条件で逆転させます"
                )
                
                effectExampleView(
                    phase: "点数計算",
                    effect: "山札の底が♠3または♣3 → 勝者と敗者が入れ替わる",
                    color: Appearance.Color.playerRed
                )
            }
            
            // ダイヤの3
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    RuleCardView(cardName: PlayCard.diamond3.rawValue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("♦3")
                            .helpBoldHeadlineStyle(color: Appearance.Color.playerPurple)
                        
                        Text("30倍カード")
                            .helpBoldSubheadlineStyle(color: Appearance.Color.playerGold)
                    }
                    
                    Spacer()
                }
                
                cardEffectSection(
                    title: "特殊効果",
                    icon: "star.circle.fill",
                    color: Appearance.Color.playerGold,
                    description: "点数計算時に数字を30として扱います"
                )
                
                effectExampleView(
                    phase: "点数計算",
                    effect: "山札の底が♦3 → 3ではなく30として計算",
                    color: Appearance.Color.playerGold
                )
            }
            
            // ハートの3
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    RuleCardView(cardName: PlayCard.heart3.rawValue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("♥3")
                            .helpBoldHeadlineStyle(color: Appearance.Color.playerPurple)
                        
                        Text("通常の3")
                            .helpDescriptionStyle(color: Appearance.Color.commonWhite.opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                cardEffectSection(
                    title: "効果",
                    icon: "circle.fill",
                    color: Appearance.Color.playerGreen,
                    description: "特殊効果はありません。普通の3として扱います"
                )
            }
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerPurple)
    }
    
    // MARK: - Other Cards Explanation View
    /// その他のカード説明表示
    private var otherCardsExplanationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // セクションタイトル
            cardSectionTitle(
                title: "その他のカード（4〜13）",
                icon: "rectangle.grid.2x2.fill",
                color: Appearance.Color.playerGreen
            )
            
            // カード表示
            HStack(spacing: 8) {
                RuleCardView(cardName: PlayCard.heart4.rawValue)
                RuleCardView(cardName: PlayCard.spade7.rawValue)
                RuleCardView(cardName: PlayCard.diamond10.rawValue)
                RuleCardView(cardName: PlayCard.club13.rawValue)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("通常のカード")
                        .helpBoldHeadlineStyle(color: Appearance.Color.playerGreen)
                    
                    Text("そのままの数字で使用")
                        .helpDescriptionStyle()
                }
                
                Spacer()
            }
            
            cardEffectSection(
                title: "効果",
                icon: "equal.circle.fill",
                color: Appearance.Color.playerGreen,
                description: "特殊効果はありません。カードに書かれた数字のまま利用します"
            )
        }
        .padding(16)
        .ruleBackground(color: Appearance.Color.playerGreen)
    }
    
    // MARK: - Joker Hand Example View
    /// ジョーカー手札例表示
    private func jokerHandExampleView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("例：ジョーカーを含む手札の価値")
                .helpBoldSubheadlineStyle()
            
            HStack(spacing: 16) {
                // 手札表示
                VStack(spacing: 8) {
                    Text("手札")
                        .helpCaptionStyle(color: Appearance.Color.commonWhite.opacity(0.7))
                    
                    HStack(spacing: -10) {
                        RuleCardView(cardName: PlayCard.blackJoker.rawValue)
                        RuleCardView(cardName: PlayCard.club1.rawValue)
                        RuleCardView(cardName: PlayCard.heart7.rawValue)
                    }
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Appearance.Color.playerGold, lineWidth: 2)
                    )
                }
                
                // 矢印
                Image(systemName: "arrow.right")
                    .font(.helpHeadline)
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                
                // 可能な合計値
                VStack(alignment: .leading, spacing: 4) {
                    Text("可能な合計値")
                        .helpCaptionStyle(color: Appearance.Color.playerGold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("7 (ジョーカー=-1)")
                            .font(.helpCaption2)
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                        
                        Text("8 (ジョーカー=0)")
                            .font(.helpCaption2)
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                        
                        Text("9 (ジョーカー=1)")
                            .font(.helpCaption2)
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Card Section Title
    /// カードセクションタイトル
    private func cardSectionTitle(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .helpBoldHeadlineStyle(color: color)
            
            Text(title)
                .helpSectionTitleStyle()
            
            Spacer()
        }
    }
    
    // MARK: - Card Effect Section
    /// カード効果セクション
    private func cardEffectSection(title: String, icon: String, color: Color, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .helpBoldSubheadlineStyle(color: color)
                
                Text(title)
                    .helpBoldSubheadlineStyle(color: color)
                
                Spacer()
            }
            
            Text(description)
                .helpDescriptionStyle()
        }
    }
    
    // MARK: - Effect Example View
    /// 効果例表示
    private func effectExampleView(phase: String, effect: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phase)
                    .helpCaptionStyle(color: color)
                
                Text(effect)
                    .helpCaptionStyle()
            }
            
            Spacer()
        }
        .padding(.leading, 8)
    }
    

} 