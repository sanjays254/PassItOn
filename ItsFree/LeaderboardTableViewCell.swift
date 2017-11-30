//
//  LeaderboardTableViewCell.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-27.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
