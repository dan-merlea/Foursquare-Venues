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
    associatedtype Response: Decodable
    
    var path: String { get }
    var parameters: [String: LosslessStringConvertible] { get }
    var body: Encodable? { get }
    var method: RequestMethod { get }
    
    func url() -> URL?
    func queryItems() -> [URLQueryItem]
}

extension APIRoute {
    
    var body: Encodable? {
        return nil
    }
    
    /// Build URL
    func url() -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = Constants.Foursquare.api
        component.path = path
        if method == .get {
            component.queryItems = queryItems()
        }
        return component.url
    }
}
