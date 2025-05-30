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
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            
            Spacer()
            
            Text("MENU 3")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("全画面表示のメニュー")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Button(action: {
                allViewNavigator.pop()
            }) {
                Text("閉じる")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(Appearance.Color.commonBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
} 