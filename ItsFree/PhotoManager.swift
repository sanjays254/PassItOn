//
//  PhotoManager.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit


class PhotoManager {
    
    class func uploadImage(image:UIImage, userUID:String, filename:String) -> String {
        let storageRef = Storage.storage().reference()
        let storagePath = "\(userUID)/\(filename)"
        let imageData:Data = UIImageJPEGRepresentation(image, 1.0)!
        let metedata = StorageMetadata()
        metedata.contentType = "image/jpeg"
        storageRef.child(storagePath).putData(imageData, metadata: metedata)
        
        return storagePath
    }
    
    class func downloadImage(imageReferencePath:String) {
        
    }
    
    
    
    
    
    
    
    
    
    
}


