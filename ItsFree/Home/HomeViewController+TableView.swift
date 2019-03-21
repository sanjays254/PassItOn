//
//  HomeViewController+TableView.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-04.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

extension HomeViewController {
    
    func sortTableView()
    {
        AppData.sharedInstance.onlineOfferedItems.sort(by:
            { $0.distance(to: getLocation()) < $1.distance(to: getLocation())})
        
        AppData.sharedInstance.onlineRequestedItems.sort(by:
            { $0.distance(to: getLocation()) < $1.distance(to: getLocation())})
        
        self.homeTableView.reloadData();
    }
    
    
    @objc func refreshTableData(sender: AnyObject) {
        
        if((self.homeTableView.refreshControl) != nil){
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            let title = String("Last update: \(dateFormatter.string(from: Date()))")
            let attributesDict = [NSAttributedStringKey.foregroundColor: UIColor.white]
            let attributedTitle = NSAttributedString(string: title, attributes: attributesDict)
            self.homeTableView.refreshControl?.attributedTitle = attributedTitle
        }
        
        setupItemsDownloadNotifications()
        
        ReadFirebaseData.readOffers(category: currentCategory)
        ReadFirebaseData.readRequests(category: currentCategory)
        
        self.homeTableView.refreshControl?.endRefreshing()
    }
    
    //tableView Delegate methods

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            if(searchApplied == true) {
                return filteredRequestedItems.count
            }
            else {
                return AppData.sharedInstance.onlineRequestedItems.count
            }
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            if(searchApplied == true) {
                return filteredOfferedItems.count
            }
            else {
                return AppData.sharedInstance.onlineOfferedItems.count
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //if some cell is selected, make it an expanded cell
        if (indexPathSelected == indexPath){
            //force unwrap okay, because selected indexpath exists when row is selected
          //  indexPathSelected
            
                let cell = generateExpandedCell(indexPath: indexPath)
            
            
            
                return cell
            }
    
        //change the previously selected cell back to a default cell
        if (indexPathPreviouslySelected == indexPath) {
    
            let cell = generateDefaultCell(indexPath: indexPath)
    
            return cell
            
        }
        
        //in cases where no cells have been selected, make them all default
  
            
        let cell = generateDefaultCell(indexPath: indexPath)
            
        return cell
        
        
 
    }
    func generateExpandedCell(indexPath: IndexPath) -> UITableViewCell {
        
        let cell = homeTableView.dequeueReusableCell(withIdentifier: "itemHomeDetailTableViewCellID") as! ItemDetailHomeTableViewCell
        
        cell.itemActionDelegate = self
        cell.homeVC = self
        cell.homeMapDelegate = self
        
   
        
        var sourceArray:[Item]!
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            
            if(searchApplied == true){
                sourceArray = filteredRequestedItems
                
            }
            else {
                sourceArray = AppData.sharedInstance.onlineRequestedItems
            }
            
            populateExpandedCellLabelsAndImage(cell: cell, indexPath: indexPath, sourceArray: sourceArray)
            
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            
            if(searchApplied == true){
                sourceArray = filteredOfferedItems
            }
            else {
                sourceArray = AppData.sharedInstance.onlineOfferedItems
            }
            
            populateExpandedCellLabelsAndImage(cell: cell, indexPath: indexPath, sourceArray: sourceArray)
        }
        
        return cell
        
    }
    
    func generateDefaultCell(indexPath: IndexPath) -> UITableViewCell{
        
        let cell = homeTableView.dequeueReusableCell(withIdentifier: "itemHomeTableViewCellID") as! ItemHomeTableViewCell
        
        var sourceArray:[Item]!
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            
            if(searchApplied == true){
                sourceArray = filteredRequestedItems
                
            }
            else {
                sourceArray = AppData.sharedInstance.onlineRequestedItems
            }
            
            populateDefaultCellLabelsAndImage(cell: cell, indexPath: indexPath, sourceArray: sourceArray)

        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            
            if(searchApplied == true){
                sourceArray = filteredOfferedItems
            }
            else {
                sourceArray = AppData.sharedInstance.onlineOfferedItems
            }
            
            populateDefaultCellLabelsAndImage(cell: cell, indexPath: indexPath, sourceArray: sourceArray)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if were selecting an expanded row, collapse it
        if(indexPathSelected == indexPath){
            collapseRow(indexPath: indexPath)
            indexPathPreviouslySelected = nil
        }
            //else if its already collapsed, expand it
        else {
            
            indexPathSelected = indexPath
            expandRow(indexPath: indexPath)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPathSelected == indexPath {
            return UITableViewAutomaticDimension
        } else {
            return 80
        }
    }
    
    func expandRow(indexPath: IndexPath){
        
       self.homeTableView.reloadRows(at: [indexPath], with: .automatic)
        
        if let indexPathPreviouslySelected = indexPathPreviouslySelected {
            if (indexPathPreviouslySelected != indexPath){
                expandPreviousRow(indexPath: indexPathPreviouslySelected)
            }
        }
        
        indexPathPreviouslySelected = indexPath
  
    }
    
    func expandPreviousRow(indexPath: IndexPath){
        
        indexPathPreviouslySelected = nil
        expandRow(indexPath: indexPath)
        
    }
    
    func collapseRow(indexPath: IndexPath) {
        
        indexPathSelected = nil
        self.homeTableView.reloadRows(at: [indexPath], with: .automatic)
     
        
    }
    
    func populateDefaultCellLabelsAndImage(cell: ItemHomeTableViewCell, indexPath: IndexPath, sourceArray: [Item]){
        
        
        let destinationLocation: CLLocation = CLLocation(latitude: sourceArray[indexPath.row].location.latitude, longitude: sourceArray[indexPath.row].location.longitude)
        
        let distance = (destinationLocation.distance(from: getLocation())/1000)
        
        cell.itemTitleLabel.text = sourceArray[indexPath.row].name
        cell.itemQualityLabel.text = sourceArray[indexPath.row].quality.rawValue
        
        if (distance > 100){
            cell.itemDistanceLabel.text = ">100 kms"
        }
        else {
            cell.itemDistanceLabel.text = String(format: "%.1f", distance) + " kms"
        }
        
        cell.itemImageView.sd_setImage(with: storageRef.child(sourceArray[indexPath.row].photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
        
//        if(indexPath.row == sourceArray.count-1){
//            BusyActivityView.hide()
//        }
    }
    
    func populateExpandedCellLabelsAndImage(cell: ItemDetailHomeTableViewCell, indexPath: IndexPath, sourceArray: [Item]){
        
        cell.currentItem = sourceArray[indexPath.row]
        
        cell.setupCollectionView()
        
        ReadFirebaseData.readUserBasics(userUID: cell.currentItem.posterUID, completion: {(success, user) in
            
            DispatchQueue.main.async {
            
            if (success){
                //force unwrapping is okay here because user exists if success is true
                cell.posterNameLabel.text = "\(user!.name)"
                cell.posterRating.text = "\(user!.rating)"
                cell.messagePosterButton.isEnabled = true
                
                cell.poster = user!
            }
            else {
                cell.posterNameLabel.text = "Unknown Poster"
                cell.posterRating.text = "0"
                cell.messagePosterButton.isEnabled = false
                
            }
            }
            
        })
        
        
        
        let destinationLocation: CLLocation = CLLocation(latitude: sourceArray[indexPath.row].location.latitude, longitude: sourceArray[indexPath.row].location.longitude)
        
        let distance = (destinationLocation.distance(from: getLocation())/1000)
        
        cell.titleLabel.text = cell.currentItem.name
        cell.qualityLabel.text = cell.currentItem.quality.rawValue
        cell.descriptionLabel.text = cell.currentItem.itemDescription
        cell.descriptionLabel.sizeToFit()
        cell.setNeedsDisplay()
        
        //if its a request, the item has no value
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0) {
            cell.valueLabel.text = ""
        }
            //else it does
        else {
            cell.valueLabel.text = "$\(cell.currentItem.value)"
        }
        
        cell.posterNameLabel.text = "Loading..."
        cell.posterRating.text = "0"
        cell.messagePosterButton.isEnabled = false
        
        
        if (distance > 100){
            cell.distanceLabel.text = ">100 kms"
        }
        else {
            cell.distanceLabel.text = String(format: "%.1f", distance) + " kms"
        }
        
//        if(indexPath.row == sourceArray.count-1){
//            BusyActivityView.hide()
//        }
    
    }
    
    
}
