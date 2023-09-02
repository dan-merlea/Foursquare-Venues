//
//  VenueListView.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 02.09.2023.
//

import SwiftUI

struct VenueListView: View {
    
    @Binding var venues: [Venue]
    
    var body: some View {
        List($venues, id: \.id) { venue in
            VenueView(venue: venue)
        }
        .listStyle(.plain)
    }
}

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        VenueListView(venues: .constant([
            Venue(id: "id", name: "Demo title 1", location: VenueLocation(address: "Address", distance: 120), categories: [VenueCategory(name: "Category", shortName: "Cat", icon: VenueCategoryIcon(prefix: "url", suffix: "png"))]),
            Venue(id: "id", name: "Demo title 2", location: VenueLocation(address: "Address", distance: 120), categories: [VenueCategory(name: "Category", shortName: "Cat", icon: VenueCategoryIcon(prefix: "url", suffix: "png"))])
        ]))
    }
}
