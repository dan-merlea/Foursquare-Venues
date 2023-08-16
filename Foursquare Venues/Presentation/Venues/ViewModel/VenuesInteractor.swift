//
//  VenuesInteractor.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine
import CoreLocation

protocol VenuesInteractor {
    func askForLocationPermission()
    func searchForVenues(radius: Int) -> AnyPublisher<ApiResponseBody, ServerErrorState>
}

final class DefaultVenuesInteractor: VenuesInteractor {
    
    /// Dependencies
    private let networkService: NetworkService
    private let locationPermissions: LocationPermissions
    
    init(networkService: NetworkService, locationPermissions: LocationPermissions) {
        self.networkService = networkService
        self.locationPermissions = locationPermissions
    }
    
    func askForLocationPermission() {
        locationPermissions.request()
    }
    
    func searchForVenues(radius: Int) -> AnyPublisher<ApiResponseBody, ServerErrorState> {
        let route = VenuesSearchRoute(ll: CLLocationCoordinate2D(latitude: 52.3547418, longitude: 4.8215606), radius: radius, limit: 20)
        return networkService.request(route: route)
    }
}
