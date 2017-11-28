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
    
    class func readContinues () {
        if ( Auth.auth().currentUser == nil)
        {
            return
        }
        
        let userID = Auth.auth().currentUser?.uid;
        var myHandle : UInt = 0;
        
        myHandle =  AppData.sharedInstance.offersNode
            .child(userID!).observe(DataEventType.value) { (snapshot) in
                
                AppData.sharedInstance.offersNode
                    .child(userID!)
                    .removeObserver(withHandle: myHandle)
        }
    }
    
    class func readOffers() {
        if ( Auth.auth().currentUser == nil)
        {
            return
        }
        
        let userID = Auth.auth().currentUser?.uid;
        
        AppData.sharedInstance.offersNode.observe(DataEventType.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary;
            
            if ( value == nil) {
                return
            }
            AppData.sharedInstance.onlineOfferedItems.removeAll()
            
            for any in (value?.allValues)! {
                let item: [String:Any] = any as! [String:Any]
                let readItem = Item(with: item)
                if readItem != nil{
                    AppData.sharedInstance.onlineOfferedItems.append(readItem!)
                    print("appending offered items")
                }
                else {
                    print("Nil found in offered items")
                }
            }
            let myDownloadNotificationKey = "myDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
        })
    }
    
    class func readRequests() {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        let userID = Auth.auth().currentUser?.uid;
        
        AppData.sharedInstance.requestsNode.observe(DataEventType.value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary;
            
            if ( value == nil) {
                return
            }
            
            AppData.sharedInstance.onlineRequestedItems.removeAll()
            
            
            for any in (value?.allValues)! {
                let item: [String:Any] = any as! [String:Any]
                let readItem = Item(with: item)
                
                if readItem != nil {
                    AppData.sharedInstance.onlineRequestedItems.append(readItem!)
                    print("appending requested items")
                }
                else {
                    print("Nil found in requested items")
                }
            }
            let myDownloadNotificationKey = "myDownloadNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
        })
    }
    
    class func readUsers() {
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        let userID = Auth.auth().currentUser?.uid;
        
        AppData.sharedInstance.usersNode
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary;
                
                if ( value == nil) {
                    return
                }
                
                for any in (value?.allValues)! {
                    let user: [String:Any] = any as! [String:Any]
                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: (user["rating"] ?? 0) as! Int, uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String)
                    
                    AppData.sharedInstance.onlineUsers.append(readUser)
                    print("appending items")
                }
                let myDownloadNotificationKey = "myDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
            })
    }
    
}

