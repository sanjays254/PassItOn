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
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary;
            
            if ( value == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "noOfferedItemsInCategoryKey"), object: nil)
                
                let myOffersDownloadedNotificationKey = "myOffersDownloadedNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myOffersDownloadedNotificationKey), object: nil)
                
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
            let myOffersDownloadedNotificationKey = "myOffersDownloadedNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myOffersDownloadedNotificationKey), object: nil)
            
        })
        

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
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if ( value == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "noRequestedItemsInCategoryKey"), object: nil)
                
                let myRequestsDownloadedNotificationKey = "myRequestsDownloadedNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myRequestsDownloadedNotificationKey), object: nil)
                
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
            let myRequestsDownloadedNotificationKey = "myRequestsDownloadedNotificationKey"
            NotificationCenter.default.post(name: Notification.Name(rawValue: myRequestsDownloadedNotificationKey), object: nil)
            
        })
    }
    
    
    
    //getMyCurrentUser
    class func readCurrentUser(){
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        AppData.sharedInstance.usersNode.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if ( value == nil) {
                return
            }
            if let currentUserUID = Auth.auth().currentUser?.uid {
                if let currentUser = value?["\(currentUserUID)"] {
            
                let user: [String:Any] = currentUser as! [String:Any]
                 
                    let userUID: String = user["UID"] as! String
                let ratingInt = user["rating"] as! NSNumber
                var readUserOffers: [String]
                var readUserRequests: [String]
                
                if (user.keys.contains("offers")){
                    readUserOffers = (user["offers"] as? [String])!
                }
                else {
                    readUserOffers = [] as [String]
                }
                
                if (user.keys.contains("requests")){
                    readUserRequests = (user["requests"] as? [String])!
                }
                else {
                    readUserRequests = [] as [String]
                }
                
                var index = 0
                for i in readUserOffers{
                    
                    if(i == ""){
                        readUserOffers.remove(at: index)
                    }
                    else {
                        index = index+1
                    }
                }
                
                
                index = 0
                for i in readUserRequests{
                    
                    if(i == ""){
                        readUserRequests.remove(at: index)
                    }
                    else {
                        index = index+1
                    }
                }
                
                let readUser = User(email: (user["email"] ?? "no email") as! String,phoneNumber: (user["phoneNumber"] ?? 0) as! Int, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: readUserOffers, requests: readUserRequests)
            
            
                    AppData.sharedInstance.currentUser = readUser
                    
                    storeCurrentUsersItems(userUID: userUID)
                    
                    let myUserDownloadNotificationKey = "myUserDownloadNotificationKey"
                    NotificationCenter.default.post(name: Notification.Name(rawValue: myUserDownloadNotificationKey), object: nil)
           
                }
            }
            
        })
        
    }
    
    //readUserBasics
    class func readUserBasics(userUID: String, completion: @escaping (_ success: Bool, _ user: User?) -> Void ){
        
        AppData.sharedInstance.usersNode.child(userUID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let userSnapshot = snapshot.value as? NSDictionary {
       
                    let user: [String:Any] = userSnapshot as! [String:Any]
                
                    let ratingInt = user["rating"] as! NSNumber
                    var readUserOffers: [String]
                    var readUserRequests: [String]
                    
                    if (user.keys.contains("offers")){
                        readUserOffers = (user["offers"] as? [String])!
                    }
                    else {
                        readUserOffers = [] as [String]
                    }
                    
                    if (user.keys.contains("requests")){
                        readUserRequests = (user["requests"] as? [String])!
                    }
                    else {
                        readUserRequests = [] as [String]
                    }
                    
                    var index = 0
                    for i in readUserOffers{
                        
                        if(i == ""){
                            readUserOffers.remove(at: index)
                        }
                        else {
                            index = index+1
                        }
                    }
                    
                    
                    index = 0
                    for i in readUserRequests{
                        
                        if(i == ""){
                            readUserRequests.remove(at: index)
                        }
                        else {
                            index = index+1
                        }
                    }
                    
                    let readUser = User(email: (user["email"] ?? "no email") as! String,phoneNumber: (user["phoneNumber"] ?? 0) as! Int, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: readUserOffers, requests: readUserRequests)
                
                
                completion(true, readUser)
                
            
            }
            else {
                completion(false, nil)
            }
        })
    }
    
    
    //get all users
    class func readUsers(completion: @escaping (_ success: Bool) -> Void) {
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
                
                var index = 0
                
                for any in (value?.allValues)! {
                
                    let user: [String:Any] = any as! [String:Any]
                    let userUID: String = user["UID"] as! String
                    
                    
                    readUserBasics(userUID: userUID, completion: {(success, user) in
                        
                        index += 1
                        
                        if (success){
                            AppData.sharedInstance.onlineUsers.append(user!)
                            
                        }
                        else {
                            print("Error reading user with uid: \(userUID)")
                        }
                        
                        if (value?.count == index){
                            completion(true)
                        }
                        
                    })


                
                }
                let myUsersDownloadNotificationKey = "myUsersDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myUsersDownloadNotificationKey), object: nil)
            })
        
    }

    
    fileprivate class func readOffer(data:[String:Any]) {
        for any in data {
            let item: [String:Any] = any.value as! [String:Any]
            let readItem = Item(with: item)
            if readItem != nil {
                if (!AppData.sharedInstance.onlineOfferedItems.contains(readItem!)){
                    AppData.sharedInstance.onlineOfferedItems.append(readItem!)
                    print("appending offered items")
                }
                else {
                    print("item has already been added")
                }
                
               
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
                 if (!AppData.sharedInstance.onlineRequestedItems.contains(readItem!)){
                    AppData.sharedInstance.onlineRequestedItems.append(readItem!)
                    print("appending requested items")
                }
                 else {
                    print("item has already been added")
                }
            }
            else {
                print("Nil found in requested items")
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
                        print("appending offered items")
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
                
                if readItem != nil {
                    if (!AppData.sharedInstance.currentUserRequestedItems.contains(readItem!)){
                        AppData.sharedInstance.currentUserRequestedItems.append(readItem!)
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
    
    
    extension UIImage {
        func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIViewContentMode = .scaleAspectFit) -> UIImage {
            var width: CGFloat
            var height: CGFloat
            var newImage: UIImage
            
            let size = self.size
            let aspectRatio =  size.width/size.height
            
            switch contentMode {
            case .scaleAspectFit:
                if aspectRatio > 1 {                            // Landscape image
                    width = dimension
                    height = dimension / aspectRatio
                } else {                                        // Portrait image
                    height = dimension
                    width = dimension * aspectRatio
                }
                
            default:
                fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
            }
            
            if #available(iOS 10.0, *) {
                let renderFormat = UIGraphicsImageRendererFormat.default()
                renderFormat.opaque = opaque
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
                newImage = renderer.image {
                    (context) in
                    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            } else {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                newImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            
            return newImage
        }
}

