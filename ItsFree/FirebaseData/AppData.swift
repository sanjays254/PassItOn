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
    public var currentUserOfferedItems: [Item] = []
    public var currentUserRequestedItems: [Item] = []
    public var currentUserPhotos: [String : UIImage] = [:]
    
    public var onlineOfferedItems: [Item] = []
    public var onlineRequestedItems: [Item] = []
    public var onlineUsers: [User] = []
    public var onlineUsersPhotos : [String : UIImage] = [:]
    
    public var usersNode: DatabaseReference
    public var offersNode: DatabaseReference
    public var requestsNode: DatabaseReference
    public var categorizedItemsNode: DatabaseReference
    
    
    public override init() {
        usersNode = Database.database().reference().child("users")
        offersNode = Database.database().reference().child("offers")
        requestsNode = Database.database().reference().child("requests")
        categorizedItemsNode = Database.database().reference().child("categorizedItems")
    }
    
}
