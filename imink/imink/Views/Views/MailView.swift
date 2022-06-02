//
//  MailView.swift
//  imink
//
//  Created by Jone Wang on 2021/3/23.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    let recipient: String
    var textAttachmentName: String? = nil
    var textAttachmentContent: String? = nil
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            isShowing = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        if let data = textAttachmentContent?.data(using: .utf8), let name = textAttachmentName {
            vc.addAttachmentData(data, mimeType: "text/plain", fileName: name)
        }
        
        vc.setToRecipients([recipient])
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {}
}

extension MailView {
    
    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}
