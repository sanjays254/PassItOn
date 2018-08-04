//
//  PostViewController+CategoryChooser.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension PostViewController {
    
    @IBAction func openCategories(_ sender: UIButton) {
        
        self.view.addSubview(categoryTableView)
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.view.bringSubview(toFront: categoryTableView)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //category chooser tableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: cellID)!
        cell.textLabel?.text = ItemCategory.stringValue(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        self.addCategoryButton.setTitle("Category: \(cell.textLabel?.text ?? "Unknown")", for: UIControlState.normal)
        chosenCategory = ItemCategory.enumName(index: indexPath.row)
        self.navigationController?.navigationBar.isHidden = false
        categoryTableView.removeFromSuperview()
    }
    
    
    
    
}
