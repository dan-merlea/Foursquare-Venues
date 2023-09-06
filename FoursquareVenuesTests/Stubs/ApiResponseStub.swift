//
//  ApiResponseStub.swift
//  FoursquareVenuesTests
//
//  Created by Dan Merlea on 06.09.2023.
//

import Foundation
@testable import FoursquareVenues

extension ApiResponseBody {
    
    /**
      Distance is increased by 10 for each id
     */
    static func stub(ids: [String]) -> ApiResponseBody {
        ApiResponseBody(
            response:
                Response(venues: ids.enumerated().map { (index, value) in
                    Venue(
                        id: value,
                        name: "Name",
                        location: VenueLocation(address: "Address", distance: 10 * index),
                        categories: [
                            VenueCategory(name: "Name", shortName: "ShortName", icon: VenueCategoryIcon(prefix: "prefix", suffix: "suffix"))
                        ]
                    )
                } )
        )
    }
}
