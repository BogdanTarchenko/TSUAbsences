import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    
    @MainActor
    func start() async
}
