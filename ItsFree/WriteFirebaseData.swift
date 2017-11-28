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
    
    class func write(item:Item, ref:DatabaseReference) {
        let user = AppData.sharedInstance.currentUser!
        ref.child(item.itemCategory.rawValue).child(item.UID).setValue(item.toDictionary())
    
    }
    
    
    
    
    
    
    
    
    
    
    
    
}



