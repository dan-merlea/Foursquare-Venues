//
//  ViewBuilder.swift
//  FoursquareVenues
//
//  Created by Dan Merlea on 03.09.2023.
//

import UIKit

protocol ViewBuilder {
    func build(resolver: DIResolver) -> UIViewController
}
