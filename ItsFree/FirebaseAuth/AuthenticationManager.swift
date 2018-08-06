//
//  AuthenticationManager.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-21.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import KeychainAccess
import FirebaseAuth
import Firebase



class AuthenticationManager {
    
    static var alertDelegate: AlertDelegate!
    
    class func signUp(withEmail email:String, password:String, name:String, completionHandler: @escaping (_ success: Bool) -> Void )  {
        print("Signing up with email: \(email), password: \(password), name: \(name)")
        print("Registering with firebase")
        Auth.auth().createUser(withEmail: email,
                               password: password)
        { (newUser, registerError) in
            if registerError == nil {
                let flag = true
                completionHandler(flag)
                Auth.auth().currentUser?.sendEmailVerification(completion: { (verifyError) in
                    if (verifyError != nil) {
                        print("Error sending verification email: \(String(describing: verifyError))")
                    }
                    else {
                        print("Email sent")
                    }
                })
                let setUsername = newUser?.createProfileChangeRequest()
                setUsername?.displayName = name
                
                setUsername?.commitChanges(completion:
                    { (profileError) in
                        if profileError == nil {
                            let addedUser = User(email: newUser!.email!,
                                                 phoneNumber: 0,
                                                 name: newUser!.displayName!,
                                                 rating: 0,
                                                 uid: newUser!.uid, profileImage: "",
                                                 offers: [""],
                                                 requests: [""])
                            
                            AppData.sharedInstance.currentUser = addedUser
                            
                            AppData.sharedInstance.usersNode
                                .child(newUser!.uid)
                                .setValue(addedUser.toDictionary())
                            print("Sign up successful")
                            AuthenticationManager.addToKeychain(email: email, password: password)
                            guestUser = false
                        }
                        else {
                            print("Error setting profile name: \(String(describing: profileError))")
                        }
                })
            }
            else {
                print("Error registering with Firebase: \(String(describing: registerError))")
            }
        }
    }
    
    
    class func addToKeychain(email:String, password:String) {
        
        
        
        print("Adding to keychain...")
        let keychain = Keychain(service: "com.itsFree")
        
        DispatchQueue.global().async {
            do {
                print("checking if keychain has key already")
                let alreadyInKeychain = try keychain.get("_\(email)")
                print("alreadyInKeychain: \(String(describing: alreadyInKeychain))")
                if alreadyInKeychain == nil {
                    do {
                        try keychain
                            .accessibility(.whenUnlocked, authenticationPolicy: .userPresence)
                            .set(password, key: email)
                        try keychain.set("yes", key: "_\(email)")
                        
                        print("Item added to keychain")
                    } catch let error {
                        // Error handling if needed...
                        print("Keychain Error: \(error)")
                    }
                }
            } catch let error {
                print("Keychain item existence check error: \(error)")
            }
            
        }
    }
    
    class func login(withEmail email:String, password:String, completionHandler: @escaping (_ success: Bool) -> Void) {
        print("Logging in with email: \(email), password: \(password)")
        
        print("Logging in to Firebase...")
        Auth.auth().signIn(withEmail: email,
                           password: password)
        { (authUser, loginError) in
            
            
            if loginError == nil {
                let userUID = Auth.auth().currentUser?.uid
                AppData.sharedInstance.usersNode.child(userUID!)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                    let data = snapshot.value as? NSDictionary
                        
                        if data == nil {
                            return
                        }
                        
                        let userData: [String:Any] = data as! [String : Any]
                        
                        AppData.sharedInstance.currentUser = User(with: userData)
                })
                print("Login Successful")
                guestUser = false
                addToKeychain(email: email, password: password)
                
                BusyActivityView.hide()
                
                let flag = true
                completionHandler(flag)
            }
            else {
                print("login failed: \(loginError.debugDescription)")
//
//                var loginVC: LoginViewController
//
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//                if let rootVC = appDelegate.window?.rootViewController as? LoginViewController{
//                    loginVC = rootVC
//                }
//                else {
//                    loginVC =
//                }
                
                
                
                let loginFailedAlert = UIAlertController(title: "Login failed", message: "Incorrect Email or Password", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
                loginFailedAlert.addAction(okayAction)
                
                alertDelegate.presentAlert(alert: loginFailedAlert)
                
                BusyActivityView.hide()
                
            }
        }
    }
    
    class func loginWithTouchID(vc: UIViewController, email:String, completionHandler: @escaping (_ success: Bool) -> Void ) {
        
        let keychain = Keychain(service: "com.itsFree")
    
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get(email)
                
                print("password: \(String(describing: password))")
                
                DispatchQueue.main.async {
                    
                    BusyActivityView.show(inpVc: vc)
                }
                AuthenticationManager.login(withEmail: email, password: password!, completionHandler: completionHandler)
            } catch let error {
                // Error handling if needed...
                print("Error loggin in using TouchID: \(error)")
            }
        }
    }
    
}
