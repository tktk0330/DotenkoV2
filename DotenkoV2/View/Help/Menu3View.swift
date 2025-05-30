import SwiftUI

struct Menu3View: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    allViewNavigator.pop()
                }) {
                    Image(systemName: Appearance.Icon.xmark)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Appearance.Color.commonWhite)
                        .padding()
                }
            }
            
            Spacer()
            
            Text("MENU 3")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Appearance.Color.commonWhite)
            
            Text("全画面表示のメニュー")
                .font(.title2)
                .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
            
            Spacer()
            
            Button(action: {
                allViewNavigator.pop()
            }) {
                Text("閉じる")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Appearance.Color.commonBlue)
                    .foregroundColor(Appearance.Color.commonWhite)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
} 