//
//  SceneDelegate.swift
//  Flowify
//
//  Created by Ramon Martinez on 7/13/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let launchViewController = LaunchViewController()
        let navigationController = UINavigationController(rootViewController: launchViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
