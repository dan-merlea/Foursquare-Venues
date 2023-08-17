//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine
import CoreLocation

protocol VenuesViewModel {
    var venues: AnyPublisher<[Venue], Never> { get }
    var radiusPublisher: Published<Float>.Publisher { get }
    var errorHandled: ErrorHandled? { get set }
    
    func getCurrentSearchRadiusText() -> String
    func getCurrentSearchRadius() -> Float
    func updateSearchRadius(_ radius: Float)
    
    func numberOfVenues() -> Int
    func venueAt(index: Int) -> Venue
}

final class DefaultVenuesViewModel: VenuesViewModel {
    
    /// Publishers
    let venues: AnyPublisher<[Venue], Never>
    @Published private(set) var radius: Float
    
    /// Subjects
    private var venuesSubject = CurrentValueSubject<[Venue], Never>([])
    internal var radiusPublisher: Published<Float>.Publisher { $radius }
    
    /// Data
    weak var errorHandled: ErrorHandled?
    private let interactor: VenuesInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var searchSubscription: AnyCancellable?
    private var inputsSubscription: AnyCancellable?
    private var lastLocationAvailable: CLLocationCoordinate2D?
    
    init(interactor: VenuesInteractor) {
        self.venues = venuesSubject.eraseToAnyPublisher()
        self.radius = 0.3
        self.interactor = interactor
        
        askForLocationPermissionIfNeeded()
    }
    
    // MARK: - Public
    
    func getCurrentSearchRadiusText() -> String {
        "Radius: \(radiusValueToMeters().toDistanceString())"
    }
    
    func getCurrentSearchRadius() -> Float {
        radius
    }
    
    func updateSearchRadius(_ radius: Float) {
        self.radius = radius
    }
    
    func numberOfVenues() -> Int {
        return venuesSubject.value.count
    }
    
    func venueAt(index: Int) -> Venue {
        guard index >= 0, index < venuesSubject.value.count else {
            fatalError("Trying to access a non-existing venue from ViewModel")
        }
        
        return venuesSubject.value[index]
    }
    
    // MARK: - Private
    
    private func radiusValueToMeters() -> Int {
        Int(radius * 2_000) // 0-2km
    }
    
    private func askForLocationPermissionIfNeeded() {
        interactor
            .askForLocationPermission()
            .sink { [weak self] status in
                self?.subscribeForInputUpdates()
            }
            .store(in: &subscriptions)
    }
    
    private func subscribeForInputUpdates() {
        inputsSubscription = Publishers.CombineLatest(
            interactor.subscribeForLocationChanges(),
            $radius
        )
        .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
        .sink { [weak self] location, _ in
            self?.searchForVenues(location: location.coordinate)
        }
    }
    
    private func searchForVenues(location: CLLocationCoordinate2D) {
        searchSubscription?.cancel() /// Avoid spamming the API
        
        lastLocationAvailable = location
        
        searchSubscription = interactor
            .searchForVenues(radius: radiusValueToMeters(), location: location)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.requestFinishedWithStatus(status: status)
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                
                /// Adding extra filtering due to API not being confident all the time
                let venues = result.response.venues
                    .filter { $0.location.distance <= self.radiusValueToMeters() }
                self.venuesSubject.send(venues)
            }
    }
    
    private func requestFinishedWithStatus(status: Subscribers.Completion<ServerErrorState>) {
        switch status {
        case .failure(let error):
            
            venuesSubject.send([])
            inputsSubscription?.cancel()
            
            errorHandled?.handle(error) { [weak self] in
                guard let self = self else { return }
                
                /// Re-Subscribe to input events
                self.subscribeForInputUpdates()
                
                /// Force a reload
                if let location = self.lastLocationAvailable {
                    self.searchForVenues(location: location)
                }
            }
        default: ()
        }
    }
}
