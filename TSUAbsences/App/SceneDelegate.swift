//
//  SceneDelegate.swift
//  TSUAbsences
//
//  Created by Богдан Тарченко on 25.02.2025.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        
        navigationController.setNavigationBarHidden(true, animated: false)
        
        let loadingViewController = UIHostingController(rootView: 
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                ProgressView()
            }
        )
        navigationController.setViewControllers([loadingViewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        
        coordinator = AppCoordinator(navigationController: navigationController)
        
        Task { @MainActor in
            await coordinator?.start()
        }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
