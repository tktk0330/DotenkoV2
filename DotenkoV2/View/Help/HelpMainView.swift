import SwiftUI

struct HelpMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    
    var body: some View {
        ZStack {
            BaseLayout {
                VStack(spacing: 20) {
                    Spacer().frame(height: 24)
                    
                    // ヘルプセクション
                    ForEach(HelpSection.allCases, id: \.self) { section in
                        AccordionView(title: section.title) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(section.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                ForEach(section.items, id: \.self) { item in
                                    Button(action: {
                                        ModalManager.shared.show {
                                            HelpDetailView(title: item.title, icon: item.icon)
                                        }
                                    }) {
                                        HStack(spacing: 15) {
                                            Image(systemName: item.icon)
                                                .foregroundColor(.blue)
                                                .frame(width: 20)
                                            
                                            Text(item.title)
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
                    
                    // MENU1への遷移ボタン
                    Button(action: {
                        navigator.push(Menu1View())
                    }) {
                        Text("MENU 1を開く")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // MENU2のモーダル表示ボタン
                    Button(action: {
                        ModalManager.shared.show {
                            Menu2View()
                        }
                    }) {
                        Text("MENU 2を開く")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
