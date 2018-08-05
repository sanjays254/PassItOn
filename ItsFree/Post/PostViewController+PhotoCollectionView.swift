//
//  PostViewController+PhotoCollectionView.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit


extension PostViewController {
    
    
    func setupPhotoCollectionView(){
        let photoCollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        photoCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        photoCollectionViewFlowLayout.minimumInteritemSpacing = 5.0
        
        photoCollectionView.collectionViewLayout = photoCollectionViewFlowLayout
    }
    
    func centralizePhotoCollectionView(){
        
        var totalPhotosCount: Int!
        
        if (editingBool == true){
            totalPhotosCount = photosArray.count + itemToEdit.photos.count + 1
        }
        else {
            totalPhotosCount = photosArray.count + 1
        }
        
        let viewWidth = CGFloat(photoCollectionView.frame.width * 1)
        let totalCellWidth = (photoCollectionView.frame.size.width/3) * CGFloat(totalPhotosCount);
        let totalSpacingWidth = 10 * CGFloat(totalPhotosCount - 1);
        
        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
        let rightInset = leftInset;
        
        photoCollectionViewLeadingConstraint = NSLayoutConstraint(item: photoCollectionView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 7)
        photoCollectionViewTrailingConstraint = NSLayoutConstraint(item: photoCollectionView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: 7)
        photoCollectionViewLeadingConstraint.constant = leftInset
        photoCollectionViewTrailingConstraint.constant = rightInset
        
        view.layoutIfNeeded()
    }
    
    
    //photos CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (editingBool){
            if(itemToEdit.photos[0] == ""){
                return ((itemToEdit.photos.count-1)+photosArray.count+1)
            }
            else {
                return ((itemToEdit.photos.count)+photosArray.count+1)
            }
        }
        else {
            return (photosArray.count+1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (editingBool){
            if(itemToEdit.photos.count+photosArray.count == 0){
                return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height);
            }
        }
        else {
            if (photosArray.count == 0){
                return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height);
            }
        }
        
        return CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.height);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PostPhotoCollectionViewCell
        
        
        if(editingBool){
            
            if(itemToEdit.photos[0] == ""){
                
                if((itemToEdit.photos.count-1)+photosArray.count == indexPath.item){
                    cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
                    cell.postCollectionViewCellImageView.backgroundColor = .white
                    cell.postCollectionViewCellImageView.layer.borderWidth = 0
                    cell.postCollectionViewCellImageView.layer.cornerRadius = 0
                    cell.contentMode = .scaleAspectFit
                }
                    
                else if(indexPath.item < (itemToEdit.photos.count-1)+photosArray.count){
                    
                    
                    if(indexPath.item < (itemToEdit.photos.count-1)){
                        cell.postCollectionViewCellImageView.sd_setImage(with:storageRef.child(itemToEdit.photos[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                        
                    else {
                        cell.postCollectionViewCellImageView.image = photosArray[(indexPath.item-(itemToEdit.photos.count-1))]
                    }
                    
                    cell.postCollectionViewCellImageView.layer.cornerRadius = 10
                    cell.postCollectionViewCellImageView.layer.borderWidth = 3.0
                    cell.postCollectionViewCellImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
                    cell.postCollectionViewCellImageView.layer.masksToBounds = true
                    cell.postCollectionViewCellImageView.clipsToBounds = true
                    cell.postCollectionViewCellImageView.contentMode = .scaleAspectFit
                    cell.postCollectionViewCellImageView.backgroundColor = .black
                }
            }
            else{
                if((itemToEdit.photos.count)+photosArray.count == indexPath.item){
                    cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
                    cell.postCollectionViewCellImageView.backgroundColor = .white
                    cell.postCollectionViewCellImageView.layer.borderWidth = 0
                    cell.postCollectionViewCellImageView.layer.cornerRadius = 0
                    cell.contentMode = .scaleAspectFit
                }
                    
                else if(indexPath.item < (itemToEdit.photos.count)+photosArray.count){
                    
                    
                    if(indexPath.item < (itemToEdit.photos.count)){
                        cell.postCollectionViewCellImageView.sd_setImage(with:storageRef.child(itemToEdit.photos[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))
                    }
                        
                    else {
                        cell.postCollectionViewCellImageView.image = photosArray[(indexPath.item-(itemToEdit.photos.count))]
                    }
                    
                    cell.postCollectionViewCellImageView.layer.cornerRadius = 10
                    cell.postCollectionViewCellImageView.layer.borderWidth = 3.0
                    cell.postCollectionViewCellImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
                    cell.postCollectionViewCellImageView.layer.masksToBounds = true
                    cell.postCollectionViewCellImageView.clipsToBounds = true
                    cell.postCollectionViewCellImageView.contentMode = .scaleAspectFit
                    cell.postCollectionViewCellImageView.backgroundColor = .black
                }
                
                
            }
        }
            
        else  {
            if(photosArray.count == indexPath.item){
                cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
                cell.postCollectionViewCellImageView.backgroundColor = .white
                cell.postCollectionViewCellImageView.contentMode = .scaleAspectFit
                cell.postCollectionViewCellImageView.layer.borderWidth = 0
                
            }
                
            else if(indexPath.item < photosArray.count){
                cell.postCollectionViewCellImageView.image = photosArray[indexPath.item]
                
                cell.postCollectionViewCellImageView.layer.cornerRadius = 10
                cell.postCollectionViewCellImageView.layer.borderWidth = 3.0
                cell.postCollectionViewCellImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
                cell.postCollectionViewCellImageView.layer.masksToBounds = true
                cell.postCollectionViewCellImageView.clipsToBounds = true
                cell.postCollectionViewCellImageView.contentMode = .scaleAspectFit
                cell.postCollectionViewCellImageView.backgroundColor = .black
                
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //if we are editing an existing post
        if (editingBool){
            
            if (itemToEdit.photos[0] == ""){
                //if we click on the plus picture
                if ((indexPath.item) + 1 > (self.photosArray.count + (itemToEdit.photos.count-1))){
                    presentImagePickerAlert()
                }
                    //else we click on an existing picture
                else {
                    let changePhotoAlert = UIAlertController(title: "View or Delete Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    var viewAction: UIAlertAction!
                    var changeAction: UIAlertAction!
                    
                    //if the picture was already existing
                    if(indexPath.item < (itemToEdit.photos.count-1)){
                        
                        viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                            //open photo
                            
                        })
                        
                        changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                            //
                            
                            self.itemToEdit.photos.remove(at: indexPath.item)
                            self.photoCollectionView.reloadData()
                        })
                    }
                        
                        //else if the picture was just added
                    else {
                        
                        viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                            //open photo
                            self.fullscreenImage(image: self.photosArray[indexPath.item - (self.itemToEdit.photos.count-1)])
                            
                        })
                        
                        changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                            
                            self.photosArray.remove(at: (indexPath.item-self.itemToEdit.photos.count-1))
                            self.photoCollectionView.reloadData()
                        })
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    
                    changePhotoAlert.addAction(viewAction)
                    changePhotoAlert.addAction(changeAction)
                    changePhotoAlert.addAction(cancelAction)
                    
                    self.present(changePhotoAlert, animated: true, completion: nil)
                }
            }
            else {
                //if we click on the plus picture
                if ((indexPath.item) + 1 > (self.photosArray.count + (itemToEdit.photos.count))){
                    presentImagePickerAlert()
                }
                    //else we click on an existing picture
                else {
                    let changePhotoAlert = UIAlertController(title: "View or Delete Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    var viewAction: UIAlertAction!
                    var changeAction: UIAlertAction!
                    
                    //if the picture was already existing
                    if(indexPath.item < (itemToEdit.photos.count)){
                        
                        viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                            //open photo
                            
                        })
                        
                        changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                            //
                            
                            self.itemToEdit.photos.remove(at: indexPath.item)
                            self.photoCollectionView.reloadData()
                        })
                    }
                        
                        //else if the picture was just added
                    else {
                        
                        viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                            //open photo
                            self.fullscreenImage(image: self.photosArray[indexPath.item - (self.itemToEdit.photos.count)])
                            
                        })
                        
                        changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                            
                            self.photosArray.remove(at: (indexPath.item-self.itemToEdit.photos.count))
                            self.photoCollectionView.reloadData()
                        })
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    
                    changePhotoAlert.addAction(viewAction)
                    changePhotoAlert.addAction(changeAction)
                    changePhotoAlert.addAction(cancelAction)
                    
                    self.present(changePhotoAlert, animated: true, completion: nil)
                }
            }
            
        }
            //else if we are creating a new post
        else {
            //if we click on the plus picture
            if ((indexPath.item) + 1 > self.photosArray.count){
                presentImagePickerAlert()
            }
                //else if we click on an image
            else {
                let changePhotoAlert = UIAlertController(title: "View or Delete Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                let viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                    self.fullscreenImage(image: self.photosArray[indexPath.item])
                })
                
                let changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                    self.photosArray.remove(at: indexPath.item)
                    self.photoCollectionView.reloadData()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                changePhotoAlert.addAction(viewAction)
                changePhotoAlert.addAction(changeAction)
                changePhotoAlert.addAction(cancelAction)
                
                self.present(changePhotoAlert, animated: true, completion: nil)
            }
        }
    }
}
