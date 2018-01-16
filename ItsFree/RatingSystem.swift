//
//  RatingSystem.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-01-15.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class RatingSystem: NSObject {
    
    func parseURLAndRateUser(url: URL){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let mainVC = appDelegate.window?.rootViewController as! LoginViewController
        var currentVC: UIViewController
        
        //if we are already logged in and on the main view controller navigation stack
        if(mainVC.presentedViewController != nil){
            
            //set the HomeVC as the currentVC
            let presentedVC = mainVC.presentedViewController as! UINavigationController
            currentVC = presentedVC.viewControllers[0] as! HomeViewController
        }
            //else set the LoginVC as the currentVC
        else {
            currentVC = mainVC
        }
        
        let fullQuery = String("\(url.query!)")
        
        //find item
        let itemStartIndex = fullQuery.index(fullQuery.startIndex, offsetBy: 7)
        let itemEndIndex = fullQuery.index(fullQuery.endIndex, offsetBy: -36)
        let itemRange = itemStartIndex..<itemEndIndex
        
        let substringitemID = fullQuery[itemRange]
        print(substringitemID)
        let itemID: String! = String(substringitemID)
        var item: Item
        
        //if its a requested item. What about if it was deleted???
        if(AppData.sharedInstance.onlineRequestedItems.filter{ $0.UID == itemID}.first != nil){
            item = AppData.sharedInstance.onlineRequestedItems.filter{ $0.UID == itemID}.first!
            
            //ask user to delete his request
            
        }
            //else if it was an offered item.
        else {
            item = AppData.sharedInstance.onlineOfferedItems.filter{ $0.UID == itemID}.first!
        }
        
        
        //find user
        let userStartIndex = fullQuery.index(fullQuery.startIndex, offsetBy: 35)
        let userEndIndex = fullQuery.index(fullQuery.endIndex, offsetBy: 0)
        let userRange = userStartIndex..<userEndIndex
        
        let substringUserID = fullQuery[userRange]
        print(substringUserID)
        let responderID: String! = String(substringUserID)
        
        if ((AppData.sharedInstance.onlineUsers.filter{ $0.UID == responderID}.first) != nil){
            let responder = AppData.sharedInstance.onlineUsers.filter{ $0.UID == responderID}.first
            
            var alert: UIAlertController!
            
            //if its an offered item, currentUser cannot vote if = respsonder
            if(AppData.sharedInstance.onlineOfferedItems.filter{ $0.UID == itemID}.first != nil){
                if(responderID != item.posterUID){
                    alert = UIAlertController(title: "You cannot vote yourself", message: "The link is for the user you gave your \(item.name) to", preferredStyle: UIAlertControllerStyle.alert)
                    let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(okayAction)
                }
                    
                else {
                    alert = UIAlertController(title: "Do you like the \(item.name)?", message: "Upvote or downvote \(responder!.name)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let upvoteAction = UIAlertAction(title: "Upvote", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in responder?.rating = (responder?.rating)!+1
                        AppData.sharedInstance.usersNode.child("\(responderID!)/rating").setValue(responder?.rating)
                    })
                    let downvoteAction = UIAlertAction(title: "Downvote", style: UIAlertActionStyle.destructive, handler: {(alert: UIAlertAction!) in responder?.rating = (responder?.rating)!-1
                        AppData.sharedInstance.usersNode.child("\(responderID!)/rating").setValue(responder?.rating)
                    })
                    
                    alert.addAction(upvoteAction)
                    alert.addAction(downvoteAction)
                }
            }
                
                //if its a requested item, can only vote if posterID is currentID
            else {
                if(AppData.sharedInstance.currentUser?.UID == item.posterUID){
                    alert = UIAlertController(title: "Do you like the \(item.name)?", message: "Upvote or downvote \(responder!.name)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let upvoteAction = UIAlertAction(title: "Upvote", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in responder?.rating = (responder?.rating)!+1
                        AppData.sharedInstance.usersNode.child("\(responderID!)/rating").setValue(responder?.rating)
                    })
                    let downvoteAction = UIAlertAction(title: "Downvote", style: UIAlertActionStyle.destructive, handler: {(alert: UIAlertAction!) in responder?.rating = (responder?.rating)!-1
                        AppData.sharedInstance.usersNode.child("\(responderID!)/rating").setValue(responder?.rating)
                    })
                    
                    alert.addAction(upvoteAction)
                    alert.addAction(downvoteAction)
                }
                else{
                    alert = UIAlertController(title: "You cannot vote yourself", message: "The link is for the user you gave your \(item.name) to", preferredStyle: UIAlertControllerStyle.alert)
                    let okayAction = UIAlertAction(title: "Okay Lol", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(okayAction)
                }
            }
            
            
            
            currentVC.present(alert, animated: true, completion: nil)
        }
        else {
            let userDoesntExistAlert =  UIAlertController(title: "Oops", message: "User no longer exists", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            
            userDoesntExistAlert.addAction(okayAction)
            
            currentVC.present(userDoesntExistAlert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    

}
