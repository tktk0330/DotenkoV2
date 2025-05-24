import SwiftUI

struct ReviewView: View {
    var body: some View {
        HStack() {
            
            Spacer()
            
            Button(action: {
                if let url = URL(string: Config.applicationSite) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("レビューに協力")
//                    .font(.custom(FontName.font01, size: 20))
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .bold()
                    .padding()
//                    .frame(width: Constants.scrWidth * 0.6, height: 40)
//                    .background(
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(Color.casinoGreen)
//                            .shadow(color: Color.casinoShadow, radius: 1, x: 5, y: 10)
//                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white, lineWidth: 5)
                    )
            }
            
            Spacer()
            
        }
    }
}
