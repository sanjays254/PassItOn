//
//  ImageManager.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit 
import FirebaseStorageUI


class ImageManager {
    
    class func uploadImage(image:UIImage, userUID:String, filename:String) -> String {
        let storageRef = Storage.storage().reference()
        let storagePath = "\(userUID)/\(filename)"
        let imageData:Data = UIImageJPEGRepresentation(image, 0.2)!
        let metedata = StorageMetadata()
        metedata.contentType = "image/jpeg"
        storageRef.child(storagePath).putData(imageData, metadata: metedata)
        
        return storagePath
    }
    
    class func downloadImage(imagePath:String, into: UIImageView) {
        
        let storageRef = Storage.storage().reference()
        
       
        let photoRef = storageRef.child(imagePath)
        var imageArray: [UIImage] = []
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        photoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error getting data")
            } else {
                
                let image = UIImage(data: data!)
                into.image = image
        
            }
        }
   
        //imageView.sd_setImage(with: imageRef, placeholderImage: nil)
    }
    
}


