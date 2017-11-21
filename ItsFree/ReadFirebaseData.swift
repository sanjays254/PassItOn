//
//  ReadFirebaseData.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-18.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation



class ReadFirebaseData: NSObject {

        class func readContinues ()
        {
            if ( Auth.auth().currentUser == nil)
            {
                return
            }

            let userID = Auth.auth().currentUser?.uid;

            var myHandle : UInt = 0;

            myHandle =  AppData.sharedInstance.itemsNode
                .child(userID!).observe(DataEventType.value) { (snapshot) in

                    AppData.sharedInstance.itemsNode
                        .child(userID!)
                        .removeObserver(withHandle: myHandle)

            }
        }



        class func read()
        {
            if ( Auth.auth().currentUser == nil)
            {
                return
            }

            let userID = Auth.auth().currentUser?.uid;

            AppData.sharedInstance.itemsNode
                .observeSingleEvent(of: .value, with: { (snapshot) in

                    let value = snapshot.value as? NSDictionary;

                    if ( value == nil) {
                        return
                    }

                    for any in (value?.allValues)!
                    {
                        let item: [String:Any] = any as! [String:Any]
                        let readItem = Item(with: item)

                        AppData.sharedInstance.onlineItems.append(readItem!)
                    }
                })
        }

}

