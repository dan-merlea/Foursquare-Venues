//
//  ErrorMessage.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 06.09.2023.
//

enum ErrorMessage: Hashable, Identifiable {
    case customMessage(String)
    case locationDenied
    
    var localizedDescription: String {
        switch self {
        case .customMessage(let message):
            return message
        case .locationDenied:
            return "In order to use the app, go to Settins and allow using location for this application."
        }
    }
        
    var id: Self {
        return self
    }
}
