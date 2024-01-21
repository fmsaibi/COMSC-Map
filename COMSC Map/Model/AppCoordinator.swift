//
//  AppCoordinator.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 18/08/2023.
//

import UIKit

class AppCoordinator {
    static func setupWindow(withViewControllerIdentifier identifier: String, inScene scene: UIScene, windowScene: UIWindowScene) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: identifier)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
