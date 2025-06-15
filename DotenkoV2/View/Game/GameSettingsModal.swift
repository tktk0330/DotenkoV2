import SwiftUI

// MARK: - Game Settings Modal
/// ゲーム中の設定モーダル画面
struct GameSettingsModal: View {
    @Environment(\.dismiss) private var dismiss
    let onExitGame: () -> Void
    
    @State private var isSEOn: Bool = true
    @State private var isSoundOn: Bool = true
    @State private var isVibrationOn: Bool = true
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.95),
                    Color.black.opacity(0.85)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // メインコンテンツ
            ScrollView {
                VStack(spacing: 24) {
                    // タイトル
                    headerView
                        .padding(.top, 20)
                    
                    // 設定項目
                    settingsContentView
                        .padding(.horizontal, 20)
                    
                    // ボタンエリア
                    buttonAreaView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .presentationBackground(.clear)
        .presentationDetents([.height(600), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: Appearance.Icon.gearshapeFill)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
            
            Text("ゲーム設定")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(Appearance.Color.commonWhite)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Settings Content View
    private var settingsContentView: some View {
        VStack(spacing: 16) {
            GameSettingToggleItem(
                icon: "music.note",
                title: "効果音",
                isOn: $isSEOn
            )
            
            GameSettingToggleItem(
                icon: "speaker.wave.2",
                title: "サウンド",
                isOn: $isSoundOn
            )
            
            GameSettingToggleItem(
                icon: "iphone.radiowaves.left.and.right",
                title: "バイブレーション",
                isOn: $isVibrationOn
            )
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Button Area View
    private var buttonAreaView: some View {
        VStack(spacing: 12) {
            // ゲームを抜けるボタン
            CasinoUnifiedButton.danger(title: "ゲームを抜ける") {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onExitGame()
                }
            }
            
            // 閉じるボタン
            CasinoUnifiedButton.close {
                dismiss()
            }
        }
    }
}

// MARK: - Game Setting Toggle Item
/// ゲーム設定のトグル項目コンポーネント
struct GameSettingToggleItem: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // アイコン
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Appearance.Color.playerGold)
                .frame(width: 30, height: 30)
            
            // タイトル
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Appearance.Color.commonWhite)
            
            Spacer()
            
            // トグルスイッチ
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Appearance.Color.playerGold))
                .scaleEffect(1.1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Appearance.Color.commonBlack.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Appearance.Color.commonWhite.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    GameSettingsModal(onExitGame: {})
} 