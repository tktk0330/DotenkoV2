import SwiftUI

// ヘルプ詳細ビュー
struct HelpDetailView: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            // アイコンとタイトル
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
            }
            .padding(.top, 24)
            
            // 説明文（仮のテキスト）
            Text("この項目の詳細な説明がここに表示されます。\n\n必要に応じて、より詳細な情報や設定オプションをここに追加することができます。")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)
            
            Spacer()
            
            // 閉じるボタン
            Button(action: {
                ModalManager.shared.dismiss()
            }) {
                Text("閉じる")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
    }
}
