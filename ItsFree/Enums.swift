//
//  Enums.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
// 

import Foundation

public enum ItemCategory:String {
    case Books = "Books",
    Clothing = "Clothing",
    Furniture = "Furniture",
    ArtAndCollectables = "Art & Collectables",
    SportingGoods = "Sporting Goods",
    Electronics = "Electronics",
    HomeAppliances = "Home Appliances",
    JewelleryAndWatches = "Jewellery & Watches",
    Toys = "Toys",
    BuildingToolsAndSupplies = "Building Tools & Supplies",
    IndoorDecor = "Indoor Decor",
    OutdoorDecor = "Outdoor Decor",
    Other = "Other"
}

public enum ItemQuality:String {
    case New  = "New",
    GentlyUsed = "Gently Used",
    WellUsed = "Well Used",
    DamagedButFunctional = "Damaged but Functional",
    NeedsFixing = "Needs Fixing"
}
