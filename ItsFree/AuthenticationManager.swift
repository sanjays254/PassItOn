//
//  AuthenticationManager.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-21.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import KeychainAccess








class AuthenticationManager {
    
    class func signUp(with email:String, password:String, name:String) {
        
        let keychain = Keychain(service: "com.itsFree")
        
        DispatchQueue.global().async {
            do {
                // Should be the secret invalidated when passcode is removed? If not then use `.WhenUnlocked`
                try keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(password, key: email)
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
    
    class func login(with email:String, password:String) {
        let keychain = Keychain(service: "com.itsFree")
        
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get(email)
                
                print("password: \(password)")
            } catch let error {
                // Error handling if needed...
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
}





