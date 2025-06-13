import SwiftUI

// MARK: - Card View
struct CardView: View {
    let card: Card
    let size: CGFloat
    let showFront: Bool // カードの表面を表示するかどうか
    
    // デフォルトで表面を表示するイニシャライザ
    init(card: Card, size: CGFloat, showFront: Bool = true) {
        self.card = card
        self.size = size
        self.showFront = showFront
    }
    
    var body: some View {
        ZStack {
            if showFront {
                // カード表面画像
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
            } else {
                // カード裏面画像
                Image("back-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.9, height: size * 1.26)
                    .clipped()
            }
        }
    }
}
