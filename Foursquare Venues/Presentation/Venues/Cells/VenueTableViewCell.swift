//
//  VenueTableViewCell.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

final class VenueTableViewCell: UITableViewCell, NibLoadableView, ReusableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // not in scope: reset downloads & clear images
    }
    
    func configure(with venue: Venue) {
        titleLabel.text = venue.name
        categoryLabel.text = venue.categories.map { $0.name }.joined(separator: "\u{2022}") // bull ascii
        addressLabel.text = venue.location.address ?? ""
        distanceLabel.text = venue.location.distance.toDistanceString()
    }
    
}
