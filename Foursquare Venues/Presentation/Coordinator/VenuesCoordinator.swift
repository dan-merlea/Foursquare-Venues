//
//  VenuesCoordinator.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

final class VenuesCoordinator: Coordinator {
    
    let networkService = DefaultNetworkService()
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let locationService = DefaultLocationService()
        let locationPermissions = LocationPermissions(locationService: locationService)
        let interactor = DefaultVenuesInteractor(
            networkService: networkService,
            locationPermissions: locationPermissions,
            locationService: locationService
        )
        let viewModel = DefaultVenuesViewModel(interactor: interactor)
        let viewController = VenuesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
}
