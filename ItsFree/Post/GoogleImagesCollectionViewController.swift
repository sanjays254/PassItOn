//
//  GoogleImagesCollectionViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class GoogleImagesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var googleImagesArray: [URL]!
    
    override func viewDidLoad(){
        
        
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 5
        //layout.minimumLineSpacing = 100000
        layout.scrollDirection = .horizontal
        
        let promptLabel = UILabel()
        promptLabel.text = "Or select some based on your title:"
        promptLabel.font = UIFont(name: "Avenir-Light", size: 15)
        view.addSubview(promptLabel)
        
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let labelXConstraint = NSLayoutConstraint(item: promptLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let labelTopConstraint = NSLayoutConstraint(item: promptLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 10)
        let labelHeightConstraint = NSLayoutConstraint(item: promptLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        
        NSLayoutConstraint.activate([labelXConstraint, labelTopConstraint, labelHeightConstraint])
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
         collectionView.register(UINib(nibName: "GoogleImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "googleImageCellId")
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: promptLabel.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        
        googleImagesArray = []
        
        
        view.layoutIfNeeded()
        
       

   
    
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        
//    }
//    
//    
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return googleImagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "googleImageCellId", for: indexPath) as! GoogleImageCollectionViewCell
        
        cell.imageView.backgroundColor = .black
        let selectedView = UIView(frame: cell.frame)
        let checkedImageView = UIImageView(frame: selectedView.frame)
        checkedImageView.image = #imageLiteral(resourceName: "tick")
        
        cell.selectedBackgroundView = selectedView
        
        cell.imageView.layer.cornerRadius = 10
        cell.imageView.layer.borderWidth = 3.0
        cell.imageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.contentMode = .scaleAspectFit
        
        cell.imageView.sd_setImage(with: googleImagesArray[indexPath.item])
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        //add this photo to photosArray
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            cell.isSelected = true
        
            let tickImageView = UIImageView.init(image: #imageLiteral(resourceName: "tick"))
        
            cell.contentView.addSubview(tickImageView)
            tickImageView.center = cell.contentView.center
            
            
            ReadGoogleImages.convertURLintoImage(url: googleImagesArray[indexPath.item], completion: {(image, success) in
                
                if (success){
                    if let postVC = self.parent as? PostViewController {
                        //force unwrapping wont cause crash because success bool is only true if image exists
                        postVC.photosArray.append(image!)
                        
//                        DispatchQueue.main.async {
//                               postVC.photoCollectionView.reloadData()
//                        }
                     
                    }
                    
                }
                else {
                    
                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Hmmm", inpMessage: "This image could not be added to your post", inpOkTitle: "Try another")
                    
                    cell.isSelected = false
                }
                
            })
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //remove from photosArray
        collectionView.cellForItem(at: indexPath)?.isSelected = false
        
        if let subviews = collectionView.cellForItem(at: indexPath)?.contentView.subviews {
            
            //there will only be 2 subviews ever
            //at index0, will be the actual image
            //at index1, will be the tick, if its been selected
            subviews[1].removeFromSuperview()
        }
    }
    
    
}
