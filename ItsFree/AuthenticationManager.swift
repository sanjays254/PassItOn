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


class AuthenticationManager {
    
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
                        print("Error sending verification email: \(verifyError)")
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
                                                 name: newUser!.displayName!,
                                                 rating: 0,
                                                 uid: newUser!.uid)
                            
                            AppData.sharedInstance.currentUser = addedUser
                            
                            AppData.sharedInstance.usersNode
                                .child(newUser!.uid)
                                .setValue(addedUser.toDictionary())
                            print("Sign up successful")
                            AuthenticationManager.addToKeychain(email: email, password: password)
                        }
                        else {
                            print("Error setting profile name: \(profileError)")
                        }
                })
            }
            else {
                print("Error registering with Firebase: \(registerError)")
            }
        }
    }
    
    
    class func addToKeychain(email:String, password:String) {
        print("Adding to keychain...")
        let keychain = Keychain(service: "com.itsFree")
        
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenUnlocked, authenticationPolicy: .userPresence)
                    .set(password, key: email)
                print("Item added to keychain")
            } catch let error {
                // Error handling if needed...
                print("Keychain Error: \(error)")
            }
        }
    }
    
    class func printKeychain() {
        let keychain = Keychain(service: "com.itsFree")
        print("\(keychain)")
    }
    
    class func login(withEmail email:String, password:String, completionHandler: @escaping (_ success: Bool) -> Void) {
        print("Logging in with email: \(email), password: \(password)")

        print("Logging in to Firebase...")
        Auth.auth().signIn(withEmail: email,
                           password: password)
        { (authUser, loginError) in
            if loginError == nil {
                AppData.sharedInstance.currentUser = User(email: authUser!.email!,
                                                          name: authUser!.displayName!,
                                                          rating: 0,
                                                          uid: authUser!.uid)
                print("Login Successful")
                //addToKeychain(email: email, password: password)
                let flag = true
                completionHandler(flag)
            }
            else {
                print("login failed: \(loginError.debugDescription)")
            }
        }
    }
    
    class func loginWithTouchID(email:String, completionHandler: @escaping (_ success: Bool) -> Void ) {
        let keychain = Keychain(service: "com.itsFree")
        
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get(email)
                
                print("password: \(password)")
                AuthenticationManager.login(withEmail: email, password: password!, completionHandler: completionHandler)
            } catch let error {
                // Error handling if needed...
                print("Error loggin in using TouchID: \(error)")
            }
        }
    }
    
}
