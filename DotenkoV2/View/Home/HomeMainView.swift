import SwiftUI

struct HomeMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @StateObject private var profileVM = UserProfileViewModel()
    
    var body: some View {
        ZStack {
            // メインコンテンツ
            VStack(spacing: 16) {
                // ロゴ
                Image(uiImage: Appearance.Image.Common.logo ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                // プロフィールアイコンとユーザー名
                HStack {
                    Image(uiImage: Appearance.Image.Common.profileIcon ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(.white))
                        .overlay(Circle().stroke(Color(uiColor: Appearance.Color.goldenYellow), lineWidth: 2))
                    
                    if profileVM.isEditingName {
                        // 名前編集モード
                        TextField("名前を入力", text: $profileVM.newUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(Font(Appearance.Font.body))
                            .frame(width: 150)
                        
                        // 保存/キャンセルボタン
                        HStack(spacing: 8) {
                            Button(action: profileVM.updateUsername) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: profileVM.cancelEditing) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        // 表示モード
                        Text(profileVM.username)
                            .font(Font(Appearance.Font.casinoHeading))
                            .foregroundColor(.white)
                        
                        // 編集ボタン
                        Button(action: profileVM.startEditing) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // ゲームモード選択ボタン
                VStack(spacing: 16) {
                    // 個人戦ボタン
                    GameModeButton(
                        title: "個人戦",
                        backgroundImage: Appearance.Image.GameMode.singlePlayButton,
                        action: { navigator.push(SinglePlayView()) }
                    )
                    
                    // 友人戦ボタン
                    GameModeButton(
                        title: "友人戦",
                        backgroundImage: Appearance.Image.GameMode.friendPlayButton,
                        action: { navigator.push(FriendPlayView()) }
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 40)
            }
            
            // カード装飾
            CardDecorations()
        }
    }
}

// ゲームモードボタン
struct GameModeButton: View {
    let title: String
    let backgroundImage: UIImage?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // ボタンの背景
                if let image = backgroundImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: Appearance.Color.mossGreen))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(uiColor: Appearance.Color.goldenYellow), lineWidth: 2)
                        )
                }
                
                // ボタンのテキスト
                Text(title)
                    .font(Font(Appearance.Font.casinoDisplay))
                    .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            }
        }
        .frame(height: 70)
    }
}

// カード装飾
struct CardDecorations: View {
    var body: some View {
        ZStack {
            // 左上のカード
            Image(uiImage: Appearance.Image.Cards.kingCard ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .rotationEffect(.degrees(-15))
                .position(x: 40, y: 80)
            
            // 右下のカード
            Image(uiImage: Appearance.Image.Cards.aceSpade ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                .rotationEffect(.degrees(15))
                .position(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height - 160)
            
            // その他の装飾
            ForEach(0..<4) { i in
                Image(uiImage: Appearance.Image.Cards.cardDecoration ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .rotationEffect(.degrees(Double(i) * 90))
                    .position(
                        x: UIScreen.main.bounds.width * (i % 2 == 0 ? 0.2 : 0.8),
                        y: UIScreen.main.bounds.height * (i < 2 ? 0.25 : 0.65)
                    )
            }
        }
        .ignoresSafeArea()
    }
}

// プレビュー用のダミービュー
struct SinglePlayView: View {
    var body: some View {
        Text("個人戦")
    }
}

struct FriendPlayView: View {
    var body: some View {
        Text("友人戦")
    }
}
