//
//  AppDelegate.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-16.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import Firebase
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //FirebaseOptions.defaultOptions()?.deepLinkURLScheme = self.customURLScheme
        FirebaseApp.configure()
        let key = "FirstRun"
        if UserDefaults.standard.object(forKey: key) == nil {
            let keychain = Keychain(service: "com.itsFree")
            do {
                try keychain.removeAll()
            } catch {
                print("Error clearing Keychain")
            }
            UserDefaults.standard.set(true, forKey: key)
            UserDefaults.standard.set(false, forKey: rememberMeKey)
            UserDefaults.standard.synchronize()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if(url.scheme == "iosanotherlifeapp"){
        print("Scheme is: \(url.scheme!)")
        print("Query is: \(url.query!)")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        var homeViewController: HomeViewController = mainStoryboard.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
            
        self.window?.rootViewController?.present(homeViewController, animated: true, completion: nil)
            

         

////
//
//
//        let profileStoryboard: UIStoryboard = UIStoryboard(name: "ProfileViewControllers", bundle: nil)
////
//        var myPostsVC : MyPostsTableViewController = profileStoryboard.instantiateViewController(withIdentifier: "myPostsVC") as! MyPostsTableViewController


        
        
        
        
        let fullQueryitemIDToShow = String("\(url.query!)")
        
        let responderID: String!
        let itemID: String!
        
        let index = fullQueryitemIDToShow.index(fullQueryitemIDToShow.startIndex, offsetBy: 12)
        let substringitemIDToShow = fullQueryitemIDToShow.suffix(from: index)
        
        print(substringitemIDToShow)
        
        //if it was a wanted Item
        //Alert - Did you like the product? Use responderID to find the username Yes upvotes, no downvotes
        
        let alert = UIAlertController(title: "Do you like what you got?", message: "Upvote or downvote responderName", preferredStyle: UIAlertControllerStyle.alert)
        
        let upvoteAction = UIAlertAction(title: "Upvote", style: UIAlertActionStyle.default, handler:{(alert:UIAlertAction!) in         homeViewController.performSegue(withIdentifier: "toProfileSegue", sender: homeViewController)
            
        })
            let downvoteAction = UIAlertAction(title: "Downvote", style: UIAlertActionStyle.destructive, handler:{(alert:UIAlertAction!) in UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)})
        
        alert.addAction(upvoteAction)
        alert.addAction(downvoteAction)
        
        homeViewController.present(alert, animated: true, completion: nil)
            
        
        //if it was a available item
        //if link is clicked, send an email to seller saying thanks, and take me to the post to delete the item,
        
     
        
       // homeViewController.showItemDetail(item: <#T##Item#>)
        
        
        return true
        }
        else {
            return false
            
        }
    }
    
}

