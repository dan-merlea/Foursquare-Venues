//
//  APIResponse.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

struct ApiResponseBody: Codable {
    let response: Response
}

struct Response: Codable {
    let venues: [Venue]
}
