////
////  ReadFirebaseData.swift
////  ItsFree
////
////  Created by Sanjay Shah on 2017-11-18.
////  Copyright © 2017 Sanjay Shah. All rights reserved.
////
//
//import UIKit
//import Firebase
//import FirebaseAuth
//
//
//
//class ReadFirebaseData: NSObject {
//
//        class func readContinues ()
//        {
//            if ( Auth.auth().currentUser == nil)
//            {
//                return
//            }
//
//            let userID = Auth.auth().currentUser?.uid;
//
//            var myHandle : UInt = 0;
//
//            myHandle =  AppData.sharedInstance.itemsNode
//                .child(userID!).observe(DataEventType.value) { (snapshot) in
//
//                    AppData.sharedInstance.itemsNode
//                        .child(userID!)
//                        .removeObserver(withHandle: myHandle)
//
//            }
//        }
//
//
//
//        class func read()
//        {
//            if ( Auth.auth().currentUser == nil)
//            {
//                return
//            }
//
//            AppData.sharedInstance.onlineEntries = Array<EntryClass>()
//
//            let userID = Auth.auth().currentUser?.uid;
//
//            AppData.sharedInstance.itemsNode
//                .child(userID!)
//                .observeSingleEvent(of: .value, with: { (snapshot) in
//
//                    let value = snapshot.value as? NSDictionary;
//
//                    if ( value == nil) {
//                        return
//                    }
//
//
//
//                    for any in (value?.allValues)!
//                    {
//                        let entry : [String : String] = any as! Dictionary <String, String>;
//
//                        let readTitle : String = entry["titleKey"]!;
//                        let readBody : String = entry["bodyKey"]!;
//                        let readTime : String = entry["timeKey"]!;
//                        let readUid : String = entry["uidKey"]!;
//
//                        let readEntry = EntryClass (inpTitle: readTitle,
//                                                    inpBody: readBody,
//                                                    inpTime: Convert.stringToTime(inp:  readTime),
//                                                    inpUid: readUid);
//
//                        AppData.sharedInstance.onlineEntries.append(readEntry)
//
//                        print (AppData.sharedInstance.onlineEntries)
//                    }
//                })
//        }
//
//}

