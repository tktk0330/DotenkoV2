import SwiftUI


// MARK: - Deck View
/// デッキ表示コンポーネント
struct DeckView: View {
    let deckCards: [Card]
    let namespace: Namespace.ID
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // デッキカード表示（裏面で重ねて表示）
            ForEach(deckCards.prefix(5), id: \.id) { card in
                DeckCardBackView(size: 80)
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

// MARK: - Deck Card Back View
/// デッキカードの裏面表示View
struct DeckCardBackView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // カード裏面画像
            Image("back-1")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.9, height: size * 1.26)
                .clipped()
        }
    }
}
