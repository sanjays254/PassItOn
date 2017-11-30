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
        var itemRef:String
        
        switch type {
        case 0:
            itemRef = "offers/"
            itemRef.append(itemPath)
            if AppData.sharedInstance.currentUser!.offeredItems.first == "" {
                AppData.sharedInstance.currentUser!.offeredItems.remove(at: 0)
            }
            AppData.sharedInstance.currentUser!.offeredItems.append(itemRef)
            break
        case 1:
            itemRef = "requests/"
            itemRef.append(itemPath)
            if AppData.sharedInstance.currentUser!.requestedItems.first == "" {
                AppData.sharedInstance.currentUser!.requestedItems.remove(at: 0)
            }
            AppData.sharedInstance.currentUser!.requestedItems.append(itemRef)
            break
        default:
            print("Error: Invalid argument passed for 'type'")
            return
        }
        Database.database().reference().child(itemRef).setValue(item.toDictionary())
        
        
        print("# of offered items: \(user.offeredItems.count), # of requested items: \(user.requestedItems.count), itemPath: \(itemRef)")
        AppData.sharedInstance.usersNode.child(user.UID).setValue(AppData.sharedInstance.currentUser?.toDictionary())
    }
    
    class func delete(itemUID: String) {
        let user = AppData.sharedInstance.currentUser!
        var itemPath:String? = nil
        for post in user.offeredItems {
            if post.range(of: itemUID) != nil {
                itemPath = post
                if let index = user.offeredItems.index(of: post) {
                    user.offeredItems.remove(at: index)
                }
                break
            }
        }
        if itemPath == nil {
            for post in user.requestedItems {
                if post.range(of: itemUID) != nil {
                    itemPath = post
                    if let index = user.requestedItems.index(of: post) {
                        user.requestedItems.remove(at: index)
                    }
                    break
                }
            }
        }
        
        if itemPath == nil {
            print("Error: Cannot delete item; Item not found")
            return
        }
        else {
            print("itemPath found: \(Database.database().reference().child(itemPath!))")
            
            Database.database().reference().child(itemPath!).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                print(snapshot.value)
                
                let ref = Storage.storage().reference()
                let item: [String:Any] = snapshot.value as! [String:Any]
                let readItem = Item(with: item)
                if readItem != nil {
                    //print(readItem?.photos)
                    for photo in readItem!.photos {
                        print(photo)
                        ref.child(photo).delete(completion: { (error) in
                            if error != nil {
                                print("Error deleting photos linked to post: \(error)")
                            }
                            else {
                                print("Deleted \(photo)")
                            }
                        })
                    }
                    Database.database().reference().child(itemPath!).removeValue()
                    WriteFirebaseData.write(user: AppData.sharedInstance.currentUser!)
                }
                else {
                    print("Nil found in read items")
                }
            })
        }
    }
    
    class func write(user:User) {
        AppData.sharedInstance.usersNode.child(user.UID).setValue(user.toDictionary())
    }
    
    
    
    
    
    
    
}
