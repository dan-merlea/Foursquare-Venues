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
        let config = Constants.Foursquare()
        var queryItems = [
            URLQueryItem(name: "v", value: config.version),
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "client_secret", value: config.clientSecret),
            URLQueryItem(name: "limit", value: String(config.pageSize))
        ]
        
        parameters.forEach {
            queryItems.append(URLQueryItem(name: $0, value: String($1)))
        }
        
        return queryItems
    }
}
