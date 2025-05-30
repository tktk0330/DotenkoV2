import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 16) {
            // エラーアイコン
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Appearance.Color.commonRed)
                .padding(.top, 24)
            
            // エラーメッセージ
            Text(errorMessage)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
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
                    .background(Appearance.Color.commonBlue)
                    .foregroundColor(Appearance.Color.commonWhite)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .allowsHitTesting(true) // モーダル内のタップを有効化
    }
}
