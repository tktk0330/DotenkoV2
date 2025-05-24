import SwiftUI

struct SettingsButtonsView: View {
    @Binding var isSEOn: Bool
    @Binding var isSoundOn: Bool
    @Binding var isVibrationOn: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            SettingButton(
                icon: "music.note",
                title: "SE",
                isOn: isSEOn,
                onToggle: { isSEOn.toggle() }
            )
            SettingButton(
                icon: "speaker.wave.2",
                title: "Sound",
                isOn: isSoundOn,
                onToggle: { isSoundOn.toggle() }
            )
            SettingButton(
                icon: "iphone.radiowaves.left.and.right",
                title: "Vibration",
                isOn: isVibrationOn,
                onToggle: { isVibrationOn.toggle() }
            )
        }
        .padding(.top, 40)
    }
} 