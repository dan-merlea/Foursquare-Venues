//
//  LocationServiceMock.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 03.09.2023.
//

import Foundation
import Combine
import CoreLocation
@testable import FoursquareVenues

class LocationServiceMock: LocationService {
    
    static let stub = CLLocation(latitude: 23.4, longitude: 10)
    
    /// Publishers
    var state: AnyPublisher<ServiceState, Never>
    var location: AnyPublisher<CLLocation?, Never>
    
    /// Subjects
    let locationSubject = PassthroughSubject<CLLocation?, Never>()
    let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    
    init() {
        self.state = stateSubject.eraseToAnyPublisher()
        self.location = locationSubject.eraseToAnyPublisher()
    }
    
    func ready() {
        stateSubject.send(.ready)
    }
    
    func start() {}
    func stop() {}
}
