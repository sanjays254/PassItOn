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
    
    
    public var selectedLocationString: String = ""
    public var selectedLocationCoordinates: CLLocationCoordinate2D!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
    var chosenQuality: ItemQuality!
    
    @IBOutlet weak var customTagTextField: UITextField!
    @IBOutlet weak var tagButtonView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    //var chosenLocation: CLLocation!

    @IBOutlet weak var addCategoryButton: UIButton!
    var chosenCategory: ItemCategory!
    
    var categoryCount: Int!
    var categoryTableView: UITableView!
    let cellID: String = "categoryCellID"
    
    let imagePicker = UIImagePickerController()
    var myImage:UIImage?
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var photosArray: Array<UIImage>!
    
    var tapGesture: UITapGestureRecognizer!

   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
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


        let offerRequestSegmentedControl = UISegmentedControl()
        offerRequestSegmentedControl.insertSegment(withTitle: "Offer", at: 0, animated: true)
        offerRequestSegmentedControl.insertSegment(withTitle: "Request", at: 1, animated: true)
        self.navigationItem.titleView = offerRequestSegmentedControl
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationButton.setTitle("Location: \(self.selectedLocationString)", for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        

        
        let tags:Tag = Tag()
       
        tags.add(tag: "blue")
        tags.add(tag: "Phone")
        
        let testUser:User = User.init(email: "test@gmail.com", name: "John", rating: 39, uid: "testUID")
        testUser.UID = "testUserUID"
        
//        let testItem:Item = Item.init(name: "Hat", category: ItemCategory.clothing, description: "It's a hat", location: (LocationManager.theLocationManager.getLocation().coordinate), posterUID: testUser.UID, quality: ItemQuality.GentlyUsed, and: [tag1])
//        testItem.UID = "testItemUID"
        
        //let theItemToPostCategory = ItemCategory.hashValue(addCategoryButton.titleLabel)
        
        switch(qualitySegmentedControl.selectedSegmentIndex){
        case 0: chosenQuality = ItemQuality.New
        case 1: chosenQuality = ItemQuality.GentlyUsed
        case 2: chosenQuality = ItemQuality.NeedsFixing
        case 3: chosenQuality = ItemQuality.DamagedButFunctional
        default:
            chosenQuality = ItemQuality.GentlyUsed
        }
        //what should our default be
        
        
        if(titleTextField.text != "") {
            if(descriptionTextField.text != "") {
                if(chosenCategory != nil){
                    if(selectedLocationCoordinates != nil){
                        
                        //if these fields are not nil, then post the item
                        let realItem: Item = Item.init(name: titleTextField.text!, category: chosenCategory, description: descriptionTextField.text!, location: (LocationManager.theLocationManager.getLocation().coordinate), posterUID:  testUser.UID, quality: chosenQuality, tags: tags, photos: [""], itemUID: nil)
                        
                        AppData.sharedInstance.usersNode.child(testUser.UID).setValue(testUser.toDictionary())
                        AppData.sharedInstance.itemsNode.child(realItem.UID).setValue(realItem.toDictionary())
                        AppData.sharedInstance.categorizedItemsNode.child(String(describing: realItem.itemCategory)).child(String(realItem.name.prefix(2))).setValue(realItem.toDictionary())
                        
                        
                        
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        
                    }
                    else {
                        let alert = UIAlertController(title: "Whoops", message: "You must add a location", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        present(alert, animated: true, completion: nil)}}
                    
                else {
                    let alert = UIAlertController(title: "Whoops", message: "You must add a category", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    present(alert, animated: true, completion: nil)}}
                
            else {let alert = UIAlertController(title: "Whoops", message: "You must add a description", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                present(alert, animated: true, completion: nil)}}
            
        else {let alert = UIAlertController(title: "Whoops", message: "You must add a title", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)}        
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
                cell.postCollectionViewCellImageView.image = #imageLiteral(resourceName: "addPhotoPlaceholder")
            }
        
            else if(indexPath.item < photosArray.count) {
                cell.postCollectionViewCellImageView.image = photosArray[indexPath.item]
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
            let changePhotoAlert = UIAlertController(title: "Change or View Photo?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let viewAction = UIAlertAction(title: "View Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                //open photo
            })
            
            let changeAction = UIAlertAction(title: "Change Photo", style: UIAlertActionStyle.default, handler:{ (action) in
                self.presentImagePickerAlert()
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
        
        //self.view.endEditing(true)
    }

}
