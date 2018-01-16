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
    
    static var offersHandle:UInt? = nil
    static var requestsHandle:UInt? = nil
    
    //get all offered items
    class func readOffers(category:ItemCategory?) {
        if ( Auth.auth().currentUser == nil)
        {
            return
        }
        
        var ref:DatabaseReference
        if category == nil {
            ref = AppData.sharedInstance.offersNode
        }
        else {
            ref = AppData.sharedInstance.offersNode.child("\(category!.rawValue)")
        }
        let tempHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if ( value == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "noOfferedItemsInCategoryKey"), object: nil)
                return
            }
            AppData.sharedInstance.onlineOfferedItems.removeAll()
            
            //if no category filter applied**
            if category == nil {
                for thisCategory in value! {
                    print("\n\n\(thisCategory.key)")
                    let data = thisCategory.value as! [String:Any]
                    
                    readOffer(data: data)
                }
            }
            else {
                let data = value as? [String:Any]
                readOffer(data: data!)
            }
            let myDownloadNotificationKey = "myDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
            
            let myOffersDownloadNotificationKey = "myOffersDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myOffersDownloadNotificationKey), object: nil)
        })
        
        if offersHandle != nil {
            ref.removeObserver(withHandle: offersHandle!)
        }
        offersHandle = tempHandle
        
    }
    
    //get all requested items
    class func readRequests(category:ItemCategory?) {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        var ref:DatabaseReference
        if category == nil {
            ref = AppData.sharedInstance.requestsNode
        }
        else {
            ref = AppData.sharedInstance.requestsNode.child("\(category!.rawValue)")
        }
        
        let tempHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if ( value == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "noRequestedItemsInCategoryKey"), object: nil)
                return
            }
            
            AppData.sharedInstance.onlineRequestedItems.removeAll()
            
            //if no category filter applied**
            if category == nil {
                for thisCategory in value! {
                    print("\n\n\(thisCategory.key)")
                    let data = thisCategory.value as! [String:Any]
                    print(data)
                    readRequest(data: data)
                }
            }
            else {
                let data = value as? [String:Any]
                readRequest(data: data!)
            }
            let myDownloadNotificationKey = "myDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
            
            let myRequestsDownloadNotificationKey = "myRequestsDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myRequestsDownloadNotificationKey), object: nil)
        })
        if requestsHandle != nil {
            ref.removeObserver(withHandle: requestsHandle!)
        }
        requestsHandle = tempHandle
    }
    
    //get all users
    class func readUsers() {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        AppData.sharedInstance.onlineUsers.removeAll()        
        AppData.sharedInstance.usersNode
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                if ( value == nil) {
                    return
                }
                
                for any in (value?.allValues)! {
                    let user: [String:Any] = any as! [String:Any]
                    let ratingInt = user["rating"] as! NSNumber
                    var readUserOffers: Array<Any> = user["offers"] as! Array<Any>
                    var index = 0
                    for i in readUserOffers{
                    
                        if(i is NSNull){
                            readUserOffers.remove(at: index)
                        }
                        else {
                        index = index+1
                        }
                    }
                    
                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: readUserOffers as! [String], requests: (user["requests"] ?? [""]) as! Array)
                    
//                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: [""] as! Array, requests: (user["requests"] ?? [""]) as! Array)
                    
                    AppData.sharedInstance.onlineUsers.append(readUser)
                    print("appending items")
                }
                let myDownloadNotificationKey = "myDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
                
                let myUsersDownloadNotificationKey = "myUsersDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myUsersDownloadNotificationKey), object: nil)
            })
    }
    
    fileprivate class func readOffer(data:[String:Any]) {
        for any in data {
            let item: [String:Any] = any.value as! [String:Any]
            let readItem = Item(with: item)
            if readItem != nil {
                AppData.sharedInstance.onlineOfferedItems.append(readItem!)
                print("appending offered items")
            }
            else {
                print("Nil found in offered items")
            }
        }
    }
    
    fileprivate class func readRequest(data:[String:Any]) {
   
        for any in data {
            let item: [String:Any] = any.value as! [String:Any]
            let readItem = Item(with: item)
            if readItem != nil {
                AppData.sharedInstance.onlineRequestedItems.append(readItem!)
                print(readItem?.name)
                print("appending requested items")
            }
            else {
                print("Nil found in requested items")
            }
            
        }
    }
    
}

