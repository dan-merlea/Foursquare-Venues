//
//  FoursquareAPIRoute.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation

protocol FoursquareAPIRoute: APIRoute {}

extension FoursquareAPIRoute {
    
    func getQueryItems() -> [URLQueryItem] {
        var queryItems = [
            URLQueryItem(name: "v", value: Constants.Foursquare.version),
            URLQueryItem(name: "client_id", value: Constants.Foursquare.clientId),
            URLQueryItem(name: "client_secret", value: Constants.Foursquare.clientSecret),
            URLQueryItem(name: "limit", value: String(Constants.Foursquare.pageSize))
        ]
        
        parameters.forEach {
            queryItems.append(URLQueryItem(name: $0, value: String($1)))
        }
        
        return queryItems
    }
}
