import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor
    func start() async {
        if let token = try? KeychainService.shared.loadToken() {
            do {
                let _: UserProfile = try await NetworkManager.shared.request(
                    endpoint: "/user/profile",
                    method: "GET",
                    body: EmptyRequest()
                )
                
                let mainScreen = MainScreen()
                let hostingController = UIHostingController(rootView: mainScreen)
                navigationController.setViewControllers([hostingController], animated: true)
            } catch {
                try? KeychainService.shared.deleteToken()
                showWelcomeScreen()
            }
        } else {
            showWelcomeScreen()
        }
    }
    
    @MainActor
    private func showWelcomeScreen() {
        let welcomeScreen = WelcomeScreen()
        let hostingController = UIHostingController(rootView: welcomeScreen)
        navigationController.setViewControllers([hostingController], animated: true)
    }
} 
