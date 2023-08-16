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
        tableView.register(VenueTableViewCell.self)
    }
}

// MARK: - Actions

extension VenuesViewController {
    @IBAction private func sliderAction(_ sender: UISlider) {
        print(sender.value)
    }
}


// MARK: - UITableViewDataSource

extension VenuesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VenueTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure()
        return cell
    }
}
