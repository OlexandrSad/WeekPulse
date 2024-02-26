//
//  SceneDelegate.swift
//  WeekPulse
//
//  Created by Олександр on 22.11.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var sceneDidResign = false
    var window: UIWindow?
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    
    func sceneDidBecomeActive(_ scene: UIScene) {
        resetAppBadge()
        
        guard let windowScene = (scene as? UIWindowScene), sceneDidResign == true else { return }
        if let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController,
           let selectedNavController = tabBarController.selectedViewController as? UINavigationController,
           let rootViewController = selectedNavController.viewControllers.first as? ViewController {
            rootViewController.restartAnimationForVisibleCells()
        }
    }
    
    
    func sceneWillResignActive(_ scene: UIScene) {
        sceneDidResign = true
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
    
    
    func resetAppBadge() {
        let center = UNUserNotificationCenter.current()
        center.setBadgeCount(0, withCompletionHandler: nil)
    }

}

