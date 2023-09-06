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
    let statusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
        self.status = statusSubject.eraseToAnyPublisher()
    }
    
    func request() -> Future<CLAuthorizationStatus, Never> {
        Future { [weak self] promise in
            promise(.success(.authorizedWhenInUse))
            self?.statusSubject.send(.authorizedWhenInUse)
            self?.locationService.ready()
        }
    }
}
