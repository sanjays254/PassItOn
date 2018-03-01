//
//  MyPostsTableViewCell.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-01-17.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class MyPostsTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemImageView.layer.borderWidth = 4.0
        itemImageView.layer.borderColor = UIColor.black.cgColor
        itemImageView.layer.cornerRadius = 4.0
        itemImageView.clipsToBounds = true
        itemImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
