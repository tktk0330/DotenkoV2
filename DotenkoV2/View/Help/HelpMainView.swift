// DotenkoV2/View/Help/HelpMainView.swift
// ヘルプメイン画面 - カジノ風デザイン統一

import SwiftUI

// MARK: - Help Main View
/// ヘルプメイン画面
struct HelpMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    
    // 設定状態管理
    @State private var isSEOn: Bool = true
    @State private var isSoundOn: Bool = true
    @State private var isVibrationOn: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 設定セクション
                        settingsSection
                            .padding(.top, geometry.safeAreaInsets.top + 20)
                            .padding(.horizontal, 16)
                        
                        // ヘルプセクション一覧
                        helpSectionsView
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + CGFloat(Constant.BANNER_HEIGHT) + 20)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    /// 設定セクション表示
    private var settingsSection: some View {
        VStack(spacing: 16) {
            // 設定セクションタイトル
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                
                Text("設定")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // 設定項目
            VStack(spacing: 12) {
                CasinoSettingToggleItem(
                    icon: "music.note",
                    title: "効果音 (SE)",
                    isOn: $isSEOn
                )
                
                CasinoSettingToggleItem(
                    icon: "speaker.wave.2",
                    title: "サウンド",
                    isOn: $isSoundOn
                )
                
                CasinoSettingToggleItem(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "バイブレーション",
                    isOn: $isVibrationOn
                )
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 20)
        .background(settingSectionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Appearance.Color.commonBlack.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // 設定セクション背景
    private var settingSectionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.8),
                        Appearance.Color.commonBlack.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold.opacity(0.6),
                                Appearance.Color.playerGold.opacity(0.3),
                                Appearance.Color.playerGold.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
    
    // MARK: - Help Sections View
    /// ヘルプセクション一覧表示
    private var helpSectionsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(HelpSection.allCases, id: \.self) { section in
                CasinoAccordionView(
                    title: section.title,
                    description: section.description
                ) {
                    helpItemsView(for: section)
                }
            }
        }
    }
    
    // MARK: - Help Items View
    /// セクション内のヘルプアイテム表示
    private func helpItemsView(for section: HelpSection) -> some View {
        VStack(spacing: 12) {
            ForEach(section.items, id: \.self) { item in
                CasinoHelpItemButton(
                    icon: item.type.icon,
                    title: item.type.title
                ) {
                    ModalManager.shared.show {
                        HelpDetailView(detailType: item.type)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Casino Setting Toggle Item
/// カジノ風設定トグルアイテム
struct CasinoSettingToggleItem: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    @State private var glowScale: CGFloat = 1.0
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 16) {
                // アイコン
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isOn ? Appearance.Color.playerGold : Appearance.Color.commonWhite.opacity(0.6))
                    .frame(width: 28, height: 28)
                
                // タイトル
                Text(title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .toggleStyle(CasinoToggleStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(toggleBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(glowScale)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glowScale)
        .onAppear {
            glowScale = 1.01
        }
        // アクセシビリティ設定
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "オン" : "オフ")
        .accessibilityHint("ダブルタップで\(isOn ? "オフ" : "オン")にします")
    }
    
    // トグル背景
    private var toggleBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.4),
                        Appearance.Color.commonBlack.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isOn ? 
                        Appearance.Color.playerGold.opacity(0.4) :
                        Appearance.Color.commonWhite.opacity(0.2),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Casino Toggle Style
/// カジノ風トグルスタイル
struct CasinoToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            // カスタムトグルスイッチ
            ZStack {
                // 背景トラック
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? 
                          LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold.opacity(0.8),
                                Appearance.Color.playerGold
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                          ) :
                          LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.commonWhite.opacity(0.2),
                                Appearance.Color.commonWhite.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
                    .frame(width: 50, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                configuration.isOn ? Appearance.Color.playerGold.opacity(0.6) : Appearance.Color.commonWhite.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                // スイッチノブ
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.commonWhite,
                                Appearance.Color.commonWhite.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 22, height: 22)
                    .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 2, x: 0, y: 1)
                    .offset(x: configuration.isOn ? 11 : -11)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

// MARK: - Casino Accordion View
/// カジノ風アコーディオンビュー
struct CasinoAccordionView<Content: View>: View {
    let title: String
    let description: String
    let content: Content
    @State private var isExpanded: Bool = false
    @State private var glowScale: CGFloat = 1.0
    
    init(title: String, description: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダーボタン
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                accordionHeader
            }
            .buttonStyle(PlainButtonStyle())
            
            // コンテンツ
            if isExpanded {
                accordionContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
            }
        }
        .background(accordionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Appearance.Color.commonBlack.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
        .scaleEffect(glowScale)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowScale)
        .onAppear {
            glowScale = 1.01
        }
    }
    
    // アコーディオンヘッダー
    private var accordionHeader: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Appearance.Color.commonWhite)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // アコーディオンコンテンツ
    private var accordionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 説明文
            Text(description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
            
            // コンテンツ
            content
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(
            Rectangle()
                .fill(Appearance.Color.commonBlack.opacity(0.2))
        )
    }
    
    // アコーディオン背景
    private var accordionBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.8),
                        Appearance.Color.commonBlack.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold.opacity(0.6),
                                Appearance.Color.playerGold.opacity(0.3),
                                Appearance.Color.playerGold.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
}

// MARK: - Casino Help Item Button
/// カジノ風ヘルプアイテムボタン
struct CasinoHelpItemButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                    .frame(width: 24, height: 24)
                
                // タイトル
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Appearance.Color.commonWhite)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // 矢印アイコン
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : glowScale)
            .animation(
                isPressed ? 
                    .easeInOut(duration: 0.15) : 
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true), 
                value: isPressed ? 1 : glowScale
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            glowScale = 1.01
        }
    }
    
    // ボタン背景
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.4),
                        Appearance.Color.commonBlack.opacity(0.6)
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
}
