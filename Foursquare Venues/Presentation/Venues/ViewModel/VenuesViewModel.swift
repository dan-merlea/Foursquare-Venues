//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation

protocol VenuesViewModel {
    func updateSearchRadius(_ radius: Float)
    
    func numberOfVenues() -> Int
    func venueAt(index: Int) -> Any // todo: change with Venue model
}

final class DefaultVenuesViewModel: VenuesViewModel {
    
    
    func updateSearchRadius(_ radius: Float) {
        print(radius)
    }
    
    func numberOfVenues() -> Int {
        return 5
    }
    
    func venueAt(index: Int) -> Any {
        return NSObject() // todo
    }
}
