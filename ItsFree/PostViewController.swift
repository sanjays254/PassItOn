 //
//  PostViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorage
import CoreLocation

class PostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var customTagTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var addCustomTagButton: UIButton!
    @IBOutlet weak var tagButtonView: UIView!
    @IBOutlet weak var defaultTagStackView: UIStackView!
    @IBOutlet weak var customTagStackView: UIStackView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var chosenQuality: ItemQuality!
    var chosenTagsArray: [String] = []
    var chosenCategory: ItemCategory!
    
    var categoryCount: Int!
    var categoryTableView: UITableView!
    let cellID: String = "categoryCellID"
    
    public var selectedLocationString: String = ""
    public var selectedLocationCoordinates: CLLocationCoordinate2D!
    
    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    var photosArray: Array<UIImage>!
    
    var tapGesture: UITapGestureRecognizer!
    
    var offerRequestSegmentedControl: UISegmentedControl!
    var offerRequestIndex: Int!
    
    var editingBool: Bool = false
    var itemToEdit: Item!
    
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupOfferRequestSegmentedControl()
        checkIfEditing()
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        descriptionTextField.textColor = .lightGray
        descriptionTextField.text = "Description"
        customTagTextField.delegate = self
        valueTextField.delegate = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePicker.delegate = self
        
        photosArray = []
    }
    
    func setupUI(){
        
        titleTextField.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 4.0
        
        descriptionTextField.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.cornerRadius = 4.0
        
        customTagTextField.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        customTagTextField.layer.borderWidth = 1.0
        customTagTextField.layer.cornerRadius = 4.0
        
        valueTextField.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        valueTextField.layer.borderWidth = 1.0
        valueTextField.layer.cornerRadius = 4.0
        
        
        categoryTableView = UITableView(frame: CGRect(x: 0, y:0, width: self.view.frame.width, height: (self.view.frame.height-((self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height))), style: UITableViewStyle.plain)
        
        addCustomTagButton.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        
        qualitySegmentedControl.tintColor = UIProperties.sharedUIProperties.purpleColour
        qualitySegmentedControl.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        qualitySegmentedControl.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        qualitySegmentedControl.layer.borderWidth = 1.0
        
        qualitySegmentedControl.layer.cornerRadius = 4.0
        
        addCategoryButton.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        addCategoryButton.setTitleColor(UIProperties.sharedUIProperties.purpleColour, for: .normal)
        
        addCategoryButton.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        addCategoryButton.layer.borderWidth = 1
        addCategoryButton.layer.cornerRadius = 5
        addCategoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        locationButton.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        locationButton.setTitleColor(UIProperties.sharedUIProperties.purpleColour, for: .normal)
        locationButton.layer.borderColor = UIProperties.sharedUIProperties.purpleColour.cgColor
        locationButton.layer.borderWidth = 1
        locationButton.layer.cornerRadius = 5
        locationButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        let photoCollectionViewFlowLayout = UICollectionViewFlowLayout()

        photoCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        photoCollectionViewFlowLayout.minimumInteritemSpacing = 5.0
        
        photoCollectionView.collectionViewLayout = photoCollectionViewFlowLayout
        
        setupOfferRequestSegmentedControl()
        setupTagButtonsView()
    }
    
    func checkIfEditing(){
        if (editingBool){
            titleTextField.text = itemToEdit.name
            descriptionTextField.text = itemToEdit.itemDescription
            chosenTagsArray = itemToEdit.tags.tagsArray
            qualitySegmentedControl.selectedSegmentIndex = ItemQuality.itemQualityIndex(quality: itemToEdit.quality)
            addCategoryButton.setTitle("Category: \(itemToEdit.itemCategory.rawValue)", for: .normal)
            chosenCategory = itemToEdit.itemCategory
            locationButton.setTitle("Location: \(String(describing: itemToEdit!.coordinate))", for: .normal)
            offerRequestSegmentedControl.selectedSegmentIndex = offerRequestIndex
            //valueTextField.text = itemToEdit.value
            
            for tag in itemToEdit.tags.tagsArray {
                addCustomTag(string: tag)
            }
            
            findLocationStringFromCoordinates(item: itemToEdit)
        }
    }
    
    
    fileprivate func setupOfferRequestSegmentedControl() {
        offerRequestSegmentedControl = UISegmentedControl()
        offerRequestSegmentedControl.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        offerRequestSegmentedControl.insertSegment(withTitle: "Offer", at: 0, animated: true)
        offerRequestSegmentedControl.insertSegment(withTitle: "Request", at: 1, animated: true)
        self.navigationItem.titleView = offerRequestSegmentedControl
    }
    
    
    func setupTagButtonsView(){
        
        let defaultTags = ["mom", "student", "ubc", "nike", "hiker"]
        
        for defaultTag in defaultTags {
            
            let currentButton = UIButton(frame: CGRect(x: 5, y: 8, width: 50, height: 20))
            
            currentButton.setTitle(defaultTag, for: .normal)
            currentButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            currentButton.addTarget(self, action: #selector(addOrRemoveThisDefaultTag), for: UIControlEvents.touchUpInside)
            
            currentButton.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.light)
            currentButton.sizeToFit()
            
            currentButton.layer.borderWidth = 1
            currentButton.layer.borderColor = UIColor.gray.cgColor
            currentButton.layer.cornerRadius = 10
            
            defaultTagStackView.addArrangedSubview(currentButton)
        }
        
        defaultTagStackView.alignment = .center
        defaultTagStackView.spacing = 1
        defaultTagStackView.distribution = .fillProportionally
        
        customTagStackView.alignment = .leading
        customTagStackView.spacing = 1
        customTagStackView.distribution = .fillProportionally
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationButton.setTitle("Location: \(self.selectedLocationString)", for: UIControlState.normal)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func openCategories(_ sender: UIButton) {
        
        self.view.addSubview(categoryTableView)
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.view.bringSubview(toFront: categoryTableView)
    }
    
    func findLocationStringFromCoordinates(item: Item){
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude), completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks!.count > 0) {
                let pm = placemarks![0]
                
                if(pm.thoroughfare != nil && pm.subThoroughfare != nil){
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    
                    self.locationButton.setTitle("Location: \(pm.thoroughfare ?? "Unknown Place"), \(pm.subThoroughfare ?? "Unknown Place")", for: UIControlState.normal)
                    
                }
                else if(pm.subThoroughfare != nil) {
                    
                    self.locationButton.setTitle("Location: \(pm.thoroughfare ?? "Unknown Place"), \(pm.subLocality ?? "Unknown Place")", for: UIControlState.normal)
                }
                    
                else {
                    self.locationButton.setTitle("Location: Unknown Place", for: UIControlState.normal)
                }
            }
            else {
                self.locationButton.setTitle("Location: Unknown Place", for: UIControlState.normal)
            }
        })
    }
    
    //imagePicker Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if myImage != nil {
            print("image loaded: \(myImage!)")
        }
        photosArray.append(myImage!)
        dismiss(animated: true, completion: nil)
        photoCollectionView.reloadData()
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
    
    func addCustomTag(string: String){
        
        if (string != ""){
            
            let newButton = UIButton(frame: CGRect(x: 5, y: 8, width: 50, height: 20))
            
            newButton.setTitle(string, for: .normal)
            newButton.setTitleColor(UIProperties.sharedUIProperties.whiteColour, for: UIControlState.normal)
            newButton.addTarget(self, action: #selector(addOrRemoveThisDefaultTag), for: UIControlEvents.touchUpInside)
            
            newButton.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.light)
            newButton.sizeToFit()
            
            newButton.backgroundColor = UIProperties.sharedUIProperties.purpleColour
            newButton.layer.borderWidth = 1
            newButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
            newButton.layer.cornerRadius = 10
            
            customTagStackView.addArrangedSubview(newButton)
            
            chosenTagsArray.append(string)
            
            customTagTextField.resignFirstResponder()
            customTagTextField.text = ""
        }
    }
    
    @IBAction func addCustomTagButton(_ sender: UIButton) {
        
        let newCustomTag =  customTagTextField.text
        addCustomTag(string: newCustomTag!)
    }
    
    @objc func addOrRemoveThisDefaultTag(sender: UIButton){
        
        if(sender.titleColor(for: UIControlState.normal) == UIColor.gray){
            
            sender.setTitleColor(UIProperties.sharedUIProperties.whiteColour, for: UIControlState.normal)
            sender.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
            sender.backgroundColor = UIProperties.sharedUIProperties.purpleColour
            
            chosenTagsArray.append((sender.titleLabel?.text)!)
        }
            
        else if(sender.titleColor(for: UIControlState.normal) == UIProperties.sharedUIProperties.whiteColour){
            
            sender.setTitleColor(UIColor.gray, for: UIControlState.normal)
            sender.layer.borderColor = UIColor.gray.cgColor
            sender.backgroundColor = UIProperties.sharedUIProperties.whiteColour
            
            chosenTagsArray.remove(at:chosenTagsArray.index(of:((sender.titleLabel?.text)!))!)
        }
    }
    
    //category chooser table views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: cellID)!
        cell.textLabel?.text = ItemCategory.stringValue(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        self.addCategoryButton.setTitle("Category: \(cell.textLabel?.text ?? "Unknown")", for: UIControlState.normal)
        chosenCategory = ItemCategory.enumName(index: indexPath.row)
        categoryTableView.removeFromSuperview()
    }
    
    
    //thePostMethod
    fileprivate func validateFields() {
        
        guard (offerRequestSegmentedControl.selectedSegmentIndex != -1) else {
            let alert = UIAlertController(title: "Whoops", message: "You must offer or request this", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (titleTextField.text != "") else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a title", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (titleTextField.text!.count > 18) else {
            let alert = UIAlertController(title: "Whoops", message: "Title needs to be less than 18 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (descriptionTextField.text != "") else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a description", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        guard (chosenCategory != nil) else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a category", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        guard (selectedLocationCoordinates != nil) else {
            let alert = UIAlertController(title: "Whoops", message: "You must add a location", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard (selectedLocationCoordinates != nil) else {
            let alert = UIAlertController(title: "Whoops", message: "You must give it a value", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let user = AppData.sharedInstance.currentUser!
        
        let tags:Tag = Tag()
        if chosenTagsArray.count > 0 {
            tags.tagsArray = chosenTagsArray
        }
        
        let realItem: Item = Item.init(name: titleTextField.text!, category: chosenCategory, description: descriptionTextField.text!, location: selectedLocationCoordinates, posterUID:  user.UID, quality: chosenQuality, tags: tags, photos: [""], itemUID: nil)
        
        var photoRefs:[String] = []
        
        if (editingBool){
            WriteFirebaseData.delete(itemUID: itemToEdit.UID)
            
            
            if (photosArray.count+itemToEdit.photos.count) == 0 {
                photoRefs.append("")
            }
            else {
                
                photoRefs = itemToEdit.photos
                for index in 0..<photosArray.count {
                    let storagePath = "\(realItem.UID!)/\(index)"
                    
                    let photoRefStr = ImageManager.uploadImage(image: photosArray[index],
                                                               userUID: (AppData.sharedInstance.currentUser?.UID)!,
                                                               filename: storagePath)
                    photoRefs.append(photoRefStr)
                    print("\(realItem.UID)/\(photoRefStr)")
                }
            }
        }
        else {
        
            if (photosArray.count == 0) {
                photoRefs.append("")
            }
            else {
                for index in 0..<photosArray.count {
                    let storagePath = "\(realItem.UID!)/\(index)"
                    
                    
                    let photoRefStr = ImageManager.uploadImage(image: photosArray[index],
                                                               userUID: (AppData.sharedInstance.currentUser?.UID)!,
                                                               filename: storagePath)
                    photoRefs.append(photoRefStr)
                    print("\(realItem.UID)/\(photoRefStr)")
                }
            }
        }
        realItem.photos = photoRefs
        
        WriteFirebaseData.write(item: realItem, type: offerRequestSegmentedControl.selectedSegmentIndex)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        switch(qualitySegmentedControl.selectedSegmentIndex){
        case 0: chosenQuality = ItemQuality.New
        case 1: chosenQuality = ItemQuality.GentlyUsed
        case 2: chosenQuality = ItemQuality.NeedsFixing
        case 3: chosenQuality = ItemQuality.DamagedButFunctional
        default:
            chosenQuality = ItemQuality.GentlyUsed
        }
        validateFields()
    }
    
    
    @IBAction func selectPostLocationButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showPostMap", sender: self)
    }
    
    
    //photos CollectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (editingBool){
            return (itemToEdit.photos.count+photosArray.count+1)
        }
        else {
            return (photosArray.count+1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PostPhotoCollectionViewCell
        
        if(editingBool){
            
            if(itemToEdit.photos.count+photosArray.count == indexPath.item){
                cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
                cell.contentMode = .scaleAspectFit
            }
            
            else if(indexPath.item < itemToEdit.photos.count+photosArray.count){
                
                if(indexPath.item < itemToEdit.photos.count){
                    cell.postCollectionViewCellImageView.sd_setImage(with:storageRef.child(itemToEdit.photos[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))
                }
                
                else {
                    cell.postCollectionViewCellImageView.image = photosArray[(indexPath.item-itemToEdit.photos.count)]
                }
                
                cell.postCollectionViewCellImageView.layer.cornerRadius = 10
                cell.postCollectionViewCellImageView.layer.borderWidth = 3.0
                cell.postCollectionViewCellImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
                cell.postCollectionViewCellImageView.layer.masksToBounds = true
                cell.postCollectionViewCellImageView.clipsToBounds = true
                cell.postCollectionViewCellImageView.contentMode = .scaleAspectFill
            }
        }
        
        else  {
            if(photosArray.count == indexPath.item){
                cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
                cell.postCollectionViewCellImageView.contentMode = .scaleAspectFit
                
            }
        
            else if(indexPath.item < photosArray.count){
                cell.postCollectionViewCellImageView.image = photosArray[indexPath.item]
                
                cell.postCollectionViewCellImageView.layer.cornerRadius = 10
                cell.postCollectionViewCellImageView.layer.borderWidth = 3.0
                cell.postCollectionViewCellImageView.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
                cell.postCollectionViewCellImageView.layer.masksToBounds = true
                cell.postCollectionViewCellImageView.clipsToBounds = true
                cell.postCollectionViewCellImageView.contentMode = .scaleAspectFill
                
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //if we are editing an existing post
        if (editingBool){
            //if we click on the plus picture
            if ((indexPath.item) + 1 > (self.photosArray.count + itemToEdit.photos.count)){
                presentImagePickerAlert()
            }
            //else we click on an existing picture
            else {
                let changePhotoAlert = UIAlertController(title: "View or Delete Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                var viewAction: UIAlertAction!
                var changeAction: UIAlertAction!
                
                //if the picture was already existing
                if(indexPath.item < itemToEdit.photos.count){
                    
                    viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                        //open photo
                        
                    })
                    
                    changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                        //
                        
                        self.itemToEdit.photos.remove(at: indexPath.item)
                        self.photoCollectionView.reloadData()
                    })
                }
                    
                //else if the picture was just added
                else {
                    
                    viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                        //open photo
                        self.fullscreenImage(image: self.photosArray[indexPath.item - self.itemToEdit.photos.count])
                        
                    })
                    
                    changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                        
                        self.photosArray.remove(at: (indexPath.item-self.itemToEdit.photos.count))
                        self.photoCollectionView.reloadData()
                    })
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                changePhotoAlert.addAction(viewAction)
                changePhotoAlert.addAction(changeAction)
                changePhotoAlert.addAction(cancelAction)
                
                self.present(changePhotoAlert, animated: true, completion: nil)
            }
            
        }
        //else if we are creating a new post
        else {
            //if we click on the plus picture
            if ((indexPath.item) + 1 > self.photosArray.count){
                presentImagePickerAlert()
            }
            //else if we click on an image
            else {
                let changePhotoAlert = UIAlertController(title: "View or Delete Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                let viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                    //open photo
                    self.fullscreenImage(image: self.photosArray[indexPath.item])
                })
                
                let changeAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler:{ (action) in
                    self.photosArray.remove(at: indexPath.item)
                    self.photoCollectionView.reloadData()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                
                changePhotoAlert.addAction(viewAction)
                changePhotoAlert.addAction(changeAction)
                changePhotoAlert.addAction(cancelAction)
                
                self.present(changePhotoAlert, animated: true, completion: nil)
            }
        }
    }
    
    //textView methods
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
//        self.view.addGestureRecognizer(tapGesture)
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.view.removeGestureRecognizer(tapGesture)
//
//    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        if descriptionTextField.textColor == .lightGray && descriptionTextField.isFirstResponder {
            descriptionTextField.text = nil
            descriptionTextField.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        
        self.view.removeGestureRecognizer(tapGesture)
        
        if descriptionTextField.text.isEmpty || descriptionTextField.text == "" {
            descriptionTextField.textColor = .lightGray
            descriptionTextField.text = "Description"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        customTagTextField.resignFirstResponder()
        valueTextField.resignFirstResponder()
    }
    
    func fullscreenImage(image: UIImage) {
        
        let newImageView = UIImageView(image: image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}
