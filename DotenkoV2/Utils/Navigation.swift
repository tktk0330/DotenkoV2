/*
 * Navigation.swift
 * 
 * ファイル概要:
 * アプリケーション全体のナビゲーション状態管理システム
 * - 画面遷移の制御
 * - ビュースタックの管理
 * - アニメーション付き画面切り替え
 * - 通常画面とフルスクリーン画面の分離管理
 * 
 * 主要機能:
 * - スタックベースのナビゲーション
 * - push/pop操作による画面遷移
 * - ObservableObjectによる状態通知
 * - MainActorによるUI安全性の確保
 * - 全画面表示専用のナビゲーション管理
 * 
 * 構成要素:
 * - ViewWrapper: ViewをHashableにラップ
 * - NavigationStateManager: 通常画面のナビゲーション管理
 * - NavigationAllViewStateManager: 全画面表示のナビゲーション管理
 * 
 * 作成日: 2024年12月
 */

import SwiftUI

// MARK: - View Wrapper
/// ViewをHashableにラップするための構造体
/// AnyViewを配列で管理するために必要な一意性を提供
struct ViewWrapper: Hashable {
    /// 一意識別子
    let id = UUID()
    
    /// ラップされたビュー
    let view: AnyView
    
    /// Equatable プロトコル準拠
    /// - Parameters:
    ///   - lhs: 左辺のViewWrapper
    ///   - rhs: 右辺のViewWrapper
    /// - Returns: IDが一致する場合true
    static func == (lhs: ViewWrapper, rhs: ViewWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hashable プロトコル準拠
    /// - Parameter hasher: ハッシュ関数
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Navigation State Manager
/// 通常画面のナビゲーション状態管理クラス
/// スタックベースの画面遷移を提供
@MainActor
class NavigationStateManager: ObservableObject {
    
    /// 現在表示中のビュー
    @Published var currentView: AnyView?
    
    /// ビュー履歴スタック
    private var viewStack: [AnyView] = []
    
    /// 新しいビューをスタックにプッシュ
    /// - Parameter view: 表示するビュー
    func push<V: View>(_ view: V) {
        // 現在のビューがあればスタックに保存
        if let current = currentView {
            viewStack.append(current)
        }
        // 新しいビューを表示
        withAnimation(.easeInOut(duration: 0.0)) {
            currentView = AnyView(view)
        }
    }
    
    /// 前のビューに戻る（ポップ操作）
    func pop() {
        withAnimation(.easeInOut(duration: 0.0)) {
            if !viewStack.isEmpty {
                // スタックから前のビューを復元
                currentView = viewStack.removeLast()
            } else {
                // スタックが空の場合はルートに戻る
                currentView = nil
            }
        }
    }
    
    /// ルートビューまで戻る
    func popToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = nil
            viewStack.removeAll()
        }
    }
    
    /// デバッグ用：現在のナビゲーション状態を出力
    func printNavigationState() {
        print("Current view exists: \(currentView != nil)")
        print("Stack count: \(viewStack.count)")
    }
}

// MARK: - Navigation All View State Manager
/// 全画面表示専用のナビゲーション状態管理クラス
/// モーダルやオーバーレイなどの全画面表示を管理
@MainActor
class NavigationAllViewStateManager: ObservableObject {
    
    /// 現在表示中の全画面ビュー
    @Published var currentView: AnyView?
    
    /// 全画面ビュー履歴スタック
    private var viewStack: [AnyView] = []
    
    /// シングルトンインスタンス
    static let shared = NavigationAllViewStateManager()
    
    /// プライベートイニシャライザ（シングルトンパターン）
    private init() {}
    
    /// 新しい全画面ビューをプッシュ
    /// - Parameter view: 表示するビュー
    func push<V: View>(_ view: V) {
        // 現在のビューがあればスタックに保存
        if let current = currentView {
            viewStack.append(current)
        }
        // カジノ風背景付きで新しいビューを表示
        withAnimation(.easeInOut(duration: 0.0)) {
            currentView = AnyView(
                ZStack {
                    // カジノ風背景
                    LinearGradient(
                        gradient: Gradient(colors: Appearance.Color.mainBackgroundGradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    view
                }
            )
        }
    }
    
    /// 前の全画面ビューに戻る
    func pop() {
        withAnimation(.easeInOut(duration: 0.0)) {
            if !viewStack.isEmpty {
                // スタックから前のビューを復元
                currentView = viewStack.removeLast()
            } else {
                // スタックが空の場合は全画面表示を終了
                currentView = nil
            }
        }
    }
    
    /// 全ての全画面ビューを閉じてルートに戻る
    func popToRoot() {
        withAnimation(.easeInOut(duration: 0)) {
            currentView = nil
            viewStack.removeAll()
        }
    }
    
    /// デバッグ用：現在の全画面ナビゲーション状態を出力
    func printNavigationState() {
        print("Current all view exists: \(currentView != nil)")
        print("All view stack count: \(viewStack.count)")
    }
}
