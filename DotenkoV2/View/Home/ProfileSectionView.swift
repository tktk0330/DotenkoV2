import SwiftUI

struct ProfileSectionView: View {
    @ObservedObject var profileVM: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                // プロフィール画像表示
                Group {
                    if let uiImage = profileVM.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // デフォルトアイコン
                        Image(systemName: Appearance.Icon.personFill)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                            .foregroundStyle(Appearance.Color.commonGray)
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
                .background(Appearance.Color.commonBlack.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Appearance.Color.commonGray, lineWidth: 1)
                )
                .onTapGesture {
                    profileVM.isPickerPresented = true
                }

                if case .loading = profileVM.updateState {
                    ProgressView("アップロード中…")
                }

                if case .error(let message) = profileVM.updateState {
                    Text(message)
                        .foregroundColor(Appearance.Color.commonRed)
                        .font(.caption)
                }
            }
            .sheet(isPresented: $profileVM.isPickerPresented) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    profileVM.didSelectImage(image)
                }
            }
            
            HStack(spacing: 16) {
                if profileVM.isEditingName {
                    // 名前編集モード
                    TextField("名前を入力", text: $profileVM.newUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font(Appearance.Font.body))
                        .frame(width: 150)
                    
                    // 保存/キャンセルボタン
                    HStack(spacing: 8) {
                        Button(action: profileVM.updateUsername) {
                            Image(systemName: Appearance.Icon.checkmarkCircleFill)
                                .foregroundColor(Appearance.Color.commonGreen)
                        }
                        
                        Button(action: profileVM.cancelEditing) {
                            Image(systemName: Appearance.Icon.xmarkCircleFill)
                                .foregroundColor(Appearance.Color.commonRed)
                        }
                    }
                } else {
                    // 表示モード
                    Text(profileVM.username)
                        .font(Font(Appearance.Font.casinoHeading))
                        .foregroundColor(Appearance.Color.commonWhite)
                    
                    // 編集ボタン
                    Button(action: profileVM.startEditing) {
                        Image(systemName: Appearance.Icon.pencilCircleFill)
                            .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
} 
