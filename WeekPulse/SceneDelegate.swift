//
//  SceneDelegate.swift
//  WeekPulse
//
//  Created by Олександр on 22.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController,
           let selectedNavController = tabBarController.selectedViewController as? UINavigationController,
           let rootViewController = selectedNavController.viewControllers.first as? ViewController {
            rootViewController.restartAnimationForVisibleCells()
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }

}

