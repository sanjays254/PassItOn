//
//  ProfileViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-24.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var offersRequestsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var myOfferedPostsImages: [UIImage]?
    var myRequestedPostsImages: [UIImage]?
    weak var usernameTextField: UITextField!
    weak var selectedItemToEdit: Item!
    var editingProfile: Bool!
    
    var username:String = (AppData.sharedInstance.currentUser?.name)!
    var email:String = (AppData.sharedInstance.currentUser?.email)!
    weak var user : User? = AppData.sharedInstance.currentUser
    
    let storageRef = Storage.storage().reference()
    var photoRef = AppData.sharedInstance.currentUser?.profileImage

    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    
    var tapGesture: UITapGestureRecognizer!
    
    var animateTable: Bool = false
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        editingProfile = false
        
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        self.backButton.layer.backgroundColor = UIColor.black.cgColor
        self.backButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.backButton.layer.masksToBounds = false
        
        editButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        self.editButton.layer.backgroundColor = UIColor.black.cgColor
        self.editButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.editButton.layer.masksToBounds = false
        
        setUpProfilePicture()
        setUpProfileText()
        setupTextFields()
        setupTableView()
        
        offersRequestsSegmentedControl.layer.borderWidth = 3.0
        offersRequestsSegmentedControl.layer.borderColor = UIColor.black.cgColor
        offersRequestsSegmentedControl.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        myPostsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTextFields(){
        usernameTextField = UITextField()
        usernameTextField.delegate = self
        self.view.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .top, relatedBy: .equal, toItem: profileImageView, attribute: .bottom , multiplier: 1, constant: 20)
        let bottomConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .bottom, relatedBy: .equal, toItem: emailLabel, attribute: .top , multiplier: 1, constant: -10)
        let centralizeConstraint = NSLayoutConstraint(item: usernameTextField, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 250)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, centralizeConstraint, widthConstraint])
        
        usernameTextField.isHidden = true
        usernameTextField.layer.borderWidth = 0.5
        usernameTextField.layer.borderColor = UIColor.gray.cgColor
        usernameTextField.layer.cornerRadius = 4
        usernameTextField.textAlignment = .center
        usernameTextField.autocorrectionType = .no
        usernameTextField.font = UIFont(name: "GillSans-Light", size: 25)
    }
    
    func setUpProfileText() {
        self.navigationItem.title = "Profile"
        self.usernameLabel.text = username
        self.emailLabel.text = email
        self.pointsLabel.text = String(AppData.sharedInstance.currentUser!.rating)
    }
    
    func setupTableView() {
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
        
        myPostsTableView.layer.borderColor = UIColor.black.cgColor
        myPostsTableView.layer.borderWidth = 3.0
    }
    
    func setUpProfilePicture() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.borderWidth = 5.0
        
        //profileImageView.image = AppData.sharedInstance.currentUserPhotos[(user?.profileImage)!]

        profileImageView.sd_setImage(with: storageRef.child(photoRef!), placeholderImage: UIImage(named: "defaultProfile"))
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfilePic(_ sender: Any) {
        presentImagePickerAlert()
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
              self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        if (editingProfile == false){
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.editButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.editButton.setImage(#imageLiteral(resourceName: "thumbsUp"), for: .normal)
            }, completion: nil)

            editingProfile = true
            
            usernameLabel.isHidden = true
            usernameTextField.isHidden = false
            usernameTextField.placeholder = username
        }
            
        else if (editingProfile == true){
            
            if (usernameTextField.text == ""){
                usernameLabel!.text = user?.name
            }

            else {
                user?.name = usernameTextField.text!
                usernameLabel.text = user?.name
                WriteFirebaseData.write(user: user!)
            }
            
            editingProfile = false
            
            usernameTextField.isHidden = true
            usernameLabel.isHidden = false
            textFieldDidEndEditing(usernameTextField)
            
            if(usernameTextField.isFirstResponder){
                dismissKeyboard(tapGesture)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.editButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.editButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
            }, completion: nil)
        }
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let imagePath = ImageManager.uploadImage(image: myImage!, userUID: (user?.UID)!, filename: "profileImage")
        
        AppData.sharedInstance.usersNode.child((user?.UID)!).child("profileImage").setValue(imagePath)
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
             return (AppData.sharedInstance.currentUser?.offeredItems.count)! + 1
        case 1:
            return (AppData.sharedInstance.currentUser?.requestedItems.count)! + 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPostsTableViewCell", for: indexPath) as! MyPostsTableViewCell
        
        //cell.translatesAutoresizingMaskIntoConstraints = false
        
        weak var item: Item!
        
        switch offersRequestsSegmentedControl.selectedSegmentIndex {
        case 0:
            if (indexPath.row == AppData.sharedInstance.currentUser?.offeredItems.count){
                cell.itemLabel.text = "Got something to offer?"
                cell.itemLabel.font = UIFont.italicSystemFont(ofSize: 16)
                //cell.itemImageView.isHidden = true
                cell.itemImageViewWidthConstraint.constant = 0
                cell.itemLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                cell.setNeedsLayout()
            }
            else {
             item = AppData.sharedInstance.currentUserOfferedItems[indexPath.row]
                cell.itemLabel?.text = item.name
                cell.itemLabel.font = UIFont(name: "GillSans", size: 20)
                cell.itemLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = false
                cell.itemImageViewWidthConstraint.constant = 77
                cell.itemImageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
                cell.setNeedsLayout()
            }
             //myOfferedPostsImages = ImageManager.downloadImage(imagePath: item.photos[0])
            
    
        case 1:
            if (indexPath.row == AppData.sharedInstance.currentUser?.requestedItems.count){
                cell.itemLabel.text = "Want something?"
                cell.itemLabel.font = UIFont.italicSystemFont(ofSize: 16)
                
                //cell.itemImageView.isHidden = true
                cell.itemImageViewWidthConstraint.constant = 0
               cell.itemLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                cell.setNeedsLayout()
            }
            else {
             item = AppData.sharedInstance.currentUserRequestedItems[indexPath.row]
                cell.itemLabel?.text = item.name
                cell.itemLabel.font = UIFont(name: "GillSans", size: 20)
                cell.itemLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = false
                cell.itemImageViewWidthConstraint.constant = 77
                cell.itemImageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
                cell.setNeedsLayout()
            }
             //myRequestedPostsImages = ImageManager.downloadImage(imagePath: item.photos[0])
      
        default:
            item = nil
        }
       
        
        
        
//        if let image = (AppData.sharedInstance.currentUserPhotos[item.photos[0]]) {
//            cell.itemImageView.image = image
//            cell.itemImageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
//        }
//        else  {
//            cell.itemImageView.image = #imageLiteral(resourceName: "placeholder")
//        }
        
        if (animateTable){
            UIView.transition(with: cell.textLabel!, duration: 0.6, options: .transitionCrossDissolve, animations: {
                cell.itemLabel?.textColor = .black
            
            }, completion: nil)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        
        switch offersRequestsSegmentedControl.selectedSegmentIndex {
        case 0:
            if (indexPath.row == AppData.sharedInstance.currentUser?.offeredItems.count){
                performSegue(withIdentifier: "newPostSegue", sender: self)
            }
            else {
                selectedItemToEdit = AppData.sharedInstance.currentUserOfferedItems[indexPath.row]
            }
            
        case 1:
            if (indexPath.row == AppData.sharedInstance.currentUser?.offeredItems.count){
                performSegue(withIdentifier: "newPostSegue", sender: self)
            }
            else {
            selectedItemToEdit = AppData.sharedInstance.currentUserRequestedItems[indexPath.row]
            }
            
        default:
            selectedItemToEdit = nil
        }
        performSegue(withIdentifier: "editPostSegue", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editPostSegue"){
            let destinationPostVC = segue.destination as! PostViewController
            destinationPostVC.itemToEdit = selectedItemToEdit
            destinationPostVC.editingBool = true
            destinationPostVC.offerRequestIndex = offersRequestsSegmentedControl.selectedSegmentIndex
        }
        
        if (segue.identifier == "newPostSegue"){
            let destinationPostVC = segue.destination as! PostViewController
    
            destinationPostVC.editingBool = false
            destinationPostVC.offerRequestIndex = offersRequestsSegmentedControl.selectedSegmentIndex
        }
    }

    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.white
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var itemUID: String
            
            switch offersRequestsSegmentedControl.selectedSegmentIndex {
            case 0:
                itemUID = AppData.sharedInstance.currentUserOfferedItems[indexPath.row].UID
                WriteFirebaseData.delete(itemUID: itemUID)
                
            case 1:
                itemUID = AppData.sharedInstance.currentUserRequestedItems[indexPath.row].UID
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (tapGesture != nil){
            self.view.removeGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        usernameTextField.isHidden = true
        
        if(usernameTextField.text == ""){
            usernameLabel.text = user?.name
        }
        else {
            user?.name = usernameTextField.text!
            usernameLabel.text = user?.name
        }
        
        usernameLabel.isHidden = false
        editingProfile = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            self.editButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.editButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        }, completion: nil)
        
        
        WriteFirebaseData.write(user: user!)
    }
    
    func saveUserData(){
        
        WriteFirebaseData.write(user: user!)
    }
    
}
