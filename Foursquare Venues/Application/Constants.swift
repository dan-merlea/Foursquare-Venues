//
//  Constants.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

/**
 Used API V2 with some keys found on Github as I could not create a developer account - bug on their side
 https://location.foursquare.com/developer/reference/v2-venues-search
 */

import Foundation

struct Constants {
    
    struct Foursquare {
        let api = "api.foursquare.com"
        let version = "20191001"
        let pageSize = 50
        
        @SecuredConfig("ClientId")
        var clientId: String
        
        @SecuredConfig("ClientSecret")
        var clientSecret: String
    }
}
