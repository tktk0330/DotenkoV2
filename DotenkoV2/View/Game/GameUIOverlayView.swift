import SwiftUI

// MARK: - Game UI Overlay View
/// ゲームUIオーバーレイ表示View（戻るボタン、設定ボタンなど）
struct GameUIOverlayView: View {
    let onBackAction: () -> Void
    let onSettingsAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 戻るボタン
                VStack {
                    HStack {
                        BackButtonView(action: onBackAction)
                        Spacer()
                    }
                    Spacer()
                }
                
                // 設定ボタン
                SettingsButtonView(action: onSettingsAction)
                    .position(
                        x: geometry.size.width * 0.075,
                        y: geometry.size.height * 0.85
                    )
            }
        }
    }
}

// MARK: - Back Button View
/// 戻るボタン表示View
struct BackButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: Appearance.Icon.chevronLeft)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Appearance.Color.commonWhite)
                .padding()
                .background(Appearance.Color.commonBlack.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(.leading, GameLayoutConfig.backButtonLeadingPadding)
        .padding(.top, GameLayoutConfig.backButtonTopPadding)
    }
}

// MARK: - Settings Button View
/// 設定ボタン表示View
struct SettingsButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: Appearance.Icon.gearshapeFill)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Appearance.Color.commonWhite)
                .padding(12)
                .background(Appearance.Color.commonBlack.opacity(0.3))
                .clipShape(Circle())
        }
    }
} 
