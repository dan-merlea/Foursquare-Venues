//
//  VenuesInteractor.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine
import CoreLocation

protocol VenuesInteractor {
    func searchForVenues(radius: Int) -> AnyPublisher<ApiResponseBody, ServerErrorState>
}

final class DefaultVenuesInteractor: VenuesInteractor {
    
    /// Dependencies
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func searchForVenues(radius: Int) -> AnyPublisher<ApiResponseBody, ServerErrorState> {
        let route = VenuesSearchRoute(ll: CLLocationCoordinate2D(latitude: 52.3547418, longitude: 4.8215606), radius: radius, limit: 20)
        return networkService.request(route: route)
    }
}
