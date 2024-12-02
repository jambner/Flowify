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
        presenter = EmailPresenter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateEmailComposer(from: self)
    }
    
    func populateEmailComposer(from viewController: UIViewController) {
        guard let presenter = presenter else {
            print("Presenter is nil")
            return
        }

        let recipient = presenter.fetchEmailRecipient
        let subject = presenter.fetchFlowName

        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([recipient])
        mailComposer.setSubject(subject)

        viewController.present(mailComposer, animated: true, completion: nil)
    }
}

extension EmailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
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
