import SwiftUI


// MARK: - Deck View
/// デッキ表示コンポーネント
struct DeckView: View {
    let deckCards: [Card]
    let onDeckTap: () -> Void
    
    var body: some View {
        ZStack {
            // デッキの重なったカード表示
            ForEach(0..<min(5, deckCards.count), id: \.self) { index in
                CardView(card: Card(card: .back, location: .deck), size: 80)
                    .offset(x: CGFloat(index) * 2, y: CGFloat(index) * -2)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
            }
            
            // デッキ枚数表示（カードの上に重ねて表示）
            Text("\(deckCards.count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                )
                .offset(x: 30)
        }
        .frame(width: 80, height: 112)
        .onTapGesture {
            onDeckTap()
        }
    }
}
