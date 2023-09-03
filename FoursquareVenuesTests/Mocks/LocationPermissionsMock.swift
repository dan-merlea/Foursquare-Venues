//
//  LocationPermissionsMock.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 03.09.2023.
//

import Foundation
import Combine
import CoreLocation
@testable import FoursquareVenues

class LocationPermissionsMock: Permissions {
    
    typealias Status = CLAuthorizationStatus
    
    /// Publishers
    var status: AnyPublisher<CLAuthorizationStatus, Never>
    
    /// Subjects
    let locationSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.status = locationSubject.eraseToAnyPublisher()
    }
    
    func request() -> Future<CLAuthorizationStatus, Never> {
        Future { [weak self] promise in
            promise(.success(.authorizedWhenInUse))
            self?.locationSubject.send(.authorizedWhenInUse)
            self?.locationService.ready()
        }
    }
}
