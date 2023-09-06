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
    
    private let distanceRange: Float = 50
    
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
            scheduler: .immediate,
            distanceRange: distanceRange,
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
        let stubRadius: Float = 0.5
        let expectation = Int(stubRadius * distanceRange).toDistanceString()
        
        /// Update inputs
        sut?.radius = stubRadius
        
        /// Test outcomes
        XCTAssertTrue(
            sut?.currentSearchRadiusText().contains(expectation) == true,
            "Expected 'Search Radius Text' to contain the range"
        )
    }
    
    func test_noLocation_shouldUpdateTitle() {
        XCTAssertEqual(sut?.title, Constants.VenuesSearch.searchGpsTitle)
    }
    
    func test_locationPermission_isRequested() {
        XCTAssertEqual(locationPermissionsMock.statusSubject.value, .authorizedWhenInUse)
    }
    
    func test_locationUpdate_triggersNewRequest() {
        
        let radiusExpected = Int((sut?.radius ?? 0) * distanceRange)
        let stub = CLLocation.stub
        
        /// Update route
        var lastRoute: (any APIRoute)!
        networkServiceMock.lastRoute = { route in
            lastRoute = route
        }
        
        /// Update inputs
        locationServiceMock.locationSubject.send(stub)
        
        /// Test outcomes
        XCTAssertEqual(lastRoute.parameters["radius"] as? Int, radiusExpected)
        XCTAssertEqual(
            lastRoute.parameters["ll"] as? String,
            stub.coordinate.toParamString()
        )
    }
    
    func test_venuesAndTitle_areUpdated_forLocation() {
        
        let locationStub = CLLocation.stub
        let responseStub = ApiResponseBody.stub(ids: ["1", "2"])
        
        /// Forcing a request with 2 results
        networkServiceMock.requestResult = Result<Any, ServerErrorState>
            .success(responseStub)
            .publisher
            .eraseToAnyPublisher()
        
        /// Update inputs
        sut?.radius = 1
        locationServiceMock.locationSubject.send(locationStub)
        
        /// Test outcomes
        XCTAssertEqual(sut?.venues.count, responseStub.response.venues.count)
        XCTAssertEqual(sut?.title, Constants.VenuesSearch.venuesTitle)
    }
    
    func test_venues_areFiltered_basedOnRange() {
        
        let locationStub = CLLocation.stub
        let responseStub = ApiResponseBody.stub(ids: ["1", "2"])
        
        /// Forcing a request with 2 results
        networkServiceMock.requestResult = Result<Any, ServerErrorState>
            .success(responseStub)
            .publisher
            .eraseToAnyPublisher()
        
        /// Update inputs
        sut?.radius = 0.5 / distanceRange /// needs to be  <10m
        locationServiceMock.locationSubject.send(locationStub)
        
        XCTAssertEqual(sut?.venues.count, 1, "Expecting 1 venue to be filtered by range")
    }
    
    func test_onRetry_willRepeatSameRequest() {
        
        let stub = CLLocation.stub
        
        /// Count requests
        var runCount = 2
        networkServiceMock.lastRoute = { [weak self] route in
            runCount -= 1
            if runCount == 1 {
                self?.sut?.onRetrySearch()
            }
        }
        
        /// Update inputs
        locationServiceMock.locationSubject.send(stub)
        
        /// Test outcomes
        XCTAssertEqual(runCount, 0)
    }
    
    func test_requestError_willUpdateUI() {
        let locationStub = CLLocation.stub
        let errorStub = ServerErrorState.serverError
                
        /// Forcing a request error
        networkServiceMock.requestResult = Result<Any, ServerErrorState>
            .failure(errorStub)
            .publisher
            .eraseToAnyPublisher()
        
        /// Update inputs
        locationServiceMock.locationSubject.send(locationStub)
        
        /// Test outcomes
        XCTAssertEqual(sut?.error, ErrorMessage.customMessage(errorStub.localizedDescription))
    }
}
