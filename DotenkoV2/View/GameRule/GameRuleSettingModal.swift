import SwiftUI
import Foundation

struct GameRuleSettingModal: View {
    let title: String
    let setting: GameSetting
    let currentValue: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedValue: String
    
    init(title: String, setting: GameSetting, currentValue: String, onSave: @escaping (String) -> Void) {
        self.title = title
        self.setting = setting
        self.currentValue = currentValue
        self.onSave = onSave
        _selectedValue = State(initialValue: currentValue)
    }
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            // メインコンテンツ
            VStack(spacing: 32) {
                Spacer()
                
                // タイトル
                Text(title)
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.white)
                
                // 値の選択
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(setting.values, id: \.self) { value in
                                Button(action: {
                                    selectedValue = value
                                    withAnimation {
                                        proxy.scrollTo(value, anchor: .center)
                                    }
                                }) {
                                    Text(value)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedValue == value ? 
                                                    Color(uiColor: Appearance.Color.mossGreen) : 
                                                    Color.gray.opacity(0.3))
                                        )
                                }
                                .id(value)
                            }
                        }
                        .padding(.horizontal, UIScreen.main.bounds.width / 2 - 30)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(selectedValue, anchor: .center)
                        }
                    }
                }
                
                // 説明テキスト
                Text(getDescription(for: setting))
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // 決定ボタン
                Button(action: {
                    onSave(selectedValue)
                    dismiss()
                }) {
                    Text("決定")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(uiColor: Appearance.Color.mossGreen))
                        )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.vertical, 32)
        }
        .presentationBackground(.clear)
    }
    
    private func getDescription(for setting: GameSetting) -> String {
        switch setting {
        case .roundCount: return "ゲームを何ラウンドするか決めます"
        case .jokerCount: return "ジョーカーの枚数を決めます"
        case .gameRate: return "1ゲームのレートを決めます"
        case .maxScore: return "重ねレートの上限を決めます"
        case .upRate: return "スコアの上限を決めます"
        case .deckCycle: return "デッキの種類を決めます"
        }
    }
} 
