/*
 * RootView.swift
 * 
 * ファイル概要:
 * アプリケーションのルートビュー
 * - 全画面レイアウトの管理
 * - ナビゲーション状態の管理
 * - カジノ風背景の提供
 * - バナー広告の配置
 * - ネットワーク監視とエラーハンドリング
 * 
 * 主要機能:
 * - NavigationStateManagerによる画面遷移管理
 * - カジノテーマの背景レンダリング
 * - AdMobバナー広告の統合
 * - フルスクリーン表示対応
 * - エラー処理とネットワーク状態監視
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - Root View
/// アプリケーションのルートビュー
/// 全体のレイアウト管理とナビゲーション制御を行う
struct RootView: View {
    
    /// バナー広告の高さ（定数から取得）
    private let bannerHeight: CGFloat = CGFloat(Constant.BANNER_HEIGHT)
    
    /// メインナビゲーション状態管理
    @StateObject private var navigator = NavigationStateManager()
    
    /// 全画面表示ナビゲーション状態管理
    @StateObject private var allViewNavigator = NavigationAllViewStateManager.shared
    
    /// メインビューボディ
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // カジノ風背景
                CasinoBackground()
                
                // メインコンテンツレイヤー
                ZStack {
                    mainContent        // 通常画面コンテンツ
                    fullScreenContent  // フルスクリーンコンテンツ
                    bannerView(width: geometry.size.width)  // バナー広告
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .environmentObject(navigator)       // ナビゲーション管理を環境オブジェクトとして注入
        .environmentObject(allViewNavigator) // 全画面ナビゲーション管理を環境オブジェクトとして注入
        .withNetworkMonitoring()            // ネットワーク監視機能を追加
        .withErrorHandling()                // エラーハンドリング機能を追加
    }
    
    // MARK: - Main Content
    /// メインコンテンツビュー
    /// 現在表示すべき画面を決定して表示
    private var mainContent: some View {
        Group {
            if let currentView = navigator.currentView {
                // ナビゲーターで指定された画面を表示
                currentView
            } else {
                // デフォルトでスプラッシュ画面を表示
                SplashView(navigator: navigator)
            }
        }
    }
    
    // MARK: - Full Screen Content
    /// フルスクリーンコンテンツビュー
    /// モーダルやオーバーレイ表示用
    private var fullScreenContent: some View {
        Group {
            if let allScreenView = allViewNavigator.currentView {
                // 全画面表示が指定されている場合
                allScreenView
            }
        }
    }
    
    // MARK: - Banner View
    /// バナー広告ビュー
    /// 画面下部にAdMobバナーを配置
    /// - Parameter width: 画面幅
    /// - Returns: バナー広告ビュー
    private func bannerView(width: CGFloat) -> some View {
        VStack {
            Spacer()
            BannerAdView(adUnitID: Config.bannerId)
                .frame(height: bannerHeight)
                .background(Color(uiColor: Appearance.Color.mossGreen))
        }
        .frame(width: width)
    }
}

// MARK: - Casino Background
/// カジノ風背景コンポーネント
/// グラデーションとオーバーレイによるカジノテーマの背景を提供
struct CasinoBackground: View {
    
    /// 背景ビューボディ
    var body: some View {
        GeometryReader { geometry in
            // メイングラデーション背景
            LinearGradient(
                gradient: Gradient(colors: Appearance.Color.mainBackgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}
