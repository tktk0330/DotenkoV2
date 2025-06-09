import SwiftUI

struct HelpMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @State private var isSEOn = true
    @State private var isSoundOn = true
    @State private var isVibrationOn = true
    
    var body: some View {
        ZStack {
            BaseLayout {
                VStack(spacing: 32) {
                    Spacer().frame(height: 30)
                    
                    // ヘルプセクション
                    ForEach(HelpSection.allCases, id: \.self) { section in
                        AccordionView(title: section.title) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(section.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                ForEach(section.items, id: \.self) { item in
                                    Button(action: {
                                        ModalManager.shared.show {
                                            HelpDetailView(detailType: item.type)
                                        }
                                    }) {
                                        HStack(spacing: 15) {
                                            Image(systemName: item.type.icon)
                                                .foregroundColor(.blue)
                                                .frame(width: 20)
                                            
                                            Text(item.type.title)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                    
                    // 設定ボタン
                    SettingsButtonsView(
                        isSEOn: $isSEOn,
                        isSoundOn: $isSoundOn,
                        isVibrationOn: $isVibrationOn
                    )
                }
            }
        }
    }
}
