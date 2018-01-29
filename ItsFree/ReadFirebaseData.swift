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
                    let userUID: String = user["UID"] as! String
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
                    
                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: readUserOffers as! Array, requests: (user["requests"] ?? [""]) as! Array)
                    
//                    let readUser = User(email: (user["email"] ?? "no email") as! String, name: user["name"] as! String, rating: Int(truncating: ratingInt), uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: [""] as! Array, requests: (user["requests"] ?? [""]) as! Array)
                    
                    AppData.sharedInstance.onlineUsers.append(readUser)
                    print("appending items")
                    
                     if (userUID == AppData.sharedInstance.currentUser?.UID){
                        
                        storeCurrentUsersItems(userUID: userUID)
                    }
                
                }
                //let myDownloadNotificationKey = "myDownloadNotificationKey"
                //NotificationCenter.default.post(name: Notification.Name(rawValue: myDownloadNotificationKey), object: nil)
                
                let myUsersDownloadNotificationKey = "myUsersDownloadNotificationKey"
                NotificationCenter.default.post(name: Notification.Name(rawValue: myUsersDownloadNotificationKey), object: nil)
            })
        
    }
    
   class func readUsersPhotos(){
        let storageRef = Storage.storage().reference()
        
        // Create a reference to the file you want to download
        let ref = AppData.sharedInstance.currentUser?.profileImage
        let profilePhotoRef = storageRef.child(ref!)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profilePhotoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("Errroorr")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                AppData.sharedInstance.currentUserPhotos[(AppData.sharedInstance.currentUser?.profileImage)!] = image
                
            }
        }

        for offeredItem in AppData.sharedInstance.currentUserOfferedItems {
            for stringPhotoRef in offeredItem.photos{

                let photoRef = storageRef.child(stringPhotoRef)
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                photoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("error getting data")
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        let resizedImage = image?.resizeImage(40, opaque: true)
                        AppData.sharedInstance.currentUserPhotos[stringPhotoRef] = resizedImage

                    }
                }
            }

        }
//
        for requestedItem in AppData.sharedInstance.currentUserRequestedItems {
            for stringPhotoRef in requestedItem.photos{

                let photoRef = storageRef.child(stringPhotoRef)
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                photoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        let resizedImage = image?.resizeImage(40, opaque: true)
                        AppData.sharedInstance.currentUserPhotos[stringPhotoRef] = resizedImage

                    }
                }
            }

        }


        
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
    
    class func storeCurrentUsersItems(userUID:String){
       
        for itemRef in (AppData.sharedInstance.currentUser?.offeredItems)! {
                
                let itemUID = String(itemRef.suffix(20))
                
                let item = AppData.sharedInstance.onlineOfferedItems.filter{ $0.UID == itemUID}.first!
                AppData.sharedInstance.currentUserOfferedItems.append(item)
            }
        
        for itemRef in (AppData.sharedInstance.currentUser?.requestedItems)! {
            
            let itemUID = String(itemRef.suffix(20))
            
            let item = AppData.sharedInstance.onlineRequestedItems.filter{ $0.UID == itemUID}.first!
            AppData.sharedInstance.currentUserRequestedItems.append(item)
            
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

