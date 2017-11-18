//
//  Item.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-16.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
// 

import Foundation
import CoreLocation

struct Tag {
    var tagString:String
}

class Item {
    
    var UID:String!
    var name:String
    var itemCategory:ItemCategory
    var itemDescription:String
    var location:CLLocationCoordinate2D
    var posterUID:String
    var quality:ItemQuality
    var tags:[Tag]
    
    init(with name:String,
         category:ItemCategory,
         description:String,
         location:CLLocationCoordinate2D,
         posterUID:String,
         quality:ItemQuality,
         and tags:[Tag]) {
        
        self.name = name
        self.itemCategory = category
        self.itemDescription = description
        self.location = location
        self.posterUID = posterUID
        self.quality = quality
        self.tags = tags
        self.posterUID = posterUID
    }
    
    func toDictionary() -> [String:Any] {
        var tagDict: [String:String] = [:]
        for tag in tags {
            tagDict[String(tagDict.count)] = tag.tagString
        }
        let locationDict:[String:Double] = ["latitude":self.location.latitude, "longitude":self.location.longitude]
        
        let itemDict:[String:Any] = [
            "UID": self.UID,
            "name": self.name,
            "itemCategory": self.itemCategory.rawValue,
            "itemDescription": self.itemDescription,
            "location": locationDict,
            "posterID":posterUID,
            "quality":self.quality.rawValue,
            "tags":tagDict
            ]
        
        return itemDict
    }
    
    
    
    
}