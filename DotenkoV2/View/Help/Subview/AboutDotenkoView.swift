/*
 * AboutDotenkoView.swift
 * 
 * ファイル概要:
 * ドテンコゲームの基本概要を説明するヘルプビュー
 * - ゲームの基本的な概要説明
 * - プレイ人数、使用カード、基本ルールの説明
 * - 中学生にもわかりやすい簡潔な説明
 * 
 * 主要機能:
 * - ゲームの基本情報表示
 * - プレイ人数と使用カードの説明
 * - 基本的なゲームの流れ説明
 * - カスタマイズ可能な要素の紹介
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

struct AboutDotenkoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ゲーム概要セクション
                VStack(alignment: .leading, spacing: 12) {
                    Text("ゲーム概要")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Appearance.Color.primaryText)
                    
                    Text("ドテンコは、場のカードと手札の数字の合計を一致させて勝利を目指すカードゲームです。運と戦略が絡み合う奥深いゲームで、家族や友人と楽しめます。")
                        .font(.body)
                        .foregroundColor(Appearance.Color.secondaryText)
                        .lineSpacing(4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Appearance.Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // 基本情報セクション
                VStack(alignment: .leading, spacing: 12) {
                    Text("基本情報")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Appearance.Color.primaryText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRowView(title: "プレイ人数", content: "2〜5人（推奨：4人）")
                        InfoRowView(title: "使用カード", content: "52枚 + ジョーカー0〜4枚")
                        InfoRowView(title: "手札", content: "各プレイヤー2枚ずつ")
                        InfoRowView(title: "勝利条件", content: "場のカードと手札の合計一致時に「どてんこ」宣言")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Appearance.Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // カスタマイズ機能セクション
                VStack(alignment: .leading, spacing: 12) {
                    Text("カスタマイズ機能")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Appearance.Color.primaryText)
                    
                    Text("ドテンコV2では、様々なルールをカスタマイズして楽しむことができます：")
                        .font(.body)
                        .foregroundColor(Appearance.Color.secondaryText)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        CustomizeRowView(title: "ラウンド数", description: "1ゲームのラウンド数を設定")
                        CustomizeRowView(title: "ジョーカー枚数", description: "0〜4枚まで選択可能")
                        CustomizeRowView(title: "ゲームレート", description: "基本スコアの倍率設定")
                        CustomizeRowView(title: "重ねレートアップ", description: "連続カード時の倍率設定")
                        CustomizeRowView(title: "最大スコア", description: "1ラウンドの上限スコア")
                        CustomizeRowView(title: "デッキサイクル", description: "山札の周回数制限")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Appearance.Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // 注意事項セクション
                VStack(alignment: .leading, spacing: 12) {
                    Text("重要なポイント")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Appearance.Color.primaryText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        PointRowView(text: "「どてんこ」は条件が揃えばいつでも宣言可能")
                        PointRowView(text: "ゲーム開始時の「しょてんこ」は特別ルール")
                        PointRowView(text: "手札が7枚になってパスすると負け（バースト）")
                        PointRowView(text: "特殊カードでレート倍増や勝敗逆転あり")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Appearance.Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .padding()
        }
        .background(Appearance.Color.background)
    }
}

// MARK: - Helper Views

struct InfoRowView: View {
    let title: String
    let content: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Appearance.Color.primaryText)
                .frame(width: 80, alignment: .leading)
            
            Text(":")
                .foregroundColor(Appearance.Color.secondaryText)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(Appearance.Color.secondaryText)
            
            Spacer()
        }
    }
}

struct CustomizeRowView: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(Appearance.Color.accent)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Appearance.Color.primaryText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(Appearance.Color.secondaryText)
            }
            
            Spacer()
        }
    }
}

struct PointRowView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Appearance.Color.accent)
                .font(.caption)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Appearance.Color.secondaryText)
                .lineSpacing(2)
            
            Spacer()
        }
    }
}
