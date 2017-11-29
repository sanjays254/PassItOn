//
//  ProfileViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-24.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var username:String = "User's name"
    var email:String = "example@mail.com"
    var photoRef = "testUserUID/testImage"

    
    
    @IBOutlet weak var myPostsButton: UIButton!
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfilePicture()
        setUpProfileText()
        
        myPostsButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        myPostsButton.layer.borderWidth = 1
        myPostsButton.layer.cornerRadius = 5
        myPostsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpProfileText() {
        self.navigationItem.title = "My Profile"
        self.usernameLabel.text = username
        self.emailLabel.text = email
    }
    
    func setUpProfilePicture() {
        let storageRef = Storage.storage().reference()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 5.0
        profileImageView.sd_setImage(with: storageRef.child(photoRef))
    }

}
