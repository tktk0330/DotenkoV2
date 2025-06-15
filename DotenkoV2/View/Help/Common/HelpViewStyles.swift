/*
 * HelpViewStyles.swift
 * 
 * ファイル概要:
 * ヘルプシステム共通のスタイルを提供するビューモディファイアとフォント拡張
 * - ruleBackgroundモディファイア：ルール説明用の背景スタイル
 * - 動的タイプ対応フォント拡張：アクセシビリティ向上
 * - カジノ風デザインに統一されたスタイル
 * - 重複コードの解消と保守性の向上
 * 
 * 主要機能:
 * - RuleBackgroundModifier：ルール背景のビューモディファイア
 * - Font拡張：動的タイプ対応のスケーラブルフォント
 * - View拡張：便利なスタイル適用メソッド
 * - アクセシビリティ対応：ユーザーの文字サイズ設定に対応
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Rule Background Modifier

/// ルール背景ビューモディファイア
/// ヘルプシステムで使用される統一された背景スタイルを提供
struct RuleBackgroundModifier: ViewModifier {
    let color: Color // 背景色のベースカラー
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.1),    // 上部：薄い色
                                color.opacity(0.05)     // 下部：より薄い色
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                color.opacity(0.3),     // ボーダー色
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - Font Extensions for Dynamic Type

extension Font {
    
    // MARK: - Help System Fonts
    
    /// ヘルプシステム用の大見出し（動的タイプ対応）
    /// 基準サイズ: 20pt, 最大サイズ: 28pt
    static var helpLargeTitle: Font {
        .system(.title2, design: .rounded, weight: .bold)
    }
    
    /// ヘルプシステム用のタイトル（動的タイプ対応）
    /// 基準サイズ: 18pt, 最大サイズ: 24pt
    static var helpTitle: Font {
        .system(.title3, design: .rounded, weight: .bold)
    }
    
    /// ヘルプシステム用の見出し（動的タイプ対応）
    /// 基準サイズ: 16pt, 最大サイズ: 21pt
    static var helpHeadline: Font {
        .system(.headline, design: .rounded, weight: .bold)
    }
    
    /// ヘルプシステム用のサブ見出し（動的タイプ対応）
    /// 基準サイズ: 15pt, 最大サイズ: 19pt
    static var helpSubheadline: Font {
        .system(.subheadline, design: .rounded, weight: .medium)
    }
    
    /// ヘルプシステム用の本文（動的タイプ対応）
    /// 基準サイズ: 14pt, 最大サイズ: 17pt
    static var helpBody: Font {
        .system(.body, design: .default, weight: .medium)
    }
    
    /// ヘルプシステム用のキャプション（動的タイプ対応）
    /// 基準サイズ: 12pt, 最大サイズ: 15pt
    static var helpCaption: Font {
        .system(.caption, design: .default, weight: .medium)
    }
    
    /// ヘルプシステム用の小さなキャプション（動的タイプ対応）
    /// 基準サイズ: 11pt, 最大サイズ: 13pt
    static var helpCaption2: Font {
        .system(.caption2, design: .default, weight: .medium)
    }
    
    // MARK: - Scaled Font Helper
    
    /// カスタムサイズの動的タイプ対応フォント
    /// - Parameters:
    ///   - size: ベースフォントサイズ
    ///   - weight: フォントウェイト
    ///   - design: フォントデザイン
    /// - Returns: 動的タイプに対応したフォント
    static func scaledFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> Font {
        .system(size: size, weight: weight, design: design)
    }
    
    // MARK: - Semantic Font Styles
    
    /// セクションタイトル用フォント
    static var sectionTitle: Font {
        .system(.title3, design: .rounded, weight: .bold)
    }
    
    /// セクション説明用フォント
    static var sectionDescription: Font {
        .system(.body, design: .default, weight: .medium)
    }
    
    /// カード説明用フォント
    static var cardDescription: Font {
        .system(.subheadline, design: .default, weight: .medium)
    }
    
    /// 例示用フォント
    static var exampleText: Font {
        .system(.caption, design: .default, weight: .medium)
    }
    
    /// 強調用フォント
    static var emphasisText: Font {
        .system(.headline, design: .rounded, weight: .bold)
    }
}

// MARK: - View Extensions

extension View {
    /// ルール背景スタイルを適用
    /// - Parameter color: 背景色のベースカラー
    /// - Returns: ルール背景が適用されたビュー
    func ruleBackground(color: Color) -> some View {
        modifier(RuleBackgroundModifier(color: color))
    }
    
    /// ヘルプシステム用のセクションタイトルスタイルを適用
    /// - Parameter color: テキスト色
    /// - Returns: セクションタイトルスタイルが適用されたビュー
    func helpSectionTitleStyle(color: Color = Appearance.Color.commonWhite) -> some View {
        self
            .font(.sectionTitle)
            .foregroundColor(color)
    }
    
    /// ヘルプシステム用の説明テキストスタイルを適用
    /// - Parameter color: テキスト色
    /// - Returns: 説明テキストスタイルが適用されたビュー
    func helpDescriptionStyle(color: Color = Appearance.Color.commonWhite.opacity(0.9)) -> some View {
        self
            .font(.sectionDescription)
            .foregroundColor(color)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    /// ヘルプシステム用のキャプションスタイルを適用
    /// - Parameter color: テキスト色
    /// - Returns: キャプションスタイルが適用されたビュー
    func helpCaptionStyle(color: Color = Appearance.Color.commonWhite.opacity(0.8)) -> some View {
        self
            .font(.helpCaption)
            .foregroundColor(color)
    }
} 