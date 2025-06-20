import SwiftUI

struct Menu2View: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("本事象について")
                .font(.headline)
                .padding(.top, 24)
            
            Text("本事象は、システムメンテナンスのため一時的にサービスを停止しています。\n\nご不便をおかけして申し訳ございませんが、復旧までしばらくお待ちください。")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                ModalManager.shared.dismiss()
            }) {
                Text("閉じる")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Appearance.Color.commonOrange)
                    .foregroundColor(Appearance.Color.commonWhite)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 280)
    }
}
