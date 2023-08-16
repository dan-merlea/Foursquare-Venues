//
//  VenuesCoordinator.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

final class VenuesCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = DefaultVenuesViewModel()
        let viewController = VenuesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
}
