//
//  ItemHomeTableViewCell.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-20.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit

class ItemHomeTableViewCell: UITableViewCell {    
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemQualityLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImageView.layer.masksToBounds = true
        itemImageView.layer.borderColor = UIColor.black.cgColor
        itemImageView.layer.borderWidth = 3
        itemImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
