//
//  PostViewController+SubmitPost.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension PostViewController {
    
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        
        resignAllKeyboardResponders()
        
        switch(qualitySegmentedControl.selectedSegmentIndex){
        case 0: chosenQuality = ItemQuality.New
        case 1: chosenQuality = ItemQuality.GentlyUsed
        case 2: chosenQuality = ItemQuality.WellUsed
        case 3: chosenQuality = ItemQuality.DamagedButFunctional
        default:
            chosenQuality = ItemQuality.GentlyUsed
        }
        validateFields()
    }
    
    
    //thePostMethod
    func validateFields() {
        
        guard (offerRequestSegmentedControl.selectedSegmentIndex != -1) else {
            let alert = UIAlertController(title: "Whoops", message: "You must offer or request this", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (titleTextField.text != "") else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a title", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (titleTextField.text!.count < 18) else {
            let alert = UIAlertController(title: "Whoops", message: "Title needs to be less than 18 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        if (descriptionTextField.text == "Optional Description"){
            descriptionTextField.text = ""
        }
        
        guard (chosenCategory != nil) else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a category", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        guard (selectedLocationCoordinates != nil) else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a location", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard !(valueTextField.text == "" && offerRequestSegmentedControl.selectedSegmentIndex == 0) else {
            let alert = UIAlertController(title: "Whoops", message: "Offered items must have a value", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let user = AppData.sharedInstance.currentUser!
        
        let tags:Tag = Tag()
        if chosenTagsArray.count > 0 {
            tags.tagsArray = chosenTagsArray
        }
        
        var photoRefs:[String] = []
        
        BusyActivityView.show(inpVc: self)
        
        if (editingBool){
            
            let realItem: Item = Item.init(name: titleTextField.text!, category: chosenCategory, description: descriptionTextField.text!, location: selectedLocationCoordinates, posterUID:  user.UID, quality: chosenQuality, tags: tags, photos: [""], value: Int(valueTextField.text!) ?? 0,  itemUID: itemToEdit.UID)
            
            
            if (photosArray.count+itemToEdit.photos.count) == 0 {
                
                if(offerRequestSegmentedControl.selectedSegmentIndex == 0){
                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "No Photos", inpMessage: "You must upload at least one photo of your item", inpOkTitle: "Okay")
                    BusyActivityView.hide()
                    
                    return
                }
                else {
                    photoRefs = []
                    
                }
            }
            else {
                
                photoRefs = itemToEdit.photos
                
                if (photosArray.count > 0){
                    
                    for index in 0..<photosArray.count {
                        let storagePath = "\(realItem.UID!)/\(index)"
                        
                        ImageManager.uploadImage(image: photosArray[index],
                                                 userUID: (AppData.sharedInstance.currentUser?.UID)!,
                                                 filename: storagePath, completion : {(success, photoRefStr) in
                                                    
                                                    if (success){
                                                        
                                                        photoRefs.append(photoRefStr!)
                                                        
                                                        if (photoRefs.count == self.photosArray.count + self.itemToEdit.photos.count) {
                                                            
                                                            realItem.photos = photoRefs
                                                            
                                                            WriteFirebaseData.write(item: realItem, type: self.offerRequestSegmentedControl.selectedSegmentIndex){(success) in
                                                                
                                                                if (success){
                                                                    
                                                                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Done", inpMessage: "Your item was successfully edited", inpOkTitle: "Ok")
                                                                    
                                                                    BusyActivityView.hide()
                                                                    self.navigationController?.popToRootViewController(animated: true)
                                                                    
                                                                }
                                                                else {
                                                                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your item could not be edited. Please try again", inpOkTitle: "Ok")
                                                                    
                                                                    BusyActivityView.hide()
                                                                }
                                                                
                                                                
                                                            }
                                                            
                                                            
                                                            
                                                        }}
                                                    else {
                                                        
                                                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "There was an error uploading one or more of your images & so your item wasnt uploaded", inpOkTitle: "Try again")
                                                        
                                                        BusyActivityView.hide()
                                                        
                                                    }
                                                    
                                                    
                        })
                    }
                }
                else{
                    
                    realItem.photos = photoRefs
                    
                    WriteFirebaseData.write(item: realItem, type: self.offerRequestSegmentedControl.selectedSegmentIndex){(success) in
                        
                        if (success){
                            
                            Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Done", inpMessage: "Your item was successfully uploaded", inpOkTitle: "Ok")
                            
                            BusyActivityView.hide()
                            self.navigationController?.popToRootViewController(animated: true)
                            
                        }
                        else {
                            Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your item could not be posted. Please try again", inpOkTitle: "Ok")
                            
                            BusyActivityView.hide()
                        }
                    }
                    
                    
                }
            }
        }
        else {
            
            
            let realItem: Item = Item.init(name: titleTextField.text!, category: chosenCategory, description: descriptionTextField.text!, location: selectedLocationCoordinates, posterUID:  user.UID, quality: chosenQuality, tags: tags, photos: [""], value: Int(valueTextField.text!) ?? 0,  itemUID: nil)
            
            
            if (photosArray.count == 0) {
                
                if(offerRequestSegmentedControl.selectedSegmentIndex == 0){
                    
                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "No Photos", inpMessage: "You must upload at least one photo of your item", inpOkTitle: "Okay")
                    BusyActivityView.hide()
                    
                    return
                }
                    
                else {
                    photoRefs = []
                    
                }
            }
            else {
                for index in 0..<photosArray.count {
                    let storagePath = "\(realItem.UID!)/\(index)"
                    
                    ImageManager.uploadImage(image: photosArray[index],
                                             userUID: (AppData.sharedInstance.currentUser?.UID)!,
                                             filename: storagePath, completion : {(success, photoRefStr) in
                                                
                                                if (success){
                                                    
                                                    photoRefs.append(photoRefStr!)
                                                    
                                                    if (photoRefs.count == self.photosArray.count) {
                                                        
                                                        realItem.photos = photoRefs
                                                        
                                                        WriteFirebaseData.write(item: realItem, type: self.offerRequestSegmentedControl.selectedSegmentIndex){(success) in
                                                            
                                                            if (success){
                                                                
                                                                let successAlert = UIAlertController(title: "Done", message: "Your item was successfully uploaded", preferredStyle: .alert)
                                                                
                                                                let okayAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) in
                                                                    
                                                                    self.navigationController?.popToRootViewController(animated: true)
                                                                    
                                                                })
                                                                successAlert.addAction(okayAction)
                                                                
                                                                Alert.Show(inpVc: self, customAlert: successAlert, inpTitle: "", inpMessage: "", inpOkTitle: "")
                                                                
                                                                BusyActivityView.hide()
                                                                
                                                                
                                                            }
                                                            else {
                                                                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your item could not be posted. Please try again", inpOkTitle: "Ok")
                                                                
                                                                BusyActivityView.hide()
                                                            }
                                                            
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                    }}
                                                else {
                                                    
                                                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "There was an error uploading one or more of your images & so your item wasnt uploaded", inpOkTitle: "Try again")
                                                    
                                                    BusyActivityView.hide()
                                                    
                                                }
                                                
                                                
                    })
                    
                }
            }
        }
        
        
    }
    

    
}
