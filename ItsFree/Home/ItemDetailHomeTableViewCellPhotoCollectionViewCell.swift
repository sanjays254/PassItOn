//
//  ItemDetailHomeTableViewCellPhotoCollectionViewCell.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-05.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class ItemDetailHomeTableViewCellPhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = 5
        
    }

}
