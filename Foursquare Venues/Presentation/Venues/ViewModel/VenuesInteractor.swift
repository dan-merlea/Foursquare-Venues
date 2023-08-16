//
//  VenuesInteractor.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine
import CoreLocation

protocol VenuesInteractor {
    func askForLocationPermission() -> Future<CLAuthorizationStatus, Never>
    func subscribeForLocationChanges() -> AnyPublisher<CLLocation, Never>
    func searchForVenues(
        radius: Int,
        location: CLLocationCoordinate2D
    ) -> AnyPublisher<ApiResponseBody, ServerErrorState>
}

final class DefaultVenuesInteractor<PermissionsType: Permissions>: VenuesInteractor
    where PermissionsType.Status == CLAuthorizationStatus {
    
    /// Dependencies
    private let networkService: NetworkService
    private let locationPermissions: PermissionsType
    private let locationService: LocationService
    
    /// Data
    private var subscriptions = Set<AnyCancellable>()
    
    init(
        networkService: NetworkService,
        locationPermissions: PermissionsType,
        locationService: LocationService
    ) {
        self.networkService = networkService
        self.locationPermissions = locationPermissions
        self.locationService = locationService
    }
    
    func askForLocationPermission() -> Future<CLAuthorizationStatus, Never> {
        locationPermissions.request()
    }
    
    func subscribeForLocationChanges() -> AnyPublisher<CLLocation, Never> {
        locationService.start()
        return locationService.location
    }
    
    func searchForVenues(radius: Int, location: CLLocationCoordinate2D) -> AnyPublisher<ApiResponseBody, ServerErrorState> {
        let route = VenuesSearchRoute(ll: location, radius: radius)
        return networkService.request(route: route)
    }
}
