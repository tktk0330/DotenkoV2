import SwiftUI

// MARK: - Card View
struct CardView: View {
    let card: Card
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // カード画像
            if let cardImage = card.card.image() {
                Image(uiImage: cardImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.9, height: size * 1.26)
                    .clipped()
            } else {
                // フォールバック表示
                Text(card.card.rawValue)
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
