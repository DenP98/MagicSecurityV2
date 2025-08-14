//
//  MailLiveKey.swift
//  MagicSecurity
//
//  Created by User on 30.05.25.
//

import MessageUI
import Dependencies

extension MailClient: DependencyKey {
    
    public static let liveValue = Self(
        canSendMail: {
            await MainActor.run {
                MFMailComposeViewController.canSendMail()
            }
        },
        presentMailComposer: { toEmail, subject, body in
            await MainActor.run {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    return
                }
                
                if MFMailComposeViewController.canSendMail() {
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.setToRecipients([toEmail])
                    mailComposer.setSubject(subject)
                    mailComposer.setMessageBody(body, isHTML: false)
                    mailComposer.mailComposeDelegate = MailComposeDelegate.shared
                    
                    rootViewController.present(mailComposer, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "Mail Not Available",
                        message: "Please configure a mail account in Settings to send emails.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    rootViewController.present(alert, animated: true)
                }
            }
        }
    )
}

@MainActor
private class MailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate, Sendable {
    static let shared = MailComposeDelegate()
    
    nonisolated func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
}
