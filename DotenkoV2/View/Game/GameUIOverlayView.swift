import SwiftUI

// MARK: - Game UI Overlay View
/// ゲームUIオーバーレイ表示View（設定ボタンなど）
struct GameUIOverlayView: View {
    let onSettingsAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 設定ボタン（左上のヘッダー下に配置）
                VStack {
                    HStack {
                        SettingsButtonView(action: onSettingsAction)
                            .padding(.leading, 15)
                            .padding(.top, geometry.size.height * GameLayoutConfig.headerAreaHeightRatio + 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
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
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.commonBlack.opacity(0.6),
                                    Appearance.Color.commonBlack.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Appearance.Color.commonWhite.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
} 
