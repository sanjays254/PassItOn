//
//  AuthenticationHelper.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationHelper: NSObject {
    
    class func register(withEmail email:String, password:String, username:String) -> User? {
        print("Registering with firebase")
        Auth.auth().createUser(withEmail: email,
                               password: password)
        { (newUser, registerError) in
            if registerError == nil {
                let setUsername = newUser?.createProfileChangeRequest()
                setUsername?.displayName = username
                
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
                            
                        }
                })
            }
            else {
                print("Error registering with Firebase: \(registerError)")
            }
        }
        
        return AppData.sharedInstance.currentUser
    }
    
    class func login(withEmail email:String, password:String) -> User? {
        
        Auth.auth().signIn(withEmail: email,
                           password: password)
        { (authUser, loginError) in
            if loginError == nil {
                AppData.sharedInstance.currentUser = User(email: authUser!.email!,
                                                         name: authUser!.displayName!,
                                                         rating: 0,
                                                         uid: authUser!.uid)
            }
            else {
                print("login failed: \(loginError.debugDescription)")
            }
            
        }
        return AppData.sharedInstance.currentUser
    }
    
}


