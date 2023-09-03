//
//  SecureConfig.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 03.09.2023.
//

import Foundation

@propertyWrapper
struct SecuredConfig {
    
    var key: String
    var value: String = ""
    
    init(_ value: String) {
        self.key = value
    }
    
    var wrappedValue: String {
        get {
            return readConfig(key: key)
        }
        set {
            value = newValue
        }
    }
    
    private func readConfig(key: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "ApiConfig", ofType: "plist") else {
            fatalError("Couldn't find file 'ApiConfig.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'ApiConfig.plist'.")
        }
        return value
    }
}
