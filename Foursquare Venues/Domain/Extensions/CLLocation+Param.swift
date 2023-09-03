//
//  File.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 03.09.2023.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    func toParamString() -> String {
        return String(format: "%f,%f", self.latitude, self.longitude)
    }
}
