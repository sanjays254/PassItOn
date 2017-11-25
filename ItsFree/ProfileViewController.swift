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

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let storageRef = Storage.storage().reference()
//        let photoRef = "testUserUID/testImage"
        
        // Do any additional setup after loading the view.
        setUpProfilePicture()
        setUpProfileText()
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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
