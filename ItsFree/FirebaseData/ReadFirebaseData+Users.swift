//
//  ReadFirebaseData+Users.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-06.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import Firebase

extension ReadFirebaseData {
    
    //getMyCurrentUser
    class func readCurrentUser(){
        if ( Auth.auth().currentUser == nil) {
            return
        }
        
        AppData.sharedInstance.usersNode.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let value = snapshot.value as? NSDictionary,
                let currentUserUID = Auth.auth().currentUser?.uid,
                let currentUser = value["\(currentUserUID)"],
                let user: [String:Any] = currentUser as? [String:Any] {
                
                if let userUID: String = user["UID"] as? String {
                //let ratingInt =
                
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
                
                let readUser = User(email: (user["email"] as? String ?? "no email"),phoneNumber: (user["phoneNumber"] as? Int ?? 0) , name:(user["name"] as? String ?? "no name"), rating: (user["rating"] as? Double ?? 0.0), uid: (user["UID"] as? String ?? "no UID"), profileImage: (user["profileImage"] as? String ?? "no profileImage") , offers: readUserOffers, requests: readUserRequests)
                
                AppData.sharedInstance.currentUser = readUser
                
                storeCurrentUsersItems(userUID: userUID)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.myUserDownloadedNotificationKey), object: nil)
                
            }
            }
            
        })
        
    }
    
    
    //get all users
    class func readUsers(completion: @escaping (_ success: Bool) -> Void) {
        
        AppData.sharedInstance.onlineUsers.removeAll()
        AppData.sharedInstance.usersNode
            .observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? NSDictionary {
     
                var index = 0
                
                for any in (value.allValues) {
                    
                    if let user: [String:Any] = any as? [String:Any],
                        let userUID: String = user["UID"] as? String {
                    
                    
                    readUserBasics(userUID: userUID, completion: {(success, readUser) in
                        
                        index += 1
                        
                        if (success){
                            //force unwrap readUser okay, because we success is only true if it exists
                            AppData.sharedInstance.onlineUsers.append(readUser!)
                            
                        }
                        else {
                            print("Error reading user with uid: \(userUID)")
                        }
                        
                        //when weve read all users, make the callback
                        if (value.count == index){
                            completion(true)
                        }
                        
                    })
                    }

                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.shared.usersDownloadedNotificationKey), object: nil)
                }
                else {
                    
                    print("Error with snapshot dict)")
                }
            })
        
    }
    
    
    //readUserBasics
    class func readUserBasics(userUID: String, completion: @escaping (_ success: Bool, _ user: User?) -> Void ){
        
        AppData.sharedInstance.usersNode.child(userUID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let userSnapshot = snapshot.value as? NSDictionary,
                
                let user: [String:Any] = userSnapshot as? [String:Any] {
                
               // let ratingInt = user["rating"] as! NSNumber
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
                
                let readUser = User(email: (user["email"] ?? "no email") as! String,phoneNumber: (user["phoneNumber"] ?? 0) as! Int, name: user["name"] as! String, rating: user["rating"] as! Double, uid: (user["UID"] ?? "no UID") as! String, profileImage: (user["profileImage"] ?? "no profileImage") as! String, offers: readUserOffers, requests: readUserRequests)
                
                
                completion(true, readUser)
                
                
            }
            else {
                completion(false, nil)
            }
        })
    }
    

    
    
}
