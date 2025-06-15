/*
 * GameEventView.swift
 * 
 * ファイル概要:
 * ドテンコゲームの特殊イベントを説明するヘルプビュー
 * - どてんこ、しょてんこ、リベンジなどの特殊イベント説明
 * - 中学生にもわかりやすい視覚的な表現
 * - 勝敗条件の明確な説明
 * - イベント発生条件の詳細説明
 * 
 * 主要機能:
 * - 各イベントの発生条件説明
 * - 勝敗の決まり方説明
 * - スコア計算の仕組み説明
 * - 特殊ルールの説明
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Game Event View
/// ゲームイベント説明ビュー
struct GameEventView: View {
    
    // イベント説明データ
    private let events: [GameEventData] = [
        GameEventData(
            title: "どてんこ / DOTENKO",
            icon: "star.fill",
            color: Appearance.Color.playerGold,
            condition: "場のカードの数字と手札の合計が一致",
            description: "誰かが出した場のカードの数字と、自分の手札全ての合計数字が一致した時「どてんこ」と宣言できます。",
            winner: "どてんこした人",
            loser: "どてんこされたカードを出した人",
            example: "場：♦7、手札：♠3+♥4 → 3+4=7で「どてんこ」！"
        ),
        GameEventData(
            title: "しょてんこ / SHOTENKO",
            icon: "bolt.fill",
            color: Appearance.Color.playerCyan,
            condition: "最初にめくられたカードと手札の合計が一致",
            description: "1番はじめに山札から捲られたカードの数字と、自分の手札全ての合計数字が一致した時「しょてんこ」と宣言できます。",
            winner: "しょてんこした人",
            loser: "その他全員",
            example: "最初のカード：♣10、手札：♠6+♥4 → 6+4=10で「しょてんこ」！"
        ),
        GameEventData(
            title: "どてんこ返し / REVENGE",
            icon: "arrow.clockwise.circle.fill",
            color: Appearance.Color.playerRed,
            condition: "他の人のどてんこに対して同じ条件を満たす",
            description: "誰かが「どてんこ」を宣言した際、別のプレイヤーも「どてんこ」できる状態であった場合、「どてんこ返し」と宣言し、勝者を上書きできます。",
            winner: "最後に「どてんこ返し」した人",
            loser: "1つ前に「どてんこ」した人",
            example: "Aさんがどてんこ → Bさんも条件を満たしていれば「リベンジ」可能！"
        ),
        GameEventData(
            title: "チャレンジゾーン / Challenge Zone",
            icon: "flame.fill",
            color: Appearance.Color.playerOrange,
            condition: "どてんこ確定後、手札合計が場より小さい",
            description: "どてんこが確定した時、チャレンジゾーンに移ります。手札の合計が場の数字より小さい場合参加可能。時計回りで山札から引いて新たに一致すれば「REVENGE」。",
            winner: "最後にリベンジした人",
            loser: "前の勝者",
            example: "場：10、手札合計：8 → 山札から2を引けばリベンジ成功！"
        ),
        GameEventData(
            title: "バースト / Burst",
            icon: "exclamationmark.triangle.fill",
            color: Appearance.Color.playerPurple,
            condition: "手札7枚の時にパス",
            description: "手札が7枚の時パスをするとバーストとなり自分の1人負けとなります。",
            winner: "その他全員",
            loser: "バーストした人",
            example: "手札7枚でパス → 一人負け確定"
        ),
        GameEventData(
            title: "ラウンドスコア決定",
            icon: "chart.bar.fill",
            color: Appearance.Color.playerGreen,
            condition: "ラウンド終了時",
            description: "ラウンドスコアは「初期レート × 上昇レート × 山札裏のカード数字」で算出されます。特殊カードでレート上昇イベントがあります。",
            winner: "勝者がスコア獲得",
            loser: "敗者がスコア失う",
            example: "100 × 4 × 10 = 4000点"
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイトル
            eventTitleView
            
            // イベント一覧
            VStack(spacing: 16) {
                ForEach(events) { event in
                    eventItemView(event: event)
                }
            }
            
            // 重要なポイント
            importantNotesView
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Event Title View
    /// イベントタイトル表示
    private var eventTitleView: some View {
        HStack {
            Image(systemName: "star.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
            
            Text("ゲームイベント")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Appearance.Color.commonWhite)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Event Item View
    /// イベントアイテム表示
    private func eventItemView(event: GameEventData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // イベントヘッダー
            HStack(spacing: 12) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [event.color, event.color.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: event.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Appearance.Color.commonWhite)
                }
                
                // タイトルと条件
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Appearance.Color.commonWhite)
                    
                    Text(event.condition)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(event.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(event.color.opacity(0.2))
                        )
                }
                
                Spacer()
            }
            
            // 説明文
            Text(event.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // 勝敗情報
            HStack(spacing: 20) {
                // 勝者
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerGold)
                        
                        Text("勝者")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerGold)
                    }
                    
                    Text(event.winner)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                }
                
                // 敗者
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerRed)
                        
                        Text("敗者")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerRed)
                    }
                    
                    Text(event.loser)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                }
                
                Spacer()
            }
            
            // 例
            if !event.example.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerCyan)
                        
                        Text("例")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Appearance.Color.playerCyan)
                    }
                    
                    Text(event.example)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Appearance.Color.playerCyan.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Appearance.Color.playerCyan.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(16)
        .background(eventBackground(color: event.color))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Event Background
    /// イベント背景
    private func eventBackground(color: Color) -> some View {
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
    
    // MARK: - Important Notes View
    /// 重要な注意事項表示
    private var importantNotesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Appearance.Color.playerBlue)
                
                Text("重要な注意事項")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                noteItem("どてんこ宣言は誰のターンでも可能です")
                noteItem("リベンジは複数人が同時に宣言できます")
                noteItem("チャレンジゾーンでは時計回りに順番が回ります")
                noteItem("バーストは即座にラウンド終了となります")
                noteItem("特殊カードが出ると大きくスコアが変わります")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerBlue.opacity(0.1),
                            Appearance.Color.playerBlue.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Appearance.Color.playerBlue.opacity(0.3),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Note Item
    /// 注意事項アイテム表示
    private func noteItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Appearance.Color.playerBlue)
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

// MARK: - Game Event Data
/// ゲームイベントデータ構造
struct GameEventData: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let condition: String
    let description: String
    let winner: String
    let loser: String
    let example: String
} 