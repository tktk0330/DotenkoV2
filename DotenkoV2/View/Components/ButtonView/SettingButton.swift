import SwiftUI

struct SettingButton: View {
    let icon: String
    let title: String
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50)
                Spacer()
                Text(title)
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(isOn ? Color(red: 32/255, green: 64/255, blue: 32/255) : Color.gray)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 8, y: 8)
        }
        .padding(.horizontal)
    }
}
