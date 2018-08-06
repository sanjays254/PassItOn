//
//  ItemDetailHomeTableViewCell.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-04.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit
import Firebase
import MapKit



class ItemDetailHomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var homeMapDelegate: HomeMarkerSelectionDelegate!
    var itemActionDelegate: ItemActionDelegate!
    
    var homeVC: HomeViewController!
    
    var poster: User?
    var currentItem: Item!
    
    var storageRef: StorageReference!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var qualityLabel: UILabel!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var posterNameLabel: UILabel!
    
    @IBOutlet weak var posterRatingLabel: UILabel!
    
    
    @IBOutlet weak var messagePosterButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        storageRef = Storage.storage().reference()
    
        messagePosterButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        locationButton.addTarget(self, action: #selector(showItemOnMap), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCollectionView(){
        
        photoCollectionView.register(UINib(nibName: "ItemDetailHomeTableViewCellPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "itemDetailTVCPhotoCVCId")
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    
        
        photoCollectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentItem.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemDetailTVCPhotoCVCId", for: indexPath) as! ItemDetailHomeTableViewCellPhotoCollectionViewCell
    
        let photoRef: [String] = currentItem.photos
        
//        cell.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
//        cell.layer.borderWidth = 5.0
//        cell.layer.cornerRadius = 5.0
        
        cell.imageView.sd_setImage(with: storageRef.child(photoRef[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoRef: [String] = currentItem.photos
        itemActionDelegate.fullscreenImage(imagePath: photoRef[indexPath.item], inpVC: homeVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: photoCollectionView.frame.width, height: photoCollectionView.frame.width*0.8)
        
    }
    

    @objc func showItemOnMap(){

        homeMapDelegate.selectMarker(item: currentItem)
        
    }
    

    
    @objc func sendMessage(){
        
        if let poster = poster {
        
        itemActionDelegate.sendPosterMessage(inpVC: homeVC, currentItem: currentItem, destinationUser: poster)
        }
        
        
        
    }
    
}
