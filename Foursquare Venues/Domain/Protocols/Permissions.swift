//
//  Permissions.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import Combine

protocol Permissions: AnyObject {
    
    associatedtype Status

    var status: AnyPublisher<Status, Never> { get }

    func request()
}
