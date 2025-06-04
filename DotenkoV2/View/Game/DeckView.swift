import SwiftUI


// MARK: - Deck View
/// デッキ表示コンポーネント
struct DeckView: View {
    let deckCards: [Card]
    let namespace: Namespace.ID
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // デッキカード表示（重ねて表示）
            ForEach(deckCards.prefix(5), id: \.id) { card in
                CardView(card: card, size: 80)
                    .matchedGeometryEffect(id: card.id, in: namespace)
            }
            
            // 山札残り枚数表示
            if !deckCards.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(deckCards.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Appearance.Color.commonBlack.opacity(0.7))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Appearance.Color.playerGold, lineWidth: 1)
                            )
                    }
                }
                .frame(width: 80, height: 80 * 1.26) // カードサイズに合わせる
            }
        }
        .onTapGesture {
            viewModel.handleDeckTap()
        }
    }
}
