import SwiftUI

struct Menu1View: View {
    
    @EnvironmentObject private var navigator: NavigationStateManager
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("MENU 1")
                .font(.title)
            
            Button(action: {
                allViewNavigator.push(Menu3View())
            }) {
                Text("Menu3へ")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Appearance.Color.commonGreen)
                    .foregroundColor(Appearance.Color.commonWhite)
                    .cornerRadius(10)
            }
            
            Button(action: {
                navigator.pop()
            }) {
                Text("戻る")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Appearance.Color.commonBlue)
                    .foregroundColor(Appearance.Color.commonWhite)
                    .cornerRadius(10)
            }
            .onDisappear {
                // 画面が消える時にデバッグ情報を出力
                navigator.printNavigationState()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
