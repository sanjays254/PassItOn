//
//  WriteFirebaseData.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-27.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import Firebase


class WriteFirebaseData {
    
    class func write(item:Item, type:Int) {
        let user = AppData.sharedInstance.currentUser!
        print("# of offered items: \(user.offeredItems.count), # of requested items: \(user.requestedItems.count)")
        let itemPath:String = "\(item.itemCategory.rawValue)/\(item.UID!)"

        
        switch type {
        case 0:
            AppData.sharedInstance.offersNode.child(itemPath).setValue(item.toDictionary())
            if AppData.sharedInstance.currentUser!.offeredItems.first == "" {
                AppData.sharedInstance.currentUser!.offeredItems.remove(at: 0)
            }
            AppData.sharedInstance.currentUser!.offeredItems.append(itemPath)
            break
        case 1:
            AppData.sharedInstance.requestsNode.child(itemPath).setValue(item.toDictionary())
            if AppData.sharedInstance.currentUser!.requestedItems.first == "" {
                AppData.sharedInstance.currentUser!.requestedItems.remove(at: 0)
            }
            AppData.sharedInstance.currentUser!.requestedItems.append(itemPath)
            break
        default:
            print("Error: Invalid argument passed for 'type'")
            return
        }
        

        
        
        print("# of offered items: \(user.offeredItems.count), # of requested items: \(user.requestedItems.count), itemPath: \(itemPath)")
        AppData.sharedInstance.usersNode.child(user.UID).setValue(AppData.sharedInstance.currentUser?.toDictionary())
    }
    
}
