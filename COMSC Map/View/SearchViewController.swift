//
//  SearchViewController.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 27/08/2023.
//

import UIKit
//import MapboxSearchUI
import NMAKit

class SearchViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    var delegate: SearchResultDelegate!
//    var addressAutofill = AddressAutofill()
//    var cachedSuggestions: [AddressAutofill.Suggestion] = []
//    var placeAutocomplete = PlaceAutocomplete()
    var cachedSuggestions: [NMALink] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cachedSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "suggestion-tableview-cell"
        
        let tableViewCell: UITableViewCell
        if let cachedTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            tableViewCell = cachedTableViewCell
        } else {
            tableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        tableViewCell.backgroundColor = .clear
        if let suggestion = cachedSuggestions[indexPath.row] as? NMAPlaceLink {
            
            
            tableViewCell.textLabel?.text = suggestion.name
            tableViewCell.textLabel?.textColor = .black
            tableViewCell.accessoryType = .disclosureIndicator

            tableViewCell.detailTextLabel?.text = suggestion.vicinityDescription?.replacingOccurrences(of: "<br/>", with: " ")
            tableViewCell.detailTextLabel?.textColor = UIColor.darkGray
            tableViewCell.detailTextLabel?.numberOfLines = 3
            
        }

        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedRow = cachedSuggestions[indexPath.row] as? NMAPlaceLink {
            self.delegate.searchViewDidSelectResult(selectedRow)
            self.dismiss(animated: true, completion: nil)
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}

// MARK: - Private
extension SearchViewController {
    func reloadData() {
        tableView.isHidden = cachedSuggestions.isEmpty
        tableView.reloadData()
    }

}
