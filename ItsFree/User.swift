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
    
    convenience init?(with inpDict:[String:Any]) {
        guard
            let inpName: String = inpDict["name"] as? String,
            let inpEmail: String = inpDict["email"] as? String,
            let inpRating: NSNumber = inpDict["rating"] as? NSNumber,
            let inpUID: String = inpDict["UID"] as? String,
            let inpProfileImage: String = inpDict["profileImage"] as? String ?? "",
            var inpOffers:[String] = inpDict["offers"] as? [String],
            var inpRequests:[String] = inpDict["requests"] as? [String] else
        {
            print("Error: Dictionary is not in the correct format")
            return nil
        }
        
        var index = 0
        for i in inpOffers{
            
            if(i == ""){
                inpOffers.remove(at: index)
            }
            else {
                index = index+1
            }
        }
        
        index = 0
        for i in inpRequests{
            
            if(i == ""){
                inpRequests.remove(at: index)
            }
            else {
                index = index+1
            }
        }
        
        self.init(email: inpEmail,
                  name: inpName,
                  rating: inpRating.intValue,
                  uid: inpUID,
                  profileImage: inpProfileImage,
                  offers: inpOffers,
                  requests: inpRequests)
    }
    
    func toDictionary() -> [String:Any] {
        let userDict:[String:Any] = [ "UID":self.UID,
                                      "email":self.email,
                                      "name":self.name,
                                      "rating":self.rating,
                                      "profileImage":self.profileImage,
                                      "offers":self.offeredItems,
                                      "requests":self.requestedItems ]
        return userDict
    }

}
