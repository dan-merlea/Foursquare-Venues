//
//  NetworkService.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine

protocol NetworkService {
    func request<T>(route: APIRoute) -> AnyPublisher<T, ServerErrorState> where T: Codable
}

final class DefaultNetworkService: NetworkService {
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T>(route: APIRoute) -> AnyPublisher<T, ServerErrorState> where T: Codable {
        guard let request = getUrlRequest(route: route) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        return session
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard output.response is HTTPURLResponse else {
                    throw ServerErrorState.serverError
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                ServerErrorState.decode(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    /// Create URL request
    private func getUrlRequest(route: APIRoute) -> URLRequest? {
        guard let urlString = route.getUrl() else {
            return nil
        }
        
        var request = URLRequest(url: urlString)
        request.httpMethod = route.method.rawValue
        
        if let body = route.body, let jsonData = try? JSONEncoder().encode(body) {
            request.httpBody = jsonData
        }
        
        return request
    }
}
