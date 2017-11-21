//
//  PostViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var categoryCount: Int!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tagButtonView: UIView!
    @IBOutlet weak var itemMapView: MKMapView!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    
    var categoryTableView: UITableView!
    
    let cellID: String = "categoryCellID"
    
    var myImage:UIImage?
    let imagePicker = UIImagePickerController()
    
    func addImage() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if myImage != nil {
            print("image loaded: \(myImage!)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        descriptionTextField.borderStyle = UITextBorderStyle.roundedRect
        
        categoryTableView = UITableView(frame: CGRect(x: 20, y:20, width: 250, height: 500), style: UITableViewStyle.plain)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        imagePicker.delegate = self
        addImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        categoryTableView.removeFromSuperview()
    }
    
    
    
    @IBAction func postItem(_ sender: UIBarButtonItem) {
        
        let tags:Tag = Tag()
       
        tags.add(tag: "blue")
        tags.add(tag: "Phone")
        
        
        let testUser:User = User.init(email: "test@gmail.com", name: "John", rating: 39, uid: "testUID")
        testUser.UID = "testUserUID"
        
//        let testItem:Item = Item.init(name: "Hat", category: ItemCategory.clothing, description: "It's a hat", location: (LocationManager.theLocationManager.getLocation().coordinate), posterUID: testUser.UID, quality: ItemQuality.GentlyUsed, and: [tag1])
//        testItem.UID = "testItemUID"
        
        let realItem: Item = Item.init(name: titleTextField.text!, category: ItemCategory.clothing, description: descriptionTextField.text!, location: (LocationManager.theLocationManager.getLocation().coordinate), posterUID:  testUser.UID, quality: ItemQuality.GentlyUsed, tags: tags)
        realItem.UID = "realItemUID"
        
        
        AppData.sharedInstance.usersNode.child(testUser.UID).setValue(testUser.toDictionary())
        AppData.sharedInstance.itemsNode.child(realItem.UID).setValue(realItem.toDictionary())
        AppData.sharedInstance.categorizedItemsNode.child(String(describing: realItem.itemCategory)).child(String(realItem.name.prefix(2))).setValue(realItem.toDictionary())
        
        
    }
    
    
    

    
    
}
