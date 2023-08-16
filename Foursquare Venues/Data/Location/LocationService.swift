//
//  LocationService.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import MapKit
import Combine
import CoreLocation

enum ServiceState {
    case idle
    case ready
    case monitoring
}

protocol LocationService: AnyObject {
    
    var state: AnyPublisher<ServiceState, Never> { get }
    var location: AnyPublisher<CLLocation, Never> { get }
    
    func ready()
    func start()
    func stop()
}

class DefaultLocationService: NSObject, LocationService {
    
    /// Publishers
    let state: AnyPublisher<ServiceState, Never>
    let location: AnyPublisher<CLLocation, Never>
    
    /// Subjects
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    
    /// Data
    private let manager: CLLocationManager

    init(
        manager: CLLocationManager = CLLocationManager(),
        accuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters,
        distanceFilter: Double = 150
    ) {
        self.manager = manager
        self.location = locationSubject.eraseToAnyPublisher()
        self.state = stateSubject.eraseToAnyPublisher()
        
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = accuracy
        manager.distanceFilter = distanceFilter
        manager.showsBackgroundLocationIndicator = true
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
    }
    
    func ready() {
        guard stateSubject.value != .ready else {
            return
        }
        
        stateSubject.send(.ready)
    }

    func start() {
        guard stateSubject.value != .monitoring else {
            return
        }
        
        manager.startMonitoringSignificantLocationChanges()
        manager.startUpdatingLocation()
    }

    func stop() {
        guard stateSubject.value == .monitoring else {
            return
        }
        
        manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension DefaultLocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations
            .filter { $0.horizontalAccuracy >= 0 && $0.horizontalAccuracy <= 50 } // wait to get a valid position
            .forEach {
                locationSubject.send($0)
            }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error)
        // todo: error handling
        // UI: we can turn the navbar red + error message until the next successful event
    }
}
