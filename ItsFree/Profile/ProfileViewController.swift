//
//  ProfileViewController.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-24.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage
import ChatSDK


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    let myDowloadCompletedNotificationKey = "myUserDownloadNotificationKey"

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var leaderboardButton: UIButton!
    
    @IBOutlet weak var conversationsButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var offersRequestsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var myOfferedPostsImages: [UIImage]?
    var myRequestedPostsImages: [UIImage]?
    weak var usernameTextField: UITextField!
    weak var phoneNumberTextField: UITextField!
    weak var selectedItemToEdit: Item!
    var editingProfile: Bool!
    
    var username:String = (AppData.sharedInstance.currentUser?.name)!
    var email:String = (AppData.sharedInstance.currentUser?.email)!
    var phoneNumber: Int = (AppData.sharedInstance.currentUser?.phoneNumber)!
    var user : User? = AppData.sharedInstance.currentUser
    
    var storageRef = Storage.storage().reference()
    var photoRef = AppData.sharedInstance.currentUser?.profileImage

    let imagePicker = UIImagePickerController()
    weak var myImage:UIImage?
    
    var tapGesture: UITapGestureRecognizer!
    
    var animateTable: Bool = false
    
    var logoutDelegate: LoggedOutDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(setUpProfileText), name: NSNotification.Name(rawValue: myDowloadCompletedNotificationKey), object: nil)
        
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
        
        logoutButton.setImage(#imageLiteral(resourceName: "logout"), for: .normal)
        self.logoutButton.imageView?.transform = CGAffineTransform(rotationAngle: (CGFloat.pi))
        self.logoutButton.layer.backgroundColor = UIColor.black.cgColor
        self.logoutButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.logoutButton.layer.masksToBounds = false
        
        leaderboardButton.setImage(#imageLiteral(resourceName: "wreath"), for: .normal)
        self.leaderboardButton.layer.backgroundColor = UIColor.black.cgColor
        self.leaderboardButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.leaderboardButton.layer.masksToBounds = false
        
        conversationsButton.setImage(#imageLiteral(resourceName: "conversations"), for: .normal)
        self.conversationsButton.layer.backgroundColor = UIColor.black.cgColor
        self.conversationsButton.layer.cornerRadius = self.backButton.frame.size.width/2
        self.conversationsButton.layer.masksToBounds = false
        

        ReadFirebaseData.readCurrentUser()
        
        setUpProfilePicture()
        setUpProfileText()
        setupTextFields()
        setupTableView()
        
        offersRequestsSegmentedControl.layer.borderWidth = 3.0
        offersRequestsSegmentedControl.layer.borderColor = UIColor.black.cgColor
        offersRequestsSegmentedControl.layer.cornerRadius = 4.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        myPostsTableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTextFields(){
        usernameTextField = UITextField()
        usernameTextField.delegate = self
        self.view.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: usernameTextField, attribute: .top, relatedBy: .equal, toItem: profileImageView, attribute: .bottom , multiplier: 1, constant: 19)
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
        
        
        phoneNumberTextField = UITextField()
        phoneNumberTextField.delegate = self
        phoneNumberTextField.keyboardType = .namePhonePad
        self.view.addSubview(phoneNumberTextField)
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let topPNConstraint = NSLayoutConstraint(item: phoneNumberTextField, attribute: .top, relatedBy: .equal, toItem: emailLabel, attribute: .bottom , multiplier: 1, constant: 12)
        let bottomPNConstraint = NSLayoutConstraint(item: phoneNumberTextField, attribute: .bottom, relatedBy: .equal, toItem: pointsLabel, attribute: .top , multiplier: 1, constant: -18)
        let centralizePNConstraint = NSLayoutConstraint(item: phoneNumberTextField, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let widthPNConstraint = NSLayoutConstraint(item: phoneNumberTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1, constant: 180)
        
        NSLayoutConstraint.activate([topPNConstraint, bottomPNConstraint, centralizePNConstraint, widthPNConstraint])
        
        phoneNumberTextField.isHidden = true
        phoneNumberTextField.layer.borderWidth = 0.5
        phoneNumberTextField.layer.borderColor = UIColor.gray.cgColor
        phoneNumberTextField.layer.cornerRadius = 4
        phoneNumberTextField.textAlignment = .center
        phoneNumberTextField.autocorrectionType = .no
        phoneNumberTextField.font = UIFont(name: "GillSans-Light", size: 20)
        
    }
    
    @objc func setUpProfileText() {
        self.navigationItem.title = "Profile"
        self.usernameLabel.text = username
        self.emailLabel.text = email
        
        if(phoneNumber == 0){
            self.phoneNumberLabel.text = "Add Phone Number"
            self.phoneNumberLabel.font = UIFont(name: "GillSans-LightItalic", size: 20)
        }
        else {
            self.phoneNumberLabel.text = String(phoneNumber)
            self.phoneNumberLabel.font = UIFont(name: "GillSans-Light", size: 20)
        }
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
        
        storageRef = Storage.storage().reference()
     
        profileImageView.sd_setImage(with: URL(string: (user?.profileImage)!), placeholderImage: #imageLiteral(resourceName: "userPlaceholder"), options: .refreshCached, completed: nil)
    
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
    
    @IBAction func leaderboardButton(_ sender: UIButton) {
    
        performSegue(withIdentifier: "leaderboardSegue", sender: self)
    }
    
    @IBAction func conversationsButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "conversationsSegue", sender: self)
        
    }
    
    
    @IBAction func logout(_ sender: UIButton) {
        
        let logoutAlert = UIAlertController(title: "Sure?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Yes, Log out", style: .destructive, handler: { (alert: UIAlertAction!) in
            
            self.dismiss(animated: true, completion: nil)

            self.logoutDelegate.goToLoginVC()
            
            //to stop touchID prompt when we go back to loginVC
            UserDefaults.standard.set(false, forKey: "useTouchID")
            
            AppData.sharedInstance.currentUser = nil
            AppData.sharedInstance.currentUserOfferedItems = []
            AppData.sharedInstance.currentUserRequestedItems = []
            loggedInBool = false
            
          
            
        })
        
        let cancelAction = UIAlertAction(title: "No, stay logged in", style: .cancel, handler: nil)
        
        logoutAlert.addAction(logoutAction)
        logoutAlert.addAction(cancelAction)
        
        present(logoutAlert, animated: true, completion: nil)
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
            
            phoneNumberLabel.isHidden = true
            phoneNumberTextField.isHidden = false
            if(phoneNumber == 0){
                phoneNumberTextField.placeholder = "xxx xxx xxxx"
            }
            else {
                phoneNumberTextField.placeholder = String(phoneNumber)
            }
        }
            
        else if (editingProfile == true){
            
            if (usernameTextField.text == ""){
                usernameLabel!.text = user?.name
            }

            else {
                user?.name = usernameTextField.text!
                usernameLabel.text = user?.name
                WriteFirebaseData.write(user: user!, completion: {(success) in
                    
                    if (success){
                        
                        BusyActivityView.hide()
                        
                    }
                    else {
                        
                        
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Couldn't change your details", inpOkTitle: "Try again")
                        
                        BusyActivityView.hide()
                        
                    }
                    
                })
            }
            
            if (phoneNumberTextField.text == ""){
                if (user?.phoneNumber == 0){
                    phoneNumberLabel.text = "Add Phone Number"
                    self.phoneNumberLabel.font = UIFont(name: "GillSans-LightItalic", size: 20)
                }
                else {
                    phoneNumberLabel!.text = String((user?.phoneNumber)!)
                    phoneNumberLabel.font = UIFont(name: "GillSans-Light", size: 20)
                }
            }
                
            else {
                user?.phoneNumber = Int(phoneNumberTextField.text!)!
                phoneNumberLabel.text = String((user?.phoneNumber)!)
                WriteFirebaseData.write(user: user!, completion: {(success) in
                    
                    if (success){
                        
                        BusyActivityView.hide()
                        
                    }
                    else {
                        
                        
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Couldn't change your details", inpOkTitle: "Try again")
                        
                        BusyActivityView.hide()
                        
                    }
                    
                })
            }
            
            editingProfile = false
            
            usernameTextField.isHidden = true
            usernameLabel.isHidden = false
            textFieldDidEndEditing(usernameTextField)
            
            phoneNumberTextField.isHidden = true
            phoneNumberLabel.isHidden = false
            textFieldDidEndEditing(phoneNumberTextField)
            
            if(usernameTextField.isFirstResponder){
                dismissKeyboard(tapGesture)
            }
            if(phoneNumberTextField.isFirstResponder){
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
        
        BusyActivityView.show(inpVc: self)
        
        ImageManager.uploadUserProfileImage(image: myImage!, userUID: (user?.UID)!, completion: {(success, path) in
        
            if (success){
                AppData.sharedInstance.usersNode.child((self.user?.UID)!).child("profileImage").setValue(path, withCompletionBlock: {(error, ref) in
                    
                    if (error == nil){
                        //https://firebasestorage.googleapis.com/v0/b/itsfree-fce29.appspot.com/o/HjlZ3CaBZGQbha33p5CLoLwMEFs2%2FprofileImage?alt=media&token=0189daca-cbcc-49f6-adf9-962454555eaa
                        
                        DispatchQueue.main.async {
                            
                        //need to clear this cached image
                        //USE DOWNLOAD WITH URL WITH OPTIONS!!!
                            self.profileImageView.sd_setImage(with: URL(string: path!), placeholderImage: self.myImage, options: .refreshCached, completed: nil)
                            
                            //self.profileImageView.image = self.myImage
                            
                           // self.profileImageView.sd_setImage
                           // self.profileImageView.sd_setImage(with: self.storageRef.child((AppData.sharedInstance.currentUser?.profileImage)!), placeholderImage: self.myImage)
                           
                        }
                        
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Success", inpMessage: "Your profile picture was updated", inpOkTitle: "Ok")
                        
                        BusyActivityView.hide()
                        
                    }
                    else {
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your profile picture didnt get saved", inpOkTitle: "Try again")
                        
                        BusyActivityView.hide()
                        
                    }
                    
                })
            }
            else {
                
                //error
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your new profile picture was uploaded, but there was error in your account", inpOkTitle: "Try again")
                
                BusyActivityView.hide()
                
            }
            
            
        })
        
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
        
       
        
        switch offersRequestsSegmentedControl.selectedSegmentIndex {
        case 0:
            if (indexPath.row == AppData.sharedInstance.currentUser?.offeredItems.count){
                cell.itemLabel.text = "Got something to offer?"
                cell.itemLabel.font = UIFont.italicSystemFont(ofSize: 16)
                cell.itemImageView.isHidden = true
                cell.itemImageViewWidthConstraint.constant = 0
                cell.setNeedsLayout()
            }
            else {
                let item = AppData.sharedInstance.currentUserOfferedItems[indexPath.row]
                cell.itemLabel?.text = item.name
                cell.itemLabel.font = UIFont(name: "GillSans", size: 20)
                cell.itemImageViewWidthConstraint.constant = 77
                storageRef = Storage.storage().reference()
                cell.itemImageView.isHidden = false
                cell.itemImageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
                cell.setNeedsLayout()
            }
            
        case 1:
            if (indexPath.row == AppData.sharedInstance.currentUser?.requestedItems.count){
                cell.itemLabel.text = "Want something?"
                cell.itemLabel.font = UIFont.italicSystemFont(ofSize: 16)
                cell.itemImageView.isHidden = true
                cell.itemImageViewWidthConstraint.constant = 0
                cell.setNeedsLayout()
            }
            else {
                let item = AppData.sharedInstance.currentUserRequestedItems[indexPath.row]
                cell.itemLabel?.text = item.name
                cell.itemLabel.font = UIFont(name: "GillSans", size: 20)
                //cell.itemLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = false
                cell.itemImageViewWidthConstraint.constant = 77
                cell.itemImageView.isHidden = false
                cell.itemImageView?.sd_setImage(with: storageRef.child(item.photos[0]), placeholderImage: UIImage.init(named: "placeholder"))
                cell.setNeedsLayout()
            }
      
        default:
            return cell
            
        }
       
        
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
                 performSegue(withIdentifier: "editPostSegue", sender: self)
            }
            
        case 1:
            if (indexPath.row == AppData.sharedInstance.currentUser?.offeredItems.count){
                performSegue(withIdentifier: "newPostSegue", sender: self)
            }
            else {
            selectedItemToEdit = AppData.sharedInstance.currentUserRequestedItems[indexPath.row]
                 performSegue(withIdentifier: "editPostSegue", sender: self)
            }
            
        default:
            selectedItemToEdit = nil
        }
       
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
            
            BusyActivityView.show(inpVc: self)
            
            switch offersRequestsSegmentedControl.selectedSegmentIndex {
            case 0:
                itemUID = AppData.sharedInstance.currentUserOfferedItems[indexPath.row].UID
                WriteFirebaseData.delete(itemUID: itemUID, completion: {(success) in
                    
                    BusyActivityView.hide()
                    
                    if (success){
                        
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Done", inpMessage: "Your item was successfully deleted", inpOkTitle: "Ok")
                    }
                    else {
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your item could not be deleted", inpOkTitle: "Try again later")
                    }
                    
                })
                
            case 1:
                itemUID = AppData.sharedInstance.currentUserRequestedItems[indexPath.row].UID
                WriteFirebaseData.delete(itemUID: itemUID, completion: {(success) in
                    
                    BusyActivityView.hide()
                    
                    if (success){
                        
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Done", inpMessage: "Your item was successfully deleted", inpOkTitle: "Ok")
                    
                    }
                    else {
                        Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Your item could not be deleted", inpOkTitle: "Try again later")
                    }
                })
                
            default:
                return
            }
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
        
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.isHidden = true
        
        if(usernameTextField.text == ""){
            usernameLabel.text = user?.name
        }
        else {
            user?.name = usernameTextField.text!
            usernameLabel.text = user?.name
        }
        
        if(phoneNumberTextField.text == ""){
            if(user?.phoneNumber == 0){
                self.phoneNumberLabel.text = "Add Phone Number"
                self.phoneNumberLabel.font = UIFont(name: "GillSans-LightItalic", size: 20)
            }
            else {
                phoneNumberLabel.text = String((user?.phoneNumber)!)
                phoneNumberLabel.font = UIFont(name: "GillSans-Light", size: 20)
            }
        }
        else {
            user?.phoneNumber = Int(phoneNumberTextField.text!)!
            phoneNumberLabel.text = String((user?.phoneNumber)!)
        }
        
        usernameLabel.isHidden = false
        phoneNumberLabel.isHidden = false
        editingProfile = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            self.editButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.editButton.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        }, completion: nil)
        
        BusyActivityView.show(inpVc: self)
        
        WriteFirebaseData.write(user: user!, completion: {(success) in
            
            if (success){
                BusyActivityView.hide()
            }
            else {
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Couldn't change your details", inpOkTitle: "Try again")
                
                BusyActivityView.hide()
                
            }
        })
    }
    
    func saveUserData(){
        
        WriteFirebaseData.write(user: user!, completion: {(success) in
            
            if (success){
                BusyActivityView.hide()
            }
            else {
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Error", inpMessage: "Couldn't change your details", inpOkTitle: "Try again")
                
                BusyActivityView.hide()
            }
        })
    }
    
}
