//
//  SpinnerManager.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 21/08/2023.
//

import Foundation
import UIKit

class SpinnerManager {
    static let shared = SpinnerManager()
    
    private var currentView: UIView!
    private var spinner: UIActivityIndicatorView?

    private init() {
        setupSpinner()
    }

    private func setupSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner?.color = .black
        spinner?.hidesWhenStopped = true
    }

    func startSpinner(in view: UIView) {
        guard let spinner = self.spinner else { return }
        currentView = view
        spinner.center = currentView.center
        currentView.addSubview(spinner)
        spinner.startAnimating()
        
    }

    func stopSpinner() {
        guard let spinner = self.spinner else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        currentView.isUserInteractionEnabled = true
    }
}
