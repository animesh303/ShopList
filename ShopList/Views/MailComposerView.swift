import SwiftUI
import MessageUI

struct MailComposerView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@shoplist.app"])
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .sent:
                // Email was sent successfully
                break
            case .failed:
                // Email failed to send
                break
            case .cancelled:
                // User cancelled
                break
            case .saved:
                // Email was saved as draft
                break
            @unknown default:
                break
            }
            
            parent.dismiss()
        }
    }
}

// MARK: - Mail Availability Check

struct MailComposerView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Mail Composer")
    }
} 