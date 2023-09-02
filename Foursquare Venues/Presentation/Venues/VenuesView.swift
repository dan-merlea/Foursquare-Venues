//
//  VenuesView.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 02.09.2023.
//

import SwiftUI

struct VenuesView<ViewModel>: View where ViewModel: VenuesViewModel {
    
    @StateObject private var viewModel: ViewModel
    
    init (viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.currentSearchRadiusText())
            Slider(value: $viewModel.radius)
            Spacer()
            VenueListView(venues: $viewModel.venues)
        }
        .padding()
        .navigationBarTitle(viewModel.title)
        .alert(item: $viewModel.error) { error in
            Alert(title: Text(error.localizedDescription),
                  primaryButton: .default(
                    Text("Retry"),
                    action: viewModel.onRetrySearch
                  ),
                  secondaryButton: .destructive(Text("Dismiss"))
            )
        }
    }
}

struct VenuesView_Previews: PreviewProvider {
    static let locationService = DefaultLocationService()
    static var previews: some View {
        VenuesView(viewModel: DefaultVenuesViewModel(
            networkService: DefaultNetworkService(),
            locationPermissions: LocationPermissions(locationService: locationService),
            locationService:locationService
        ))
    }
}
