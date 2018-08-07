//
//  HomeViewController+Search.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-04.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController {
    
    
    func setupSearchBar(){
        
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        filteredOfferedItems = []
        filteredRequestedItems = []
    }
    
    
    func setupSearchButton(){
        
        let searchButton  = UIButton(type: .system)
        let searchImage = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        
        searchButton.setImage(searchImage, for: .normal)
        
        searchButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        searchButton.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        searchButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        self.navigationItem.leftBarButtonItem = searchBarButton
        
    }
    
    @objc func searchButtonAction(){
        
        view.bringSubview(toFront: searchBar)
        
        if (searchBarHeightConstraint.constant == 45){
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBarHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: {(finished: Bool) in
                self.searchBar.resignFirstResponder()
            })
        }
            
        else if (searchBarHeightConstraint.constant == 0){
            
            UIView.animate(withDuration: 0.5, animations: {
                self.searchBarHeightConstraint.constant = 45
                
                self.view.layoutIfNeeded()
                
            }, completion: {(finished: Bool) in
                self.searchBar.becomeFirstResponder()
            })
        }
    }
    
    //searchBar delegate methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        indexPathSelected = nil
        indexPathPreviouslySelected = nil
        
        searchActive = true;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        filteredOfferedItems = []
        filteredRequestedItems = []
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = false
        homeTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchApplied = true
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        searchThroughData(searchText: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchApplied = true
        
        filteredOfferedItems = []
        filteredRequestedItems = []
        
        
        if (searchBar.text == ""){
            searchApplied = false
        }
        
        searchThroughData(searchText: searchText)
        
    }
    
    
    
    
    func searchThroughData(searchText: String) {
        
        var containsTag: Bool = false
        
        for item in AppData.sharedInstance.onlineOfferedItems {
            
            if (item.name.lowercased().contains(searchText.lowercased())){
                filteredOfferedItems.append(item)
            }
            
            for tag in item.tags.tagsArray {
                if (tag.lowercased().contains(searchText.lowercased())){
                    containsTag = true
                }
                else { containsTag = false }
                
                
                if (containsTag == true) {
                    if !(filteredOfferedItems.contains(item)){
                        filteredOfferedItems.append(item)
                    }
                    
                    break
                }
            }
        }
        
        containsTag = false
        
        for item in AppData.sharedInstance.onlineRequestedItems {
            
            if (item.name.lowercased().contains(searchText.lowercased())){
                filteredRequestedItems.append(item)
            }
            
            for tag in item.tags.tagsArray {
                if (tag.lowercased().contains(searchText.lowercased())){
                    containsTag = true
                }
                else { containsTag = false }
                
                
                if (containsTag == true) {
                    if !(filteredRequestedItems.contains(item)){
                        filteredRequestedItems.append(item)
                    }
                    break
                }
            }
        }
        
        searchActive = true
        self.homeTableView.reloadData()
        removeAndAddAnnotations()
    }
    
    
    
}
