//
//  LaunchViewController.swift
//  Flowify
//
//  Created by jambo on 9/21/24.
//

import UIKit

class LaunchViewController: UIViewController {

    private var appIconImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        appIconImageView = UIImageView(image: UIImage(named: "flowify-icon"))
        appIconImageView.contentMode = .scaleAspectFit
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appIconImageView)
        
        NSLayoutConstraint.activate([
            appIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appIconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 120),
            appIconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.fadeOutLaunchScreen()
        }
    }
    
    private func fadeOutLaunchScreen() {
        UIView.animate(withDuration: 1.0, animations: {
            self.appIconImageView.alpha = 0
        }) { _ in
            self.transitionToMainAppScreen()
        }
    }

    private func transitionToMainAppScreen() {
        if let window = view.window {
            let mainVC = FormViewController()
            window.rootViewController = mainVC
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
