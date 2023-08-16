//
//  APIRoute.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol APIRoute {
    var path: String { get }
    var parameters: [String: LosslessStringConvertible] { get }
    var body: Encodable? { get }
    var method: RequestMethod { get }
    
    func getQueryItems() -> [URLQueryItem]
}

extension APIRoute {
    
    var body: Encodable? {
        return nil
    }
    
    /// Build URL
    func getUrl() -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = Constants.Foursquare.api
        component.path = path
        if method == .get {
            component.queryItems = getQueryItems()
        }
        return component.url
    }
}
