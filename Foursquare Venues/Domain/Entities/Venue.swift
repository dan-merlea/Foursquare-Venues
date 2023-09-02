//
//  Venue.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

struct Venue: Codable, Identifiable {
    let id: String
    let name: String
    let location: VenueLocation
    let categories: [VenueCategory]
}

struct VenueLocation: Codable {
    let address: String?
    let distance: Int
}

struct VenueCategory: Codable {
    let name: String
    let shortName: String
    let icon: VenueCategoryIcon
}

struct VenueCategoryIcon: Codable {
    let prefix: String
    let suffix: String
}
