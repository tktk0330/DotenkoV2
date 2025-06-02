import SwiftUI


// MARK: - Deck View
/// デッキ表示コンポーネント
struct DeckView: View {
    let deckCards: [Card]
    let namespace: Namespace.ID
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            ForEach(deckCards.prefix(5), id: \.id) { card in
                CardView(card: card, size: 80)
                    .matchedGeometryEffect(id: card.id, in: namespace)
            }
        }
        .onTapGesture {
            viewModel.handleDeckTap()
        }
    }
}
