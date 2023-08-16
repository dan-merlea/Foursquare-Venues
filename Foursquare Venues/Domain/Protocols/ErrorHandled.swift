//
//  ErrorHandled.swift
//  Foursquare Venues
//
//  Created by Dan Merlea on 16.08.2023.
//

import UIKit

protocol ErrorHandled: UIViewController {
    func handle(_ error: ServerErrorState, retryBlock: @escaping () -> Void)
}


extension ErrorHandled {
    func handle(_ error: ServerErrorState, retryBlock: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "An error occured",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Retry",
            style: .default,
            handler: { _ in
                retryBlock()
            }
        ))

        present(alert, animated: true)
    }
}
