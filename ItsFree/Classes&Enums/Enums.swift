//
//  Enums.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
// 

import Foundation

public enum ItemCategory:String {
    
    
    case books = "Books",
    clothing = "Clothing",
    furniture = "Furniture",
    artAndCollectables = "Art & Collectables",
    sportingGoods = "Sporting Goods",
    electronics = "Electronics",
    homeAppliances = "Home Appliances",
    jewelleryAndWatches = "Jewellery & Watches",
    toys = "Toys",
    buildingToolsAndSupplies = "Building Tools & Supplies",
    indoorDecor = "Indoor Decor",
    outdoorDecor = "Outdoor Decor",
    other = "Other"
    
    static func stringValue(index: Int) -> String {
        switch index {
        case 0:
            return ItemCategory.books.rawValue
        case 1:
            return ItemCategory.clothing.rawValue
        case 2:
            return ItemCategory.furniture.rawValue
        case 3:
            return ItemCategory.artAndCollectables.rawValue
        case 4:
            return ItemCategory.sportingGoods.rawValue
        case 5:
            return ItemCategory.electronics.rawValue
        case 6:
            return ItemCategory.homeAppliances.rawValue
        case 7:
            return ItemCategory.jewelleryAndWatches.rawValue
        case 8:
            return ItemCategory.toys.rawValue
        case 9:
            return ItemCategory.buildingToolsAndSupplies.rawValue
        case 10:
            return ItemCategory.indoorDecor.rawValue
        case 11:
            return ItemCategory.outdoorDecor.rawValue
        case 12:
            return ItemCategory.other.rawValue
        default:
            return "Error"
        }
        
    }
    
    static func enumName(index: Int) -> ItemCategory {
        switch index {
        case 0:
            return ItemCategory.books
        case 1:
            return ItemCategory.clothing
        case 2:
            return ItemCategory.furniture
        case 3:
            return ItemCategory.artAndCollectables
        case 4:
            return ItemCategory.sportingGoods
        case 5:
            return ItemCategory.electronics
        case 6:
            return ItemCategory.homeAppliances
        case 7:
            return ItemCategory.jewelleryAndWatches
        case 8:
            return ItemCategory.toys
        case 9:
            return ItemCategory.buildingToolsAndSupplies
        case 10:
            return ItemCategory.indoorDecor
        case 11:
            return ItemCategory.outdoorDecor
        case 12:
            return ItemCategory.other
        default:
            return ItemCategory.other
        }
        
    }
    //gets count of categories
    static var count: Int { return ItemCategory.other.hashValue + 1
        
    }
}

public enum ItemQuality:String {
    case New  = "New",
    GentlyUsed = "Used",
    WellUsed = "Worn Out",
    DamagedButFunctional = "Damaged",
    NeedsFixing = "Needs Fixing"
    
    static func itemQualityIndex(quality: ItemQuality) -> Int {
        switch quality {
        case .New:
            return 0
        case .GentlyUsed:
            return 1
        case .WellUsed:
            return 1
        case .DamagedButFunctional:
            return 3
        case .NeedsFixing:
            return 3
        }
    }
}
