//
//  FilterTableViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-29.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit




class FilterTableViewController: UITableViewController {

    var categoryTableView: UITableView!
    var filterNotificationDelegate: FilterNotificationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select A Category"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIProperties.sharedUIProperties.lightGreenColour]
        
        categoryTableView =  UITableView()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemCategory.count+1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCategoryCellID")
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCategoryCellID")!
        
        if(indexPath.row == 0){
            cell.textLabel?.text = "All"
        }
        else {
            cell.textLabel?.text = ItemCategory.stringValue(index: indexPath.row-1)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentNonRequestedAlert), name: NSNotification.Name(rawValue: NotificationKeys.shared.noRequestsDownloadedInThisCategoryKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentNonAvailableAlert), name: NSNotification.Name(rawValue: NotificationKeys.shared.noOffersDownloadedInThisCategoryNotificationKey), object: nil)
        
                    if(indexPath.row == 0){
                        
                        filterNotificationDelegate.filterApplied()
                        filterNotificationDelegate.setNotificationsFromDelegator(category: nil)
                        
                        ReadFirebaseData.readOffers(category:nil)
                        ReadFirebaseData.readRequests(category: nil)
                        
                    }
                    else {
                        
                        filterNotificationDelegate.filterApplied()
                        filterNotificationDelegate.setNotificationsFromDelegator(category: ItemCategory.enumName(index:indexPath.row-1))
                        
                        ReadFirebaseData.readOffers(category: ItemCategory.enumName(index:indexPath.row-1))
                        
                        ReadFirebaseData.readRequests(category: ItemCategory.enumName(index:indexPath.row-1))
 
                    }

        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func presentNonAvailableAlert(){

        let noValuesAlert = UIAlertController(title: "No items!", message: "Nothing is available in this category, but there may be some requests", preferredStyle: UIAlertControllerStyle.alert)

        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)

        noValuesAlert.addAction(okayAction)
        present(noValuesAlert, animated: true, completion: nil)

    }

    @objc func presentNonRequestedAlert(){

        let noValuesAlert = UIAlertController(title: "No items!", message: "Nothing is requested for in this category, but there may be something available", preferredStyle: UIAlertControllerStyle.alert)

        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)

        noValuesAlert.addAction(okayAction)
        present(noValuesAlert, animated: true, completion: nil)

    }

}
