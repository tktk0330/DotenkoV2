/*
 * GameFlowView.swift
 * 
 * ファイル概要:
 * ドテンコゲームの流れを説明するヘルプビュー
 * - ゲーム開始から終了までの流れを段階的に説明
 * - 中学生にもわかりやすい視覚的な表現
 * - カード画像とアイコンを使った直感的な説明
 * - ステップバイステップの進行説明
 * 
 * 主要機能:
 * - ゲーム開始フェーズの説明
 * - ターン制の説明
 * - 特殊イベントの説明
 * - ラウンド終了条件の説明
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Game Flow View
/// ゲームの流れ説明ビュー
struct GameFlowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイトル
            flowTitleView
            
            // ゲームフロー説明
            VStack(spacing: 16) {
                flowStepView(
                    step: "1",
                    title: "カード配布",
                    description: "各プレイヤーに手札を2枚ずつ配ります",
                    icon: "rectangle.portrait.on.rectangle.portrait.fill",
                    color: Appearance.Color.playerBlue
                )
                
                flowStepView(
                    step: "2", 
                    title: "場のカード決定",
                    description: "山札の一番上をめくって場の最初のカードにします",
                    icon: "rectangle.portrait.fill",
                    color: Appearance.Color.playerGreen
                )
                
                flowStepView(
                    step: "3",
                    title: "ゲーム開始",
                    description: "出せるカードがある人から早い者勝ちでスタート！\n最初にカードを出した人から時計回りに進行します",
                    icon: "clock.arrow.circlepath",
                    color: Appearance.Color.playerOrange
                )
                
                flowStepView(
                    step: "4",
                    title: "ターン制プレイ",
                    description: "自分のターンでは以下の行動ができます：\n• カードを出す\n• 山札からカードを引く\n• パスをする",
                    icon: "hand.point.up.left.fill",
                    color: Appearance.Color.playerPurple
                )
                
                flowStepView(
                    step: "5",
                    title: "どてんこ宣言",
                    description: "場のカードと手札の合計が一致したら\n「どてんこ」宣言で勝利！",
                    icon: "star.fill",
                    color: Appearance.Color.playerGold
                )
                
                flowStepView(
                    step: "6",
                    title: "チャレンジゾーン",
                    description: "どてんこ後、他のプレイヤーにもチャンスがあれば\nチャレンジゾーンで逆転のチャンス！",
                    icon: "flame.fill",
                    color: Appearance.Color.playerRed
                )
                
                flowStepView(
                    step: "7",
                    title: "スコア計算",
                    description: "山札の底のカードを確認してスコアを計算\n特殊カードが出ると大きな変化が！",
                    icon: "chart.bar.fill",
                    color: Appearance.Color.playerCyan
                )
            }
            
            // 重要なポイント
            importantPointsView
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Flow Title View
    /// フロータイトル表示
    private var flowTitleView: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
            
            Text("ゲームの流れ")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Appearance.Color.commonWhite)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Flow Step View
    /// フローステップ表示
    private func flowStepView(
        step: String,
        title: String,
        description: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // ステップ番号
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(step)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
            }
            
            // コンテンツ
            VStack(alignment: .leading, spacing: 8) {
                // タイトル行
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Appearance.Color.commonWhite)
                    
                    Spacer()
                }
                
                // 説明文
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(stepBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Step Background
    /// ステップ背景
    private var stepBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.3),
                        Appearance.Color.commonBlack.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Appearance.Color.commonWhite.opacity(0.2),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Important Points View
    /// 重要なポイント表示
    private var importantPointsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerOrange)
                
                Text("重要なポイント")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                pointItem("山札がなくなったら、場の一番上を残してシャッフル")
                pointItem("手札が7枚でパスするとバースト（一人負け）")
                pointItem("どてんこは誰のターンでも宣言可能")
                pointItem("しょてんこは最初のカードに対する特別などてんこ")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerOrange.opacity(0.1),
                            Appearance.Color.playerOrange.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Appearance.Color.playerOrange.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Point Item
    /// ポイントアイテム表示
    private func pointItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Appearance.Color.playerOrange)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
} 