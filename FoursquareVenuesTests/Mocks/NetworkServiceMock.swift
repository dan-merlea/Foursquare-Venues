//
//  NetworkServiceMock.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 03.09.2023.
//

import Foundation
import Combine
@testable import FoursquareVenues

class NetworkServiceMock: NetworkService {
    
    var requestResult = Result<Any, ServerErrorState>
        .success(ApiResponseBody.stub(ids: ["1"]))
        .publisher
        .eraseToAnyPublisher()
    
    var lastRoute: ((any APIRoute) -> Void)?
    
    func request<T>(route: T) -> AnyPublisher<T.Response, ServerErrorState> where T : APIRoute {
        lastRoute?(route)
        return requestResult
            .map { $0 as! T.Response }
            .eraseToAnyPublisher()
    }
}
