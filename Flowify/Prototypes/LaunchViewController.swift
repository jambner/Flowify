//
//  LaunchViewController.swift
//  Flowify
//
//  Created by jambo on 9/21/24.
//

import UIKit

class LaunchViewController: Components {
    private let formVC = FormViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
//    @objc func startButtonTapped() {
//        navigationController?.popToViewController(<#T##viewController: UIViewController##UIViewController#>, animated: true)
//    }
    
    func setupViews() {
        view.addSubview(startButton)
        
        view.backgroundColor = .white
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
