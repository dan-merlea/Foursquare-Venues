//
//  Coordinator.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

public protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get }
    var navigationController: UINavigationController { get }
    
    func start()
}
