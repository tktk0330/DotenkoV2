import SwiftUI

// MARK: - Help Detail View
/// ヘルプ詳細ビュー
struct HelpDetailView: View {
    let detailType: RuleDetail
    
    var body: some View {
        ZStack {
            // 背景タップエリア（モーダル外側）
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    ModalManager.shared.dismiss()
                }
            
            // モーダルコンテンツ
            modalContent
        }
    }
    
    // MARK: - Modal Content
    /// モーダルコンテンツ
    private var modalContent: some View {
        ZStack {
            // カジノ風背景
            CasinoBackground()
            
            // 全体をScrollViewに変更
            ScrollView {
                VStack(spacing: 0) {
                    // ヘッダー
                    headerView
                        .padding(.top, 24)
                        .padding(.horizontal, 24)
                    
                    // コンテンツエリア
                    contentView
                        .padding(.horizontal, 4)
                        .padding(.top, 20)
                    
                    // スクロール最後の閉じるボタン
                    scrollBottomCloseButton
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                }
            }
            .background(Color.clear)
        }
        .frame(
            width: UIScreen.main.bounds.width * 0.9,
            height: UIScreen.main.bounds.height * 0.6
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Header View
    /// ヘッダー表示
    private var headerView: some View {
        VStack(spacing: 16) {
            // アイコン
            Image(systemName: detailType.icon)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold,
                            Appearance.Color.playerGold.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 4, x: 0, y: 2)
            
            // タイトル
            Text(detailType.title)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .fontDesign(.rounded)
                .foregroundColor(Appearance.Color.commonWhite)
                .multilineTextAlignment(.center)
                .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 4, x: 0, y: 2)
            
            // 区切り線
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold.opacity(0.6),
                            Appearance.Color.playerGold,
                            Appearance.Color.playerGold.opacity(0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 200)
        }
    }
    
    // MARK: - Content View
    /// コンテンツ表示
    private var contentView: some View {
        VStack(spacing: 20) {
            contentContainer {
                switch detailType {
                case .aboutDotenko:
                    AboutDotenkoView()
                case .flow:
                    GameFlowView()
                case .operation:
                    GameOperationView()
                case .event:
                    GameEventView()
                case .card:
                    CardExplanationView()
                case .roundCount:
                    GameDetailRuleCommonView(type: .roundCount)
                case .jokerCount:
                    GameDetailRuleCommonView(type: .jokerCount)
                case .gameRate:
                    GameDetailRuleCommonView(type: .gameRate)
                case .upRate:
                    GameDetailRuleCommonView(type: .upRate)
                case .maxScore:
                    GameDetailRuleCommonView(type: .maxScore)
                case .deckCycle:
                    GameDetailRuleCommonView(type: .deckCycle)
                case .contact:
                    ContactView()
                case .review:
                    ReviewView()
                case .privacyPoricy:
                    PolicyView()
                case .poricy:
                    PolicyView()
                }
            }
        }
    }
    
    // MARK: - Content Container
    /// コンテンツコンテナ
    private func contentContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonBlack.opacity(0.7),
                            Appearance.Color.commonBlack.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.commonWhite.opacity(0.3),
                                    Appearance.Color.commonWhite.opacity(0.1),
                                    Appearance.Color.commonWhite.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Appearance.Color.commonBlack.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Scroll Bottom Close Button
    /// スクロール最後の閉じるボタン表示
    private var scrollBottomCloseButton: some View {
        // 閉じるボタン
        CasinoUnifiedButton.close {
            ModalManager.shared.dismiss()
        }
    }
}
