//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine
import CoreLocation

protocol VenuesViewModel: ObservableObject {
    var venues: [Venue] { get set }
    var radius: Float { get set }
    var title: String { get set }
    var error: ServerErrorState? { get set }
    
    func currentSearchRadiusText() -> String
    
    func onRetrySearch() -> Void
}

final class DefaultVenuesViewModel<PermissionsType: Permissions>: VenuesViewModel
    where PermissionsType.Status == CLAuthorizationStatus {
    
    /// Publishers
    @Published var venues: [Venue] = []
    @Published var radius: Float = 0.3 // TODO: move to constants
    @Published var title: String = ""
    @Published var error: ServerErrorState?
    
    /// Data
    private var subscriptions = Set<AnyCancellable>()
    private var searchSubscription: AnyCancellable?
    private var inputsSubscription: AnyCancellable?
    private var lastLocationAvailable: CLLocationCoordinate2D?
    
    /// Dependencies
    private let networkService: NetworkService
    private let locationPermissions: PermissionsType
    private let locationService: LocationService
    
    init(
        networkService: NetworkService,
        locationPermissions: PermissionsType,
        locationService: LocationService
    ) {
        self.networkService = networkService
        self.locationPermissions = locationPermissions
        self.locationService = locationService
        
        askForLocationPermissionIfNeeded()
        updateTitle(for: nil)
    }
    
    // MARK: - Public
    
    func currentSearchRadiusText() -> String {
        "Radius: \(radiusValueToMeters().toDistanceString())"
    }
    
    func onRetrySearch() {
        if let lastLocationAvailable = lastLocationAvailable {
            searchForVenues(location: lastLocationAvailable)
        }
    }
    
    // MARK: - Private
    
    private func radiusValueToMeters() -> Int {
        Int(radius * 2_000) // 0-2km
    }
    
    private func updateTitle(for location: CLLocation?) {
        if location == nil {
            title = "Searching for GPS"
        } else {
            title = "Venues around you"
        }
    }
    
    private func askForLocationPermissionIfNeeded() {
        locationPermissions.request()
            .sink { [weak self] status in
                self?.subscribeForInputUpdates()
            }
            .store(in: &subscriptions)
    }
    
    private func subscribeForInputUpdates() {
        locationService.start()
        
        inputsSubscription = Publishers.CombineLatest(
            locationService.location,
            $radius.throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
        )
        .sink { [weak self] location, _ in
            if let location = location {
                self?.searchForVenues(location: location.coordinate)
            }
            self?.updateTitle(for: location)
        }
    }
    
    private func searchForVenues(location: CLLocationCoordinate2D) {
        searchSubscription?.cancel()
        
        lastLocationAvailable = location
        
        let route = VenuesSearchRoute(ll: location, radius: radiusValueToMeters())
        searchSubscription = networkService.request(route: route)
            .receive(on: DispatchQueue.main)
            .map { $0.response.venues.filter {
                $0.location.distance <= self.radiusValueToMeters()
            }}
            .sink { [weak self] status in
                self?.requestFinishedWithStatus(status: status)
            } receiveValue: { [weak self] venues in
                self?.venues = venues
            }
    }
    
    private func requestFinishedWithStatus(status: Subscribers.Completion<ServerErrorState>) {
        switch status {
        case .failure(let error):
            self.error = error
        default: ()
        }
    }
}
