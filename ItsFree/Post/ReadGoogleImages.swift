//
//  ReadGoogleImages.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

class ReadGoogleImages{
    
    class func constructURL(keyword: String) -> URL?{
        
        let APIKey = "AIzaSyCtTWhF4HK3J1sSFQhXe07CmimrwmzwlyA"
        
        let imageSearchEngineKey = "016334931021220945957:yzaxps2c9te"
        
        var urlString: String = ""
        
        //need to remove spaces, characters etc
        if let validKeyword = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
    
            urlString = "https://www.googleapis.com/customsearch/v1?key=\(APIKey)&cx=\(imageSearchEngineKey)&q=\(validKeyword)&searchType=image"
        }
  
        
       return URL(string: urlString)
        
        
        
    }
    
    class func grabImages(url: URL, completion: @escaping (_ imageArr: [URL],_ success: Bool) -> Void) {
        
        var imagesArray: [URL] = []
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            var jsonObject: Any
            if let e = error {
                print("Error downloading  picture: \(e)")
                completion([], false)
            } else {
                
                do {
    
                    jsonObject = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let dataDict = jsonObject as? [String: Any],
                        let items = dataDict["items"] as? [[String: Any]]{
                        
                        for item in items {
                            
                            if let imageData = item["image"] as? [String: Any],
                                let thumbnailLink = imageData["thumbnailLink"] as? String,
                                let thumbnailURL = URL(string: thumbnailLink){
                                
                                imagesArray.append(thumbnailURL)
                                
                            }
                            else {
                                print("Individual imageData has come back in a weid format")
                            }
                            
                        }
                        completion(imagesArray, true)
           
                    }
                    else {
                        print("Google images data has come back in a weird format")
                        completion([], false)
                    }
            

                }
                catch {
                    print("Error deserializing JSON data")
                    completion([], false)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    class func convertURLintoImage(url: URL, completion: @escaping (_ image: UIImage?,_ success: Bool) -> Void){
        
        let downloadPicTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let e = error {
                print("Error downloading  picture: \(e)")
                completion(nil, false)
            } else {
              
                if let _ = response as? HTTPURLResponse,
                    let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                    
                        completion(image, true)
                    
                    } else {
                        print("Couldn't get image: Image is nil")
                        completion(nil, false)
                    }
            }
        }
        
        downloadPicTask.resume()
        
    }
    
    
    
}
