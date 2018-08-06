//
//  ItemDetailView.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-23.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit

class ItemDetailView: UIView {
    
    @IBOutlet weak var collectionContentView: UIView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var posterUsername: UILabel!
    @IBOutlet weak var posterRating: UILabel!
    @IBOutlet weak var itemValueLabel: UILabel!
    
    @IBOutlet weak var rightUpArrow: UIImageView!
    
    @IBOutlet weak var leftUpArrow: UIImageView!
    
    @IBOutlet weak var messageButton: UIButton!
}
