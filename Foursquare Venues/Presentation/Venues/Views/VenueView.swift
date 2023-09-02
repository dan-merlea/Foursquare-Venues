//
//  VenueView.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 02.09.2023.
//

import SwiftUI

struct VenueView: View {
    
    @Binding var venue: Venue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(venue.name)
                    .font(Font.headline)
                Text(venue.categories.map { $0.name }.joined(separator: "\u{2022}"))
                Text(venue.location.address ?? "")
            }
            Spacer()
            Text(venue.location.distance.toDistanceString())
                .foregroundColor(.secondary)
        }
        .padding(8)
    }
}

struct VenueView_Previews: PreviewProvider {
    static var previews: some View {
        VenueView(venue: .constant(Venue(id: "id", name: "Demo title", location: VenueLocation(address: "Address", distance: 120), categories: [VenueCategory(name: "Category", shortName: "Cat", icon: VenueCategoryIcon(prefix: "url", suffix: "png"))])))
    }
}
