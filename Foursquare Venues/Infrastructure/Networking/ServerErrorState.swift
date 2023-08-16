//
//  ServerErrorState.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

enum ServerErrorState: Error {
    case decode(String)
    case invalidURL
    case serverError
    
    var localizedDescription: String {
        switch self {
        case .decode(let error):
            return error
        case .invalidURL:
            return "The URL is invalid"
        case .serverError:
            return "Server error"
        }
    }
}
