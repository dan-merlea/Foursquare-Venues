//
//  VenuesSearchRoute.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import CoreLocation

struct VenuesSearchRoute: FoursquareAPIRoute {
    typealias Response = ApiResponseBody
    
    let path = "/v2/venues/search"
    let method = RequestMethod.get
    let parameters: [String: LosslessStringConvertible]
    
    init(ll: CLLocationCoordinate2D, radius: Int) {
        self.parameters = [
            "radius": radius,
            "ll": "\(ll.latitude),\(ll.longitude)"
        ]
    }
}
