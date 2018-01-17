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
    
    
    @IBOutlet weak var offersRequestsSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var username:String = (AppData.sharedInstance.currentUser?.name)!
    var email:String = (AppData.sharedInstance.currentUser?.email)!
    var user:User = AppData.sharedInstance.currentUser!
    
    
    let storageRef = Storage.storage().reference()
   
    var photoRef = AppData.sharedInstance.currentUser?.profileImage

    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    
    var animateTable: Bool = false
    
    
  
    
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
        
//        myPostsButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
//        myPostsButton.layer.borderWidth = 1
//        myPostsButton.layer.cornerRadius = 5
//        myPostsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        imagePicker.delegate = self
        

        setupTableView()
        
        offersRequestsSegmentedControl.layer.borderWidth = 5.0
        offersRequestsSegmentedControl.layer.borderColor = UIColor.black.cgColor
        offersRequestsSegmentedControl.layer.cornerRadius = 5.0
        
        
        
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
    
    func setupTableView() {
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
        
        myPostsTableView.layer.borderColor = UIColor.black.cgColor
        myPostsTableView.layer.borderWidth = 5.0
        myPostsTableView.layer.cornerRadius = 5.0
        
    }
    
    func setUpProfilePicture() {
        let storageRef = Storage.storage().reference()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/4.0
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.black.cgColor
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
        switch offersRequestsSegmentedControl.selectedSegmentIndex {
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
        
        var item: Item!
        
        switch offersRequestsSegmentedControl.selectedSegmentIndex {
        case 0:
             item = AppData.sharedInstance.currentUserOfferedItems[indexPath.row]
        case 1:
             item = AppData.sharedInstance.currentUserRequestedItems[indexPath.row]
        default:
            item = nil
        }
       
        cell.textLabel?.text = item.name
        
        if (animateTable){
            UIView.transition(with: cell.textLabel!, duration: 0.6, options: .transitionCrossDissolve, animations: {
                cell.textLabel?.textColor = .black
            
            }, completion: nil)
        }
        
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        //selectedCell.contentView.backgroundColor = UIColor.green
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    func tableView(tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.white
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            switch offersRequestsSegmentedControl.selectedSegmentIndex {
            case 0: AppData.sharedInstance.currentUser?.offeredItems.remove(at: indexPath.row)
            case 1:
                AppData.sharedInstance.currentUser?.requestedItems.remove(at: indexPath.row)
                
            default:
                return
                
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    @IBAction func offersRequestsSegmentAction(_ sender: UISegmentedControl) {
        
        animateTable = true
        myPostsTableView.reloadData()
        animateTable = false
    }
    
}
