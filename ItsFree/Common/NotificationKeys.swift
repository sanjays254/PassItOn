//
//  NotificationKeys.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-06.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class NotificationKeys: NSObject {
    
    static let shared = NotificationKeys()
    
    
    let offersDownloadedNotificationKey = "myOffersDownloadedNotificationKey"
    
    let noOffersDownloadedInThisCategoryNotificationKey = "noOfferedItemsInCategoryKey"
    
    let requestsDownloadedNotificationKey = "requestsDownloadedNotificationKey"
    
    let noRequestsDownloadedInThisCategoryKey = "noRequestedItemsInCategoryKey"
    
    let myUserDownloadedNotificationKey = "myUserDownloadedNotificationKey"
    
    let usersDownloadedNotificationKey = "myUsersDownloadedNotificationKey"
    
    let selectedItemNotificationKey = "mySelectedItemNotificationKey"
    

}
