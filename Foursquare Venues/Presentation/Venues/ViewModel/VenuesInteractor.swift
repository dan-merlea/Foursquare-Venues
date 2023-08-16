//
//  VenuesInteractor.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine
import CoreLocation

protocol VenuesInteractor {
    func searchForVenues() -> AnyPublisher<ApiResponseBody, ServerErrorState>
}

final class DefaultVenuesInteractor: VenuesInteractor {
    
    /// Dependencies
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func searchForVenues() -> AnyPublisher<ApiResponseBody, ServerErrorState> {
        let route = VenuesSearchRoute(ll: CLLocationCoordinate2D(latitude: 23, longitude: 44), radius: 500, limit: 20)
        return networkService.request(route: route)
    }
}
