//
//  LocationPermissions.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine
import CoreLocation

class LocationPermissions: NSObject, Permissions {
    
    typealias Status = CLAuthorizationStatus
    
    /// Public publishers
    let status: AnyPublisher<CLAuthorizationStatus, Never>
    
    /// Subjects
    private let statusSubject: CurrentValueSubject<CLAuthorizationStatus, Never>
    
    /// Data
    private let manager: CLLocationManager
    private var subscriptions = Set<AnyCancellable>()
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        self.statusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(
            manager.authorizationStatus
        )
        self.status = statusSubject.eraseToAnyPublisher()
        super.init()
        
        self.manager.delegate = self
    }
    
    func request() -> Future<CLAuthorizationStatus, Never> {
        Future { [weak self] promise in
            guard let self = self else { return }

            self.status
                .sink { promise(.success($0)) }
                .store(in: &self.subscriptions)
            self.manager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationPermissions: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        statusSubject.send(status)
    }
}

