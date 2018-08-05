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
    
     typealias writeListingClosure = (Bool) -> Void;
    
    class func write(item:Item, type:Int, completion: @escaping writeListingClosure) {
        let user = AppData.sharedInstance.currentUser!
        print("# of offered items: \(user.offeredItems.count), # of requested items: \(user.requestedItems.count)")
        let itemPath:String = "\(item.itemCategory.rawValue)/\(item.UID!)"
        var itemRef:String
        
        switch type {
        case 0:
            itemRef = "offers/"
            itemRef.append(itemPath)
            if AppData.sharedInstance.currentUser!.offeredItems.first == "" {
                AppData.sharedInstance.currentUser!.offeredItems.remove(at: 0)
            }
            
            //if were editing, dont append, but replace
 
                if let index = AppData.sharedInstance.currentUser!.offeredItems.index(of: itemRef){
                    AppData.sharedInstance.currentUserOfferedItems[index] = item
                }
                else {
                    
                    AppData.sharedInstance.currentUser!.offeredItems.append(itemRef)
                    AppData.sharedInstance.currentUserOfferedItems.append(item)
                    
                }
                
            
            
            break
        case 1:
            itemRef = "requests/"
            itemRef.append(itemPath)
            if AppData.sharedInstance.currentUser!.requestedItems.first == "" {
                AppData.sharedInstance.currentUser!.requestedItems.remove(at: 0)
            }
            
            //if were editing, dont append, but replace
            if let index = AppData.sharedInstance.currentUser!.requestedItems.index(of: itemRef){
                AppData.sharedInstance.currentUserRequestedItems[index] = item
            }
            else {
                
                AppData.sharedInstance.currentUser!.requestedItems.append(itemRef)
                AppData.sharedInstance.currentUserRequestedItems.append(item)
                
            }
            break
        default:
            print("Error: Invalid argument passed for 'type'")
            return
        }
        Database.database().reference().child(itemRef).setValue(item.toDictionary(), withCompletionBlock:{(error, ref) in
            
            if error != nil {
                //present alert
                completion(false)
            }
            
            else {
                AppData.sharedInstance.usersNode.child(user.UID).setValue(AppData.sharedInstance.currentUser?.toDictionary(), withCompletionBlock: {(error, ref) in
                    
                    if error != nil {
                        completion(false)
                    }
                    else {
                        completion(true)
                    }
                })
            }
        })
    }
    
    
    typealias deleteListingClosure = (Bool) -> Void;
    class func delete(itemUID: String, completion: @escaping deleteListingClosure) {
        let user = AppData.sharedInstance.currentUser!
        var itemPath:String? = nil
        
        for post in user.offeredItems {
            if post.range(of: itemUID) != nil {
                
                if let index = user.offeredItems.index(of: post) {
                    itemPath = post
                    AppData.sharedInstance.currentUser!.offeredItems.remove(at: index)
                   AppData.sharedInstance.currentUserOfferedItems.remove(at: index)
                    
                    
                }
                break
            }
        }
        if itemPath == nil {
            for post in user.requestedItems {
                if post.range(of: itemUID) != nil {
                    
                    if let index = user.requestedItems.index(of: post) {
                        itemPath = post
                        print("found it in requesteditems")
                        AppData.sharedInstance.currentUser!.requestedItems.remove(at: index)
                        AppData.sharedInstance.currentUserRequestedItems.remove(at: index)
                        
                    
            
                    }
                    break
                }
                else{
                   print("Error: Didnt find it in requesteditems")
                }
            }
        }
        
        
        //itemPath should exist now since its = post
        if itemPath == nil {
            print("Error: Cannot delete item; Item not found")
            completion(false)
            return
        }
        else {
            print("itemPath found: \(Database.database().reference().child(itemPath!))")
            
            Database.database().reference().child(itemPath!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
        
                let ref = Storage.storage().reference()
                let item: [String:Any] = snapshot.value as! [String:Any]
                let readItem = Item(with: item)
                if readItem != nil {
                    for photo in readItem!.photos {
                        print(photo)
                        ref.child(photo).delete(completion: { (error) in
                            if error != nil {
                                print("Error deleting photos linked to post: \(error ?? "" as! Error)")
                            }
                            else {
                                print("Deleted \(photo)")
                            }
                        })
                    }
                    Database.database().reference().child(itemPath!).removeValue(completionBlock: {(error, ref) in
                        if(error == nil){
                            
                            
                            WriteFirebaseData.write(user: AppData.sharedInstance.currentUser!, completion:{(success) in
                                
                                if (success){
                                    
                                    completion(true)
                                }
                                else  {
                                    completion(false)
                                }
                                
                            })
                            
                        }
                        else {
                            
                            completion(false)
                        }
                    })
                }
                else {
                    print("Nil found in read items")
                    completion(false)
                    
                }
            })
        }
    }
    
    
    typealias writeUserClosure = (Bool) -> Void;
    class func write(user:User, completion: @escaping writeUserClosure) {
        AppData.sharedInstance.usersNode.child(user.UID).setValue(user.toDictionary(), withCompletionBlock: {(error, ref) in
            
            if (error == nil){
                completion(true)
                
            }
            else {
                completion(false)
            }
            
        })
    }
    
    
    
    
    
    
    
}
