//
//  NetworkService.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Foundation
import Combine

protocol NetworkService {
    func request<T: APIRoute>(route: T) -> AnyPublisher<T.Response, ServerErrorState> where T.Response: Decodable
}

final class DefaultNetworkService: NetworkService {
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: APIRoute>(route: T) -> AnyPublisher<T.Response, ServerErrorState> where T.Response: Decodable {
        guard let request = urlRequest(route: route) else {
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
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .mapError { error in
                ServerErrorState.decode(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    /// Create URL request
    private func urlRequest<T: APIRoute>(route: T) -> URLRequest? {
        guard let urlString = route.url() else {
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
