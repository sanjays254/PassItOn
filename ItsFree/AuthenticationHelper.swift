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
    
    class func register(withEmail email:String, password:String, username:String){
        Auth.auth().createUser(withEmail: email, password: password) { (newUser, error) in
            
        }
    }
    
    class func login(withEmail email:String, password:String) -> User? {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authUser, error) in
            
            
            
            
            
            
        }
        
        
        
        
        return nil
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


