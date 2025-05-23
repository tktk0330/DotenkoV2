import SwiftUI

// ゲームモードボタン
struct GameModeButton: View {
    let title: String
    let backgroundImage: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // ボタンの背景
                if let image = backgroundImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: Appearance.Color.mossGreen))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: Appearance.Color.goldenYellow), lineWidth: 2)
                        )
                }
                
                // ボタンのテキスト
                Text(title)
                    .font(Font(Appearance.Font.casinoDisplay))
                    .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            }
        }
        .frame(height: 70)
    }
}

// プレビュー用のダミービュー
struct SinglePlayView: View {
    var body: some View {
        Text("個人戦")
    }
}

struct FriendPlayView: View {
    var body: some View {
        Text("友人戦")
    }
}
