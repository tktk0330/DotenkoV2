import SwiftUI

// MARK: - Game Header View
/// ゲームヘッダー情報表示View
struct GameHeaderView: View {
    let currentRound: Int
    let totalRounds: Int
    let upRate: Int
    let currentRate: Int
    
    var body: some View {
        HStack(spacing: GameLayoutConfig.headerItemSpacing) {
            // 左側：ラウンド情報
            CasinoInfoCardView(
                icon: "chart.bar.fill",
                label: "ROUND",
                value: "\(currentRound)/\(totalRounds)",
                valueColor: Appearance.Color.commonWhite,
                accentColor: Appearance.Color.playerGold, // ゴールド
                fixedWidth: 100
            )
            
            Spacer()
            
            // 中央：UP（メイン表示）
            UpRateDisplayView(upRate: upRate)
            
            Spacer()
            
            // 右側：レート
            CasinoInfoCardView(
                icon: "multiply.circle.fill",
                label: "RATE",
                value: "×\(currentRate)",
                valueColor: Appearance.Color.emeraldGreen, // エメラルドグリーン
                accentColor: Appearance.Color.emeraldGreen, // エメラルドグリーン
                fixedWidth: 100
            )
        }
        .padding(.horizontal, GameLayoutConfig.headerHorizontalPadding)
        .padding(.vertical, GameLayoutConfig.headerVerticalPadding)
        .background(headerBackground)
    }
    
    private var headerBackground: some View {
        // カジノ風グラデーション背景
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Appearance.Color.headerDarkGreen, location: 0.0),
                .init(color: Appearance.Color.headerMediumGreen, location: 0.5),
                .init(color: Appearance.Color.headerDarkGreen, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // 上部のゴールドライン
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold,
                                Appearance.Color.playerDarkGold,
                                Appearance.Color.playerGold
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                Spacer()
                // 下部のゴールドライン
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold,
                                Appearance.Color.playerDarkGold,
                                Appearance.Color.playerGold
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
            }
        )
        .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Casino Info Card View
/// カジノ風情報カード表示View
struct CasinoInfoCardView: View {
    let icon: String
    let label: String
    let value: String
    let valueColor: Color
    let accentColor: Color
    let fixedWidth: CGFloat?
    
    init(
        icon: String,
        label: String,
        value: String,
        valueColor: Color,
        accentColor: Color,
        fixedWidth: CGFloat? = nil
    ) {
        self.icon = icon
        self.label = label
        self.value = value
        self.valueColor = valueColor
        self.accentColor = accentColor
        self.fixedWidth = fixedWidth
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentColor)
                
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.9))
                    .tracking(1.0)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(valueColor)
                .shadow(color: accentColor.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: fixedWidth)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Appearance.Color.commonBlack.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Up Rate Display View
/// UPレート表示View
struct UpRateDisplayView: View {
    let upRate: Int
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                
                Text("UP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
                    .tracking(1.5)
            }
            
            Text("×\(upRate)")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(Appearance.Color.commonWhite)
                .shadow(color: Appearance.Color.playerGold.opacity(0.3), radius: 3, x: 0, y: 0)
                .overlay(
                    Text("×\(upRate)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Appearance.Color.playerGold.opacity(0.3))
                        .blur(radius: 1)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.upDisplayDarkBrown,
                            Appearance.Color.upDisplayLightBrown
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Appearance.Color.playerGold,
                                    Appearance.Color.playerDarkGold
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Appearance.Color.playerGold.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
} 