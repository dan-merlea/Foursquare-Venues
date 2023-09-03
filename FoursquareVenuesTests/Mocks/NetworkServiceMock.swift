//
//  NetworkServiceMock.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 03.09.2023.
//

import Foundation
import Combine
@testable import FoursquareVenues

class NetworkServiceMock: NetworkService {
    
    static let stub = ApiResponseBody(response: Response(venues: [
        Venue(
            id: "1",
            name: "Central Park",
            location: VenueLocation(address: "City Center", distance: 0),
            categories: [
                VenueCategory(name: "", shortName: "Park", icon: VenueCategoryIcon(prefix: "img", suffix: "png"))
            ]
        )
    ]))
    
    static let stubList = ApiResponseBody(response: Response(venues: [
        Venue(
            id: "1",
            name: "Central Park",
            location: VenueLocation(address: "City Center", distance: 0),
            categories: [
                VenueCategory(name: "", shortName: "Park", icon: VenueCategoryIcon(prefix: "img", suffix: "png"))
            ]
        ),
        Venue(
            id: "2",
            name: "Restaurant",
            location: VenueLocation(address: "City Center", distance: 10),
            categories: [
                VenueCategory(name: "", shortName: "Food", icon: VenueCategoryIcon(prefix: "img", suffix: "png"))
            ]
        )
    ]))
    
    var requestResult = Result<Any, ServerErrorState>
        .success(NetworkServiceMock.stub)
        .publisher
        .eraseToAnyPublisher()
    
    var lastRoute: ((any APIRoute) -> Void)?
    
    func request<T>(route: T) -> AnyPublisher<T.Response, ServerErrorState> where T : APIRoute {
        lastRoute?(route)
        return requestResult
            .map { $0 as! T.Response }
            .eraseToAnyPublisher()
    }
}
