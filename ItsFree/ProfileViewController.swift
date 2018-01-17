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

    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
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
    
    
    @IBAction func backButton(_ sender: UIButton) {
              self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        self.backButton.layer.backgroundColor = UIColor.black.cgColor
        self.backButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.backButton.layer.masksToBounds = false
        //self.backButton.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        //self.backButton.layer.shadowColor = (UIColor.black).cgColor
        //self.backButton.layer.shadowOpacity = 0.5
        
        editButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        self.editButton.layer.backgroundColor = UIColor.black.cgColor
        self.editButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.editButton.layer.masksToBounds = false
        
        
        
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
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.masksToBounds = false
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
        cell.imageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
        
        
        cell.imageView?.layer.borderWidth = 4.0
        cell.imageView?.layer.borderColor = UIColor.black.cgColor
        cell.imageView?.layer.cornerRadius = 4.0
        cell.imageView?.clipsToBounds = true
        //cell.imageView?.frame.size.width =
        

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
            
            var itemUID: String
            
            switch offersRequestsSegmentedControl.selectedSegmentIndex {
            case 0:
                                itemUID = AppData.sharedInstance.currentUserOfferedItems[indexPath.row].UID
                AppData.sharedInstance.currentUserOfferedItems.remove(at: indexPath.row)
 
                WriteFirebaseData.delete(itemUID: itemUID)
                
            case 1:
                
                itemUID = AppData.sharedInstance.currentUserOfferedItems[indexPath.row].UID

            AppData.sharedInstance.currentUserRequestedItems.remove(at: indexPath.row)
                
            
            WriteFirebaseData.delete(itemUID: itemUID)
                
                
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
