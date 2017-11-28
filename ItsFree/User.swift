//
//  User.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation

class User {
    var UID:String!
    var email:String
    var name:String
    var rating:Int
    var profileImage:String
    var offeredItems:[String]
    var requestedItems:[String]
    
    init(email:String, name:String, rating:Int, uid:String, profileImage:String, offers:[String], requests:[String]) {
        self.UID = uid
        self.email = email
        self.name = name
        self.rating = rating
        self.profileImage = profileImage
        self.offeredItems = offers
        self.requestedItems = requests
    }
    
    func toDictionary() -> [String:Any] {
        let userDict:[String:Any] = [ "UID":self.UID,
                                      "email":self.email,
                                      "name":self.name,
                                      "rating":self.rating,
                                      "profileImage":self.profileImage,
                                      "offers":self.offeredItems,
                                      "requessts":self.requestedItems ]
        return userDict
    }

}
