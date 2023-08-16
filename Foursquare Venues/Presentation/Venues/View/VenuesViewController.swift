//
//  ViewController.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit
import Combine

class VenuesViewController: UIViewController {
    
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var distanceSlider: UISlider!
    @IBOutlet private weak var tableView: UITableView!
    
    private let viewModel: VenuesViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: VenuesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Maybe moved to a subclass?
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Venues around you" // Localization?
        
        configureTableView()
        configureDistanceSlider()
        subscribeForUpdates()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.register(VenueTableViewCell.self)
    }
    
    private func configureDistanceSlider() {
        distanceSlider.value = viewModel.getCurrentSearchRadius()
        distanceLabel.text = viewModel.getCurrentSearchRadiusText()
    }
    
    private func subscribeForUpdates() {
        viewModel
            .venues
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Actions

extension VenuesViewController {
    @IBAction private func sliderAction(_ sender: UISlider) {
        viewModel.updateSearchRadius(sender.value)
    }
}


// MARK: - UITableViewDataSource

extension VenuesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfVenues()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VenueTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let venue = viewModel.venueAt(index: indexPath.row)
        cell.configure(with: venue)
        return cell
    }
}
