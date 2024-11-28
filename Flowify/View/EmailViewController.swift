//
//  EmailViewController.swift
//  Flowify
//
//  Created by Ramon Martinez on 11/26/24.
//

import MessageUI

class EmailViewController: MFMailComposeViewController {
    
    var presenter: EmailPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mailComposeDelegate = self
        
        presenter = EmailPresenter()
        populateEmailComposer()
    }
    
    func populateEmailComposer() {
        guard let presenter = presenter else { return }

        let recipient = presenter.fetchEmailRecipient
        let subject = presenter.fetchFlowName
        
        self.setToRecipients([recipient])
        self.setSubject(subject)
    }
}

extension EmailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .sent:
            print("Email sent successfully.")
        case .cancelled:
            print("Email was cancelled.")
        case .saved:
            print("Email was saved.")
        case .failed:
            print("Failed to send email.")
        @unknown default:
            print("Unknown result")
        }
    }
}
