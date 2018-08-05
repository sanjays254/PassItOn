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
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "itemHomeDetailTableViewCellID") as! ItemDetailHomeTableViewCell
            
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
    
    func generateDefaultCell(indexPath: IndexPath) -> UITableViewCell{
        
        
        let cell = homeTableView.dequeueReusableCell(withIdentifier: "itemHomeTableViewCellID") as! ItemHomeTableViewCell
        let storageRef = Storage.storage().reference()
        var sourceArray:[Item]!
        
        if(wantedAvailableSegmentedControl.selectedSegmentIndex == 0){
            
            if(searchApplied == true){
                sourceArray = filteredRequestedItems
                
            }
            else {
                sourceArray = AppData.sharedInstance.onlineRequestedItems
            }
            
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
        }
        else if (wantedAvailableSegmentedControl.selectedSegmentIndex == 1){
            
            if(searchApplied == true){
                sourceArray = filteredOfferedItems
            }
            else {
                sourceArray = AppData.sharedInstance.onlineOfferedItems
            }
            
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
        
        
        
        
        
        //        var itemToShow: Item
        //
        //        switch(wantedAvailableSegmentedControl.selectedSegmentIndex){
        //
        //        case 0:  itemToShow = AppData.sharedInstance.onlineRequestedItems[indexPath.row]
        //        case 1:  itemToShow = AppData.sharedInstance.onlineOfferedItems[indexPath.row]
        //        default:
        //            return
        //
        //        }
        //
        //        if (searchApplied == true){
        //
        //            switch(wantedAvailableSegmentedControl.selectedSegmentIndex){
        //
        //            case 0:  itemToShow = filteredRequestedItems[indexPath.row]
        //            case 1:  itemToShow = filteredOfferedItems[indexPath.row]
        //            default:
        //                return
        //
        //            }
        //        }
        //
        //
        //        currentItemIndexPath = indexPath
        //        lastItemSelected = itemToShow
        //
        //        mapListSegmentedControl.selectedSegmentIndex = 0
        //        mapListSegmentedControl.sendActions(for: UIControlEvents.valueChanged)
        //
        //        homeMapView.selectAnnotation(itemToShow, animated: true)
        //
        //        let span = MKCoordinateSpanMake(0.007, 0.007)
        //
        //        homeMapView.setRegion(MKCoordinateRegionMake(itemToShow.coordinate, span) , animated: true)
        //
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPathSelected == indexPath {
            return 102
        } else {
            return 70
        }
    }
    
    func expandRow(indexPath: IndexPath){
        
      //  self.homeTableView.beginUpdates()

        
        self.homeTableView.reloadRows(at: [indexPath], with: .fade)
        
        if let indexPathPreviouslySelected = indexPathPreviouslySelected {
            if (indexPathPreviouslySelected != indexPath){
                expandPreviousRow(indexPath: indexPathPreviouslySelected)
            }
        }
        
        indexPathPreviouslySelected = indexPath
        //self.homeTableView.endUpdates()
    }
    
    func expandPreviousRow(indexPath: IndexPath){
        
        indexPathPreviouslySelected = nil
        expandRow(indexPath: indexPath)
        
    }
    
    func collapseRow(indexPath: IndexPath) {
        
        indexPathSelected = nil
        self.homeTableView.reloadRows(at: [indexPath], with: .fade)
     
        
    }
    
}
