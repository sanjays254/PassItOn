//
//  AppData.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


class AppData: NSObject {

    static let sharedInstance = AppData()
    
    public var currentUser: User? = nil
    public var onlineItems: Array<Item>? = nil
    
    public var usersNode: DatabaseReference
    public var itemsNode: DatabaseReference
    
    public override init() {
        
        usersNode = Database.database().reference().child("users")
        itemsNode = Database.database().reference().child("items")
    }
    
}