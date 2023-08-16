//
//  VenueTableViewCell.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

final class VenueTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    
    func configure() {
        titleLabel.text = "Title"
        categoryLabel.text = "Category"
        addressLabel.text = "Address"
        distanceLabel.text = "Distance"
    }
    
}
