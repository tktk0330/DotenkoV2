//
//  ContentView.swift
//  dtnk
//
//  Created by Takuma Shinoda on 2025/05/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigator = NavigationStateManager()
    @State private var selectedTab: Tab = .home
    let bannerHeight: CGFloat // バナー広告の高さを受け取るパラメータ
    
    var body: some View {
        ZStack {
            // 背景色
            Color(uiColor: Appearance.Color.forestGreen)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // メインコンテンツ
                if let currentView = navigator.currentView {
                    currentView
                } else {
                    TabView(selection: $selectedTab) {
                        HelpMainView()
                            .tag(Tab.help)
                        
                        HomeMainView()
                            .tag(Tab.home)
                        
                        ProfileMainView()
                            .tag(Tab.profile)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // グローバルナビゲーション
                GlobalNavigationView(selectedTab: $selectedTab)
                    .padding(.bottom, bannerHeight) // バナー広告の高さ分のパディング
            }
        }
        .environmentObject(navigator)
    }
}
