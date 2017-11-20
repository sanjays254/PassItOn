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

            AppData.sharedInstance.onlineItems = Array<Item>()

            let userID = Auth.auth().currentUser?.uid;

            AppData.sharedInstance.itemsNode
                //.child(userID!)
                .child("testUserUID")
                .observeSingleEvent(of: .value, with: { (snapshot) in

                    let value = snapshot.value as? NSDictionary;

                    if ( value == nil) {
                        return
                    }

                    for any in (value?.allValues)!
                    {
                  
                            
                        
                        let item : [String : Any] = any as! Dictionary <String, Any>;

                        let readTitle : String = item["name"]! as! String;
                        let readDescription : String = item["itemDescription"]! as! String;
                        let readCategory : String = item["itemCategory"]! as! String;
                        let readUid : String = item["UID"]! as! String;
                        let readRawLocation : [String:Double] = item["location"]! as! [String:Double]
                        let readPosterID : String = item["posterID"] as! String;
                        let readQuality : String = item["quality"] as! String;
                        let readTags : Array<String> =  item["tags"] as! Array;
                        
                        let readLocationCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(readRawLocation["latitude"]!, readRawLocation["longitude"]!)
                        

                        //change the location AND tAG to read from the online data.
                        let readEntry = Item.init(name: readTitle, category: ItemCategory(rawValue: readCategory)!, description: readDescription, location: readLocationCoordinate, posterUID: readPosterID, quality: ItemQuality(rawValue: readQuality)!, tags: Tag() )

                        AppData.sharedInstance.onlineItems?.append(readEntry)

                        print (AppData.sharedInstance.onlineItems)
                        
                    }
                })
        }

}

