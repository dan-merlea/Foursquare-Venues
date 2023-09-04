//
//  FoursquareVenuesTests.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 02.09.2023.
//

import XCTest
import Combine
import CoreLocation
@testable import FoursquareVenues

final class VenuesViewModelTests: XCTestCase {
    
    private let rangeDistance: Float = 10
    private var subscriptions: Set<AnyCancellable> = []
    
    private let timeout: TimeInterval = 1
    private var sut: DefaultVenuesViewModel<LocationPermissionsMock>?
    private var networkServiceMock: NetworkServiceMock!
    private var locationServiceMock: LocationServiceMock!
    private var locationPermissionsMock: LocationPermissionsMock!

    override func setUp()  {
        networkServiceMock = NetworkServiceMock()
        locationServiceMock = LocationServiceMock()
        locationPermissionsMock = LocationPermissionsMock(locationService: locationServiceMock)
        sut = DefaultVenuesViewModel(
            networkService: networkServiceMock,
            locationPermissions: locationPermissionsMock,
            locationService: locationServiceMock,
            distanceRange: rangeDistance,
            pageSize: 1
        )
    }

    override func tearDown()  {
        networkServiceMock = nil
        locationServiceMock = nil
        locationPermissionsMock = nil
        sut = nil
    }
    
    func test_venues_initialValue_isEmpty() {
      XCTAssertTrue(
            sut?.venues.isEmpty == true,
            "Expected initial value to be empty"
      )
    }
    
    func test_updateRadius_shouldHaveCorrectRange() {
        let stub: Float = 0.5
        let expectation = Int(stub * rangeDistance).toDistanceString()
        
        sut?.radius = stub
        XCTAssertTrue(
            sut?.currentSearchRadiusText().contains(expectation) == true,
            "Expected 'Search Radius Text' to contain the range"
        )
    }
    
    func test_noLocation_shouldUpdateTitle() {
        XCTAssertEqual(sut?.title, Constants.VenuesSearch.searchGpsTitle)
    }
    
    func test_locationPermission_isRequested() {
        let expectation = XCTestExpectation(description: "LocationPermission is requested")

        locationPermissionsMock.status
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_locationService_isReady() {
        let expectation = XCTestExpectation(description: "LocationService is ready")

        locationServiceMock.state
            .sink { state in
                XCTAssertTrue(state == .ready)
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_locationUpdate_triggersNewRequest() {
        let expectation = XCTestExpectation(description: "Location update triggers a new request")
        
        let radiusExpected = Int((sut?.radius ?? 0) * rangeDistance)
        let stub = LocationServiceMock.stub
        
        networkServiceMock.lastRoute = { route in
            XCTAssertEqual(route.parameters["radius"] as? Int, radiusExpected)
            XCTAssertEqual(
                route.parameters["ll"] as? String,
                stub.coordinate.toParamString()
            )
            expectation.fulfill()
        }
        
        locationServiceMock.locationSubject.send(stub)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_venuesAndTitle_areUpdated_forLocation() {
        let expectation = XCTestExpectation(description: "Venues and screen title are updated on location change")
        
        let stub = LocationServiceMock.stub
        sut?.$venues
            .dropFirst(1)
            .sink { [weak self] venues in
                XCTAssertEqual(venues.count, NetworkServiceMock.stub.response.venues.count)
                XCTAssertEqual(self?.sut?.title, Constants.VenuesSearch.venuesTitle)
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        locationServiceMock.locationSubject.send(stub)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_venues_areFiltered_basedOnRange() {
        let expectation = XCTestExpectation(description: "Venues are filtered based on range")
        
        /// Forcing a request with 2 results
        networkServiceMock.requestResult = Result<Any, ServerErrorState>
            .success(NetworkServiceMock.stubList)
            .publisher
            .eraseToAnyPublisher()
        
        let stub = LocationServiceMock.stub
        sut?.$venues
            .dropFirst(1)
            .sink { venues in
                XCTAssertEqual(venues.count, 1, "Expecting 1 venue to be filtered by range")
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        locationServiceMock.locationSubject.send(stub)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_onRetry_willRepeatSameRequest() {
        let expectation = XCTestExpectation(description: "On retry should request using the same params")

        let stub = LocationServiceMock.stub
        
        var runCount = 2
        networkServiceMock.lastRoute = { [weak self] route in
            runCount -= 1
            if runCount == 1 {
                self?.sut?.onRetrySearch()
            }
            if runCount == 0 {
                expectation.fulfill()
            }
        }
        
        locationServiceMock.locationSubject.send(stub)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    func test_requestError_willUpdateUI() {
        let expectation = XCTestExpectation(description: "On retry should request using the same params")

        let locationStub = LocationServiceMock.stub
        let errorStub = ServerErrorState.serverError
        
        /// Forcing a request error
        networkServiceMock.requestResult = Result<Any, ServerErrorState>
            .failure(errorStub)
            .publisher
            .eraseToAnyPublisher()
        
        sut?.$error
            .dropFirst()
            .sink(receiveValue: { error in
                XCTAssertEqual(error, errorStub)
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        locationServiceMock.locationSubject.send(locationStub)
        
        wait(for: [expectation], timeout: timeout)
    }
}
