//
//  SearchResultsTableTableViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-21.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit


class SearchResultsTableViewController: UITableViewController {
    
    public var searchResults: [MKLocalSearchCompletion]!
    
    public var placeToSearch: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.searchResults = [MKLocalSearchCompletion]()
        
    }
    
    
    //auto-complete table View methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        placeToSearch = searchResults[indexPath.row].title
        dismiss(animated: true, completion: nil)
        PostMapViewController.locationPlotter()
    }
    

}

