import SwiftUI

struct PolicyView: View {
    var body: some View {
        VStack(spacing: 20) {
            // プライバシーポリシー
            VStack() {
                HStack() {
                    Text("プライバシーポリシー")
                        .font(.system(size: 15))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                }
                
                Link("プライバシーポリシー", destination: URL(string: Config.poricySite)!)
//                    .font(.custom(FontName.font01, size: 15))
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

            
            // 利用規約
            VStack() {
                HStack() {
                    Text("利用規約")
                        .font(.system(size: 15))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                    
                }
                
                Link("利用規約", destination: URL(string: Config.ruleSite)!)
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

        }
    }
}


