//
//  Int+Distance.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

extension Int {
    
    func toDistanceString() -> String {
        if self > 1000 {
            return String(format: "%.1f km", Double(self) / 1000)
        }
        
        return String(format: "%d m", self)
    }
}
