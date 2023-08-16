//
//  ViewController.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

class VenuesViewController: UIViewController {
    
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var distanceSlider: UISlider!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Venues around you" // Localization?
        
        configureTableView()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: VenueTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: VenueTableViewCell.self))
    }
}

// MARK: -

extension VenuesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VenueTableViewCell.self), for: indexPath)
        if let cell = cell as? VenueTableViewCell {
            cell.configure()
        }
        return cell
    }
}
