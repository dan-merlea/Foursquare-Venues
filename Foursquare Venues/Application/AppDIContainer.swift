//
//  AppDIContainer.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 02.09.2023.
//

import Foundation
import CoreLocation

protocol DIResolver {
    func resolve<Service>(type: Service.Type) -> Service
}

protocol DIContainer: DIResolver {
    func register<Service>(type: Service.Type, componentBuilder: (DIResolver) -> Any)
}

final class AppDIContainer: DIContainer {
        
     var services: [String: Any] = [:]
     
     init() {
         register(type: DefaultNetworkService.self) { _ in
             DefaultNetworkService()
         }
         register(type: DefaultLocationService.self) { _ in
             DefaultLocationService()
         }
         
         register(type: LocationPermissions.self) { resolver in
             LocationPermissions(
                locationService: resolver.resolve(type: DefaultLocationService.self)
             )
         }
         
         register(type: DefaultVenuesViewModel<LocationPermissions>.self) { resolver in
             DefaultVenuesViewModel(
                networkService: resolver.resolve(type: DefaultNetworkService.self),
                locationPermissions: resolver.resolve(type: LocationPermissions.self),
                locationService: resolver.resolve(type: DefaultLocationService.self)
             )
         }
     }
     
     func register<Service>(type: Service.Type, componentBuilder: (DIResolver) -> Any) {
         guard services["\(type)"] == nil else {
             return
         }
         services["\(type)"] = componentBuilder(self)
     }

     func resolve<Service>(type: Service.Type) -> Service {
         guard let service = services["\(type)"] as? Service else {
             fatalError("\(type) dependency was not registered")
         }
         return service
     }
}
