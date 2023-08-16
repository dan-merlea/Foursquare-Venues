//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine

protocol VenuesViewModel {
    var venues: AnyPublisher<[Venue], Never> { get }
    var radius: AnyPublisher<Float, Never> { get }
    var errorHandled: ErrorHandled? { get set }
    
    func getCurrentSearchRadiusText() -> String
    func getCurrentSearchRadius() -> Float
    func updateSearchRadius(_ radius: Float)
    
    func numberOfVenues() -> Int
    func venueAt(index: Int) -> Venue
}

final class DefaultVenuesViewModel: VenuesViewModel {
    
    /// Public publishers
    let venues: AnyPublisher<[Venue], Never>
    let radius: AnyPublisher<Float, Never>
    
    /// Subjects
    private var venuesSubject = CurrentValueSubject<[Venue], Never>([])
    private let radiusSubject = CurrentValueSubject<Float, Never>(0.3)
    
    /// Data
    weak var errorHandled: ErrorHandled?
    private let interactor: VenuesInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var searchSubscription: AnyCancellable?
    
    init(interactor: VenuesInteractor) {
        self.venues = venuesSubject.eraseToAnyPublisher()
        self.radius = radiusSubject.eraseToAnyPublisher()
        self.interactor = interactor
        
        askForLocationPermissionIfNeeded()
    }
    
    // MARK: - Public
    
    func getCurrentSearchRadiusText() -> String {
        "Radius: \(radiusValueToMeters().toDistanceString())"
    }
    
    func getCurrentSearchRadius() -> Float {
        radiusSubject.value
    }
    
    func updateSearchRadius(_ radius: Float) {
        radiusSubject.send(radius)
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
        Int(getCurrentSearchRadius() * 2_000) // 0-2km
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
        radiusSubject
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] _ in
                self?.searchForVenues()
            }
            .store(in: &subscriptions)
    }
    
    private func searchForVenues() {
        searchSubscription?.cancel() /// avoid spamming the API
        
        searchSubscription = interactor
            .searchForVenues(radius: radiusValueToMeters())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.requestFinishedWithStatus(status: status)
            } receiveValue: { [weak self] result in
                self?.venuesSubject.send(result.response.venues)
            }
    }
    
    private func requestFinishedWithStatus(status: Subscribers.Completion<ServerErrorState>) {
        switch status {
        case .failure(let error):
            venuesSubject.send([])
            errorHandled?.handle(error) { [weak self] in
                // todo
            }
        default: ()
        }
    }
}
