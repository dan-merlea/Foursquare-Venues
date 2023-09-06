//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine
import CoreLocation
import CombineSchedulers

protocol VenuesViewModel: ObservableObject {
    var venues: [Venue] { get set }
    var radius: Float { get set }
    var title: String { get set }
    var error: ErrorMessage? { get set }
    
    func currentSearchRadiusText() -> String
    
    func onRetrySearch() -> Void
}

final class DefaultVenuesViewModel<PermissionsType: Permissions>: VenuesViewModel
    where PermissionsType.Status == CLAuthorizationStatus {
    
    /// Publishers
    @Published var venues: [Venue] = []
    @Published var radius: Float = Constants.VenuesSearch.radiusSearch
    @Published var title: String = ""
    @Published var error: ErrorMessage?
    
    /// Data
    private var subscriptions = Set<AnyCancellable>()
    private var searchSubscription: AnyCancellable?
    private var inputsSubscription: AnyCancellable?
    private var lastLocationAvailable: CLLocationCoordinate2D?
    private let distanceRange: Float
    private let pageSize: Int
    
    /// Dependencies
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let networkService: NetworkService
    private let locationPermissions: PermissionsType
    private let locationService: LocationService
    
    init(
        networkService: NetworkService,
        locationPermissions: PermissionsType,
        locationService: LocationService,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        distanceRange: Float = Constants.VenuesSearch.radiusRange,
        pageSize: Int = Constants.Foursquare.pageSize
    ) {
        self.networkService = networkService
        self.locationPermissions = locationPermissions
        self.locationService = locationService
        self.distanceRange = distanceRange
        self.pageSize = pageSize
        self.scheduler = scheduler
        
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
        Int(radius * distanceRange)
    }
    
    private func updateTitle(for location: CLLocation?) {
        if location == nil {
            title = Constants.VenuesSearch.searchGpsTitle
        } else {
            title = Constants.VenuesSearch.venuesTitle
        }
    }
    
    private func askForLocationPermissionIfNeeded() {
        locationPermissions.request()
            .receive(on: scheduler)
            .sink { [weak self] status in
                if status == .denied {
                    self?.error = ErrorMessage.locationDenied
                    return
                }
                self?.subscribeForInputUpdates()
            }
            .store(in: &subscriptions)
    }
    
    private func subscribeForInputUpdates() {
        locationService.start()
        
        inputsSubscription = Publishers.CombineLatest(
            locationService.location,
            $radius.throttle(for: .milliseconds(500), scheduler: scheduler, latest: true)
        )
        .receive(on: scheduler)
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
        
        let route = VenuesSearchRoute(ll: location, radius: radiusValueToMeters(), limit: pageSize)
        searchSubscription = networkService.request(route: route)
            .receive(on: scheduler)
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
            self.error = ErrorMessage.customMessage(error.localizedDescription)
        default: ()
        }
    }
}
