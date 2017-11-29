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
    
    
    
    //    class func readContinues () {
    //        if ( Auth.auth().currentUser == nil)
    //        {
    //            return
    //        }
    //
    //        let userID = Auth.auth().currentUser?.uid;
    //        var myHandle : UInt = 0;
    //
    //        myHandle =  AppData.sharedInstance.offersNode
    //            .child(userID!).observe(DataEventType.value) { (snapshot) in
    //
    //                AppData.sharedInstance.offersNode
    //                    .child(userID!)
    //                    .removeObserver(withHandle: myHandle)
    //        }
    //    }
    
    class func readOffers(category:ItemCategory?) {
        if ( Auth.auth().currentUser == nil)
        {
            return
        }
        
        //        let userID = Auth.auth().currentUser?.uid;
        var ref:DatabaseReference
        if category == nil {
            ref = AppData.sharedInstance.offersNode
        }
        else {
            ref = AppData.sharedInstance.offersNode.child("\(category!.rawValue)")
        }
        
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary;
            if ( value == nil) {
                return
            }
            AppData.sharedInstance.onlineOfferedItems.removeAll()
            
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
        })
    }
    
    class func readRequests(category:ItemCategory?) {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        //        let userID = Auth.auth().currentUser?.uid;
        
        
        var ref:DatabaseReference
        if category == nil {
            ref = AppData.sharedInstance.requestsNode
        }
        else {
            ref = AppData.sharedInstance.requestsNode.child("\(category!.rawValue)")
        }
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if ( value == nil) {
                return
            }
            
            AppData.sharedInstance.onlineRequestedItems.removeAll()
            
            if category == nil {
                for thisCategory in value! {
                    print("\n\n\(thisCategory.key)")
                    let data = thisCategory.value as! [String:Any]
                    
                    readRequest(data: data)
                }
            }
            else {
                let data = value as? [String:Any]
                readRequest(data: data!)
            }
            let myDownloadNotificationKey = "myDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
        })
    }
    
    class func readUsers() {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        AppData.sharedInstance.onlineUsers.removeAll()
        let userID = Auth.auth().currentUser?.uid;
        
        AppData.sharedInstance.usersNode
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                if ( value == nil) {
                    return
                }
                
                for any in (value?.allValues)! {
                    let user: [String:Any] = any as! [String:Any]
                    let ratingInt = user["rating"] as! NSNumber
                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: Int(ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: [""], requests: [""])
                    
                    AppData.sharedInstance.onlineUsers.append(readUser)
                    print("appending items")
                }
                let myDownloadNotificationKey = "myDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
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
                print("appending requested items")
            }
            else {
                print("Nil found in requested items")
            }
            
        }
    }
    
}

