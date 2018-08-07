//
//  ReadFirebaseData.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-18.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation


class ReadFirebaseData: NSObject {
    
    //get all offers
    class func readOffers(category:ItemCategory?) {
        
        var ref:DatabaseReference
        
        //if category not specified, ref should be entire offers node
        if let category = category {
            ref = AppData.sharedInstance.offersNode.child("\(category.rawValue)")
            
        }
        else {
            ref = AppData.sharedInstance.offersNode
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
        
                AppData.sharedInstance.onlineOfferedItems.removeAll()
            
                //if no category filter applied, loop through all categories
                if category == nil {
                    for thisCategory in value {
                        print("\n\n\(thisCategory.key)")
                        let data = thisCategory.value as! [String:Any]
                    
                        readOffer(data: data)
                    }
                }
                else {
                    if let data = value as? [String:Any] {
                        readOffer(data: data)
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.offersDownloadedNotificationKey), object: nil)
                
            }
                
            else {
               
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.noOffersDownloadedInThisCategoryNotificationKey), object: nil)
                    
                    
                //NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.offersDownloadedNotificationKey), object: nil)

            }
        })
        

    }
    
    
    //get all requested items
    class func readRequests(category:ItemCategory?) {
        
        var ref:DatabaseReference
        
        //if category not specified, ref should be entire offers node
        if let category = category {
            ref = AppData.sharedInstance.requestsNode.child("\(category.rawValue)")
        }
        else {
            ref = AppData.sharedInstance.requestsNode
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary {
        
            
                AppData.sharedInstance.onlineRequestedItems.removeAll()
            
                //if no category filter applied, loop through all categories
                if category == nil {
                    for thisCategory in value {
                        print("\n\n\(thisCategory.key)")
                        if let data = thisCategory.value as? [String:Any] {
                  
                            readRequest(data: data)
                        }
                    }
                }
                
                else {
                    if let data = value as? [String:Any] {
                        readRequest(data: data)
                
                    }
                }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.requestsDownloadedNotificationKey), object: nil)
            }
            
            else {
               
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.noRequestsDownloadedInThisCategoryKey), object: nil)
      
                  //  NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.requestsDownloadedNotificationKey), object: nil)
                
            }
            
        })
    }
    

    
    fileprivate class func readOffer(data:[String:Any]) {
        for any in data {
            if let item: [String:Any] = any.value as? [String:Any],
             let readItem = Item(with: item) {
                if (!AppData.sharedInstance.onlineOfferedItems.contains(readItem)){
                    AppData.sharedInstance.onlineOfferedItems.append(readItem)
                }
                else {
                    print("item has already been added")
                }
                
               
            }
            else {
                print("An offered item was returned as nil")
                
            }
        }
    }
    
    fileprivate class func readRequest(data:[String:Any]) {
   
        for any in data {
            if let item: [String:Any] = any.value as? [String:Any],
                let readItem = Item(with: item) {
           
                 if (!AppData.sharedInstance.onlineRequestedItems.contains(readItem)){
                    AppData.sharedInstance.onlineRequestedItems.append(readItem)
                
                }
                 else {
                    print("item has already been added")
                }
            }
            else {
                print("A requested item was returned as nil")
            }
            
        }
    }
    
    
    class func storeCurrentUsersItems(userUID:String){
        
        AppData.sharedInstance.currentUserOfferedItems = []
        AppData.sharedInstance.currentUserRequestedItems = []
       
        for itemRef in (AppData.sharedInstance.currentUser?.offeredItems)! {
            
            
            let ref:DatabaseReference = Database.database().reference().child(itemRef)
        
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? NSDictionary{
            
                let item: [String:Any] = value as! [String:Any]
                
                let readItem = Item(with: item)
                
                if readItem != nil {
                    if (!AppData.sharedInstance.currentUserOfferedItems.contains(readItem!)){
                        AppData.sharedInstance.currentUserOfferedItems.append(readItem!)
                       
                    }
                    else {
                        print("item has already been added")
                    }
                    
                    
                }
                }
                else {
                    //remove itemRef from my refs
                    if let itemRefToRemoveIndex = AppData.sharedInstance.currentUser?.offeredItems.index(of:itemRef) {
                        AppData.sharedInstance.currentUser?.offeredItems.remove(at: itemRefToRemoveIndex)
                        
                        WriteFirebaseData.write(user: AppData.sharedInstance.currentUser!, completion: { (success) in
                            
                            print("user was updated")
                            
                            })
                    }
                    
                    
                }
         
            })
        }
        
        for itemRef in (AppData.sharedInstance.currentUser?.requestedItems)! {
            
            let ref:DatabaseReference = Database.database().reference().child(itemRef)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? NSDictionary {
                
                let item: [String:Any] = value as! [String:Any]
                
                let readItem = Item(with: item)
                
                if let readItem = readItem {
                    if (!AppData.sharedInstance.currentUserRequestedItems.contains(readItem)){
                        AppData.sharedInstance.currentUserRequestedItems.append(readItem)
                        print("appending offered items")
                    }
                    else {
                        print("item has already been added")
                    }
                    
                    
                }
                }
                else {
                    //remove itemRef from my refs
                    if let itemRefToRemoveIndex = AppData.sharedInstance.currentUser?.requestedItems.index(of:itemRef) {
                        AppData.sharedInstance.currentUser?.requestedItems.remove(at: itemRefToRemoveIndex)
                        
                        WriteFirebaseData.write(user: AppData.sharedInstance.currentUser!, completion: { (success) in
                            
                            print("user was updated")
                            
                        })
                    }
                }
                
            })
            
        }
    }
}
