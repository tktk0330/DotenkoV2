/**
 Mailによる報告
 */

import SwiftUI
import MessageUI

struct ContactView: View {
    
    @State private var showMailView = false
    @State private var showAlert = false

    var body: some View {
        
        HStack() {
            
            Spacer()
            
            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    self.showMailView = true
                } else {
                    self.showAlert = true
                }
            }) {
                Text("お問い合わせ")
//                    .font(.custom(FontName.font01, size: 20))
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .bold()
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
//                            .fill(Color.casinoGreen)
//                            .shadow(color: Color.casinoShadow, radius: 1, x: 5, y: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white, lineWidth: 5)
                    )
                
            }
            .sheet(isPresented: $showMailView) {
                MailView(toRecipients: [Config.mailAddress], subject: "お問い合わせ（DOTENKO）")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("メール設定不足"),
                    message: Text("デバイスにメールアカウントが設定されていません。メールアプリでアカウントを設定してください。")
                )
            }
            
            Spacer()
            
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var toRecipients: [String]
    var subject: String  // 件名

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients(toRecipients)
        mailComposeVC.setSubject(subject)  // 件名を設定
        
        // HTMLフォーマットのメール本文を設定
        let htmlBody = """
        <html>
            <body>
                <p>この度は「DOTENKO」をご利用いただきありがとうございます。</p>
                <p>お問い合わせ内容を下記にご記入ください：</p>
                <br>
                <ul>
                    <li>問合せ内容：</li>
                </ul>
            </body>
        </html>
        """
        mailComposeVC.setMessageBody(htmlBody, isHTML: true)
        return mailComposeVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
