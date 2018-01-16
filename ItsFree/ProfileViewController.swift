//
//  ProfileViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-24.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var username:String = (AppData.sharedInstance.currentUser?.name)!
    var email:String = (AppData.sharedInstance.currentUser?.email)!
    var user:User = AppData.sharedInstance.currentUser!
    
    
    let storageRef = Storage.storage().reference()
   
    var photoRef = AppData.sharedInstance.currentUser?.profileImage

    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    
    
    @IBOutlet weak var myPostsButton: UIButton!
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfilePic(_ sender: Any) {
        presentImagePickerAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfilePicture()
        setUpProfileText()
        
        myPostsButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        myPostsButton.layer.borderWidth = 1
        myPostsButton.layer.cornerRadius = 5
        myPostsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        imagePicker.delegate = self
        
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
        
        
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
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/4.0
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 5.0
        profileImageView.sd_setImage(with: storageRef.child(photoRef!), placeholderImage: UIImage(named: "defaultProfile"))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("\n\ndidFinishPickingMediaWithInfo\n\n")
        myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if myImage != nil {
            print("image loaded: \(myImage!)")
        }
        
        let imagePath = ImageManager.uploadImage(image: myImage!, userUID: user.UID, filename: "profileImage")
        AppData.sharedInstance.usersNode.child(user.UID).child("profileImage").setValue(imagePath)
        profileImageView.image = myImage
        dismiss(animated: true, completion: nil)

    }
    
    func presentImagePickerAlert() {
        
        let photoSourceAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler:{ (action) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler:{ (action) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        photoSourceAlert.addAction(cameraAction)
        photoSourceAlert.addAction(photoLibraryAction)
        photoSourceAlert.addAction(cancelAction)
        
        self.present(photoSourceAlert, animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return (AppData.sharedInstance.currentUser?.offeredItems.count)!
        case 1:
            return (AppData.sharedInstance.currentUser?.requestedItems.count)!
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPostsTableViewCell", for: indexPath)
        
        
        var itemRef: String!
        var item: Item!
        var itemUID: String!
        
        
        if(indexPath.section == 0){
             itemRef = AppData.sharedInstance.currentUser?.offeredItems[indexPath.row]
            
            itemUID = String(itemRef.suffix(20))
            
                    item = AppData.sharedInstance.onlineOfferedItems.filter{ $0.UID == itemUID}.first!
        }
        else if(indexPath.section == 1){
             itemRef = AppData.sharedInstance.currentUser?.requestedItems[indexPath.row]
            
            itemUID = String(itemRef.suffix(20))
            
                    item = AppData.sharedInstance.onlineRequestedItems.filter{ $0.UID == itemUID}.first!
            
        }
       
    
        
        cell.textLabel?.text = item.name
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
}
