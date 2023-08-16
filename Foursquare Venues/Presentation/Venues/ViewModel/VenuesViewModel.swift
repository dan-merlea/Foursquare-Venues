//
//  VenuesViewModel.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine

protocol VenuesViewModel {
    func getCurrentSearchRadiusText() -> String
    func getCurrentSearchRadius() -> Float
    func updateSearchRadius(_ radius: Float)
    
    func numberOfVenues() -> Int
    func venueAt(index: Int) -> Any // todo: change with Venue model
}

final class DefaultVenuesViewModel: VenuesViewModel {
    
    private let radiusSubject = CurrentValueSubject<Float, Never>(0.3)
    
    /// Data
    private let interactor: VenuesInteractor
    private var subscriptions = Set<AnyCancellable>()
    
    init(interactor: VenuesInteractor) {
        self.interactor = interactor
        
        subscribeForInputUpdates()
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
        return 5
    }
    
    func venueAt(index: Int) -> Any {
        return NSObject() // todo
    }
    
    // MARK: - Private
    
    private func radiusValueToMeters() -> Int {
        Int(getCurrentSearchRadius() * 2_000) // 0-2km
    }
    
    private func subscribeForInputUpdates() {
        radiusSubject
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { radius in
                print(radius)
            }
            .store(in: &subscriptions)
    }
}
