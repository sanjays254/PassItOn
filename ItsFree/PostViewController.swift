//
//  PostViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
    var chosenQuality: ItemQuality!
    
    @IBOutlet weak var customTagTextField: UITextField!
    @IBOutlet weak var tagButtonView: UIView!
    
    @IBOutlet weak var defaultTagStackView: UIStackView!
    
    @IBOutlet weak var customTagStackView: UIStackView!
    var chosenTagsArray: [String] = []
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    var chosenCategory: ItemCategory!
    
    var categoryCount: Int!
    var categoryTableView: UITableView!
    let cellID: String = "categoryCellID"
    
    public var selectedLocationString: String = ""
    public var selectedLocationCoordinates: CLLocationCoordinate2D!
    
    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var photosArray: Array<UIImage>!
    
    var tapGesture: UITapGestureRecognizer!
    
    var offerRequestSegmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupOfferRequestSegmentedControl()
        setupTagButtonsView()
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        descriptionTextField.borderStyle = UITextBorderStyle.roundedRect
        customTagTextField.delegate = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePicker.delegate = self
        
        photosArray = []
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationButton.setTitle("Location: \(self.selectedLocationString)", for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    fileprivate func setupOfferRequestSegmentedControl() {
        offerRequestSegmentedControl = UISegmentedControl()
        offerRequestSegmentedControl.insertSegment(withTitle: "Offer", at: 0, animated: true)
        offerRequestSegmentedControl.insertSegment(withTitle: "Request", at: 1, animated: true)
        self.navigationItem.titleView = offerRequestSegmentedControl
    }
    
    
    func setupTagButtonsView(){
        
        let defaultTags = ["black", "white", "small", "nike", "samsung"]
        
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
    
    
    func setupUI(){
        
        categoryTableView = UITableView(frame: CGRect(x: 0, y:20, width: self.view.frame.width, height: self.view.frame.height), style: UITableViewStyle.plain)
        
        addCategoryButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        addCategoryButton.layer.borderWidth = 1
        addCategoryButton.layer.cornerRadius = 5
        addCategoryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        locationButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        locationButton.layer.borderWidth = 1
        locationButton.layer.cornerRadius = 5
        locationButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        let photoCollectionViewFlowLayout = UICollectionViewFlowLayout()
        photoCollectionViewFlowLayout.itemSize = CGSize(width:UIScreen.main.bounds.width/4, height:UIScreen.main.bounds.width/4)
        photoCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        photoCollectionViewFlowLayout.minimumInteritemSpacing = 5.0
        photoCollectionView.collectionViewLayout = photoCollectionViewFlowLayout
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func openCategories(_ sender: UIButton) {
        
        self.view.addSubview(categoryTableView)
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.view.bringSubview(toFront: categoryTableView)
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
    
    
    @IBAction func addCustomTagButton(_ sender: UIButton) {
        
        let newCustomTag =  customTagTextField.text
        
        if (newCustomTag != ""){
            
            let newButton = UIButton(frame: CGRect(x: 5, y: 8, width: 50, height: 20))
            
            newButton.setTitle(newCustomTag, for: .normal)
            newButton.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: UIControlState.normal)
            newButton.addTarget(self, action: #selector(addOrRemoveThisDefaultTag), for: UIControlEvents.touchUpInside)
            
            newButton.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.light)
            newButton.sizeToFit()
            
            newButton.layer.borderWidth = 1
            newButton.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
            newButton.layer.cornerRadius = 10
            
            customTagStackView.addArrangedSubview(newButton)
            
            chosenTagsArray.append(newCustomTag!)
            
            customTagTextField.resignFirstResponder()
            customTagTextField.text = ""
        }
    }
    
    @objc func addOrRemoveThisDefaultTag(sender: UIButton){
        
        if(sender.titleColor(for: UIControlState.normal) == UIColor.gray){
            
            sender.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0), for: UIControlState.normal)
            sender.layer.borderColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
            
            chosenTagsArray.append((sender.titleLabel?.text)!)
        }
            
        else if(sender.titleColor(for: UIControlState.normal) == UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)){
            
            sender.setTitleColor(UIColor.gray, for: UIControlState.normal)
            sender.layer.borderColor = UIColor.gray.cgColor
            
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
        
        let user = AppData.sharedInstance.currentUser!
        
        let tags:Tag = Tag()
        if chosenTagsArray.count > 0 {
            tags.tagsArray = chosenTagsArray
        }
        //if these fields are not nil, then post the item
        let realItem: Item = Item.init(name: titleTextField.text!, category: chosenCategory, description: descriptionTextField.text!, location: selectedLocationCoordinates, posterUID:  user.UID, quality: chosenQuality, tags: tags, photos: [""], itemUID: nil)
        
        var photoRefs:[String] = []
        if photosArray.count == 0 {
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
        realItem.photos = photoRefs
        
        
//        if(offerRequestSegmentedControl.selectedSegmentIndex == 0){
//            let reference = AppData.sharedInstance.offersNode
            WriteFirebaseData.write(item: realItem, type: offerRequestSegmentedControl.selectedSegmentIndex)
//            AppData.sharedInstance.offersNode.child(realItem.UID).setValue(realItem.toDictionary())
//        }
//        else if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
//            let reference = AppData.sharedInstance.requestsNode
//            WriteFirebaseData.write(item: realItem, ref: reference)
//            AppData.sharedInstance.requestsNode.child(realItem.UID).setValue(realItem.toDictionary())
//        }
        
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
        return (photosArray.count+1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PostPhotoCollectionViewCell
        
        if(photosArray.count == indexPath.item){
            cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addImage")
        }
            
        else if(indexPath.item < photosArray.count) {
            cell.postCollectionViewCellImageView.image = photosArray[indexPath.item]
            cell.postCollectionViewCellImageView.layer.cornerRadius = 20
            cell.postCollectionViewCellImageView.layer.masksToBounds = true
            cell.postCollectionViewCellImageView.contentMode = .scaleAspectFill
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.removeGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        customTagTextField.resignFirstResponder()
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
