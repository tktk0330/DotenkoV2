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
                    .foregroundColor(Appearance.Color.commonWhite)
                    .frame(width: 50)
                Spacer()
                Text(title)
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(Appearance.Color.commonWhite)
                Spacer()
            }
            .padding()
            .background(isOn ? Appearance.Color.settingActiveGreen : Appearance.Color.commonGray)
            .cornerRadius(10)
            .shadow(color: Appearance.Color.commonBlack.opacity(0.3), radius: 8, x: 8, y: 8)
        }
        .padding(.horizontal)
    }
}
