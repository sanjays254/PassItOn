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
    var selectedCategories: Array<ItemCategory>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView =  UITableView()

        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        //categoryTableView.allowsMultipleSelection = true
        selectedCategories = []
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ItemCategory.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCategoryCellID")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCategoryCellID")!
        cell.textLabel?.text = ItemCategory.stringValue(index: indexPath.row)
     
     return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // let cell = categoryTableView.dequeueReusableCell(withIdentifier: "filterCategoryCellID")!
        
        ReadFirebaseData.readOffers(category: ItemCategory.enumName(index:indexPath.row))
        ReadFirebaseData.readRequests(category: ItemCategory.enumName(index:indexPath.row))
    
        dismissFilterTableView()
    }

    
    func dismissFilterTableView(){
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            
        }, completion: {(finished: Bool) in
            
            self.willMove(toParentViewController: nil)
            let theParentViewController = self.parent as! HomeViewController
            theParentViewController.filterContainerView.removeFromSuperview()
  
            //self.itemDetailView.removeFromSuperview()
            self.removeFromParentViewController()
            
        })
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
