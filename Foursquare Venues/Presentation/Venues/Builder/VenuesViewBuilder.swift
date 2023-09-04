//
//  VenuesViewBuilder.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 03.09.2023.
//

import UIKit
import SwiftUI
import CoreLocation

struct VenuesViewBuilder: ViewBuilder {
    
    func build(resolver: DIResolver) -> UIViewController {
        let viewModel: DefaultVenuesViewModel = resolver.resolve(type: DefaultVenuesViewModel<LocationPermissions>.self)
        let view = VenuesView(viewModel: viewModel)
        return UIHostingController(rootView: view)
    }
}
