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
            // 暗い背景
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            // メインコンテンツ
            VStack(spacing: 32) {
                Spacer()
                
                // タイトル
                Text(title)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow,
                                Color.orange
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 2)
                
                // 値の選択
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(setting.values, id: \.self) { value in
                                Button(action: {
                                    selectedValue = value
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(value, anchor: .center)
                                    }
                                }) {
                                    Text(value)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 60)
                                        .background(casinoValueBackground(isSelected: selectedValue == value))
                                }
                                .id(value)
                            }
                        }
                        .padding(.horizontal, UIScreen.main.bounds.width / 2 - 30)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(selectedValue, anchor: .center)
                        }
                    }
                }
                
                // 説明テキスト
                Text(getDescription(for: setting))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // 決定ボタン
                CasinoUnifiedButton.confirm {
                    onSave(selectedValue)
                    dismiss()
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.vertical, 32)
        }
        .presentationBackground(.clear)
    }
    
    /// シンプルな値選択背景
    private func casinoValueBackground(isSelected: Bool) -> some View {
        return RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.8) : Color.gray.opacity(0.5), lineWidth: 1)
            )
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
