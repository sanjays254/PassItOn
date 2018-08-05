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
    
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextView!
    @IBOutlet var qualitySegmentedControl: UISegmentedControl!
    @IBOutlet var customTagTextField: UITextField!
    @IBOutlet var valueTextField: UITextField!
    @IBOutlet var addCustomTagButton: UIButton!
    @IBOutlet var tagButtonView: UIView!
    @IBOutlet weak var defaultTagStackView: UIStackView!
    @IBOutlet weak var customTagStackView: UIStackView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var addCategoryButton: UIButton!
    @IBOutlet var photoCollectionView: UICollectionView!
    
    //step by step outlets
    @IBOutlet weak var stepByStepView: UIView!
    var questionLabel: UILabel!
    var responseView: UIView!
    var nextPreviousButtonStackView: UIStackView!
    var previewWarningLabel: UILabel!
    var offerStepsArray: [String]!
    var requestStepsArray: [String]!
    var stepIndex: Int!
    
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet var descriptionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var customTagTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet var customTagTextFielLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var customTagTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var valueTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet var valueTextFieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var addTagButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var addTagButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var addTagButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var tagButtonTopConstraintToCustomTagTextFieldBottom: NSLayoutConstraint!
    @IBOutlet var tagButtonTopConstraintToValueBottom: NSLayoutConstraint!
    @IBOutlet var tagButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var tagButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var tagButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var photoCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var photoCollectionViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var photoCollectionViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var qualitySegmentTopConstraint: NSLayoutConstraint!
    @IBOutlet var qualitySegmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var qualitySegmentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var qualitySegmentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var categoryButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var categoryButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var categoryButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var locationButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var locationButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var locationButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var locationButtonBottomConstraint: NSLayoutConstraint!
    
    var topConstraintInResponseView: NSLayoutConstraint!
    var bottomConstraintInResponseView: NSLayoutConstraint!
    var leadingConstraintInResponseView: NSLayoutConstraint!
    var trailingConstraintInResponseView: NSLayoutConstraint!
    
    var previousButton: UIButton!
    var nextButton: UIButton!
    
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
    
    var googleImagesCollectionViewContainer: UIView!
    var googleImagesCollectionViewController: GoogleImagesCollectionViewController?
    var googleImagesURLS: [URL] = []
    
    
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        photosArray = []
        setupUI()

        titleTextField.delegate = self
        descriptionTextField.delegate = self
        descriptionTextField.textColor = .lightGray
        descriptionTextField.text = "Optional Description"
        customTagTextField.delegate = self
        valueTextField.delegate = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePicker.delegate = self
        
        checkIfEditing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationButton.setTitle("Location: \(self.selectedLocationString)", for: UIControlState.normal)
    }

    
    func setupUI(){
        
        setupCancelButton()
        
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
        
        setupPhotoCollectionView()
        setupOfferRequestSegmentedControl()
        setupTagButtonsView()
    }
    
    func setupCancelButton(){
        
        let backButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        backButton.addTarget(self, action: #selector(confirmExitAlert), for: .touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        backButton.sizeToFit()
        let customBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem  = customBackButtonItem
        
    }
    
    
    @objc func confirmExitAlert(){
        
        let exitAlert = UIAlertController(title: "Are you sure?", message: "You will lose all your progress if you go back to the home page", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: {(action) in
            self.navigationController?.popViewController(animated: true)
        })
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        exitAlert.addAction(yesAction)
        exitAlert.addAction(noAction)
        
        present(exitAlert, animated: true, completion: nil)
    }
    

 
    //setup default UI if editing, otherwise step by step questions
    func checkIfEditing(){
        if (editingBool){
            offerRequestSegmentedControl.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
            offerRequestSegmentedControl.tintColor = UIProperties.sharedUIProperties.lightGreenColour
            offerRequestSegmentedControl.backgroundColor = UIProperties.sharedUIProperties.blackColour
            offerRequestSegmentedControl.isEnabled = false
            self.navigationItem.titleView = offerRequestSegmentedControl
            offerRequestSegmentedControl.center.x = (self.navigationItem.titleView?.center.x)!
            offerRequestSegmentedControl.selectedSegmentIndex = offerRequestIndex
            
            titleTextField.text = itemToEdit.name
            descriptionTextField.text = itemToEdit.itemDescription
            descriptionTextField.textColor = UIColor.black
            chosenTagsArray = itemToEdit.tags.tagsArray
            qualitySegmentedControl.selectedSegmentIndex = ItemQuality.itemQualityIndex(quality: itemToEdit.quality)
            addCategoryButton.setTitle("Category: \(itemToEdit.itemCategory.rawValue)", for: .normal)
            chosenCategory = itemToEdit.itemCategory
            locationButton.setTitle("Location: \(String(describing: itemToEdit!.coordinate))", for: .normal)
            selectedLocationCoordinates = itemToEdit.location
            valueTextField.text = String(itemToEdit.value)
            
            for tag in itemToEdit.tags.tagsArray {
                addCustomTag(string: tag)
            }
            
            findLocationStringFromCoordinates(item: itemToEdit)
        }
        
        else {
            setupInitialUI()
        }
    }
    
    fileprivate func setupOfferRequestSegmentedControl() {
        offerRequestSegmentedControl = UISegmentedControl()
        offerRequestSegmentedControl.tintColor = UIProperties.sharedUIProperties.purpleColour
        offerRequestSegmentedControl.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        offerRequestSegmentedControl.insertSegment(withTitle: "Offer", at: 0, animated: true)
        offerRequestSegmentedControl.insertSegment(withTitle: "Request", at: 1, animated: true)
        offerRequestSegmentedControl.addTarget(self, action: #selector(offerRequestSegmentControlChanged), for: .valueChanged)
        //self.navigationItem.titleView = offerRequestSegmentedControl
    }
    
    func setupInitialUI(){
        
        offerStepsArray = ["What kind of post is this?", "Item Title & Description", "Add some photos", "Add tags/keywords to enhance searches for this item", "What condition is it in?", "What category does it fall under?", "Pick up Location?", "What is its value?"]
        requestStepsArray = ["What kind of post is this?", "Item Title & Description", "Add some sample photos", "Select or add tags/keywords to enhance searches for this item", "What's the worst condition you would accept?", "What category does it fall under?", "Drop off Location?", "Requests cannot have a value!"]
        stepIndex = 0
        
        view.bringSubview(toFront: stepByStepView)
        
        //setup Question Label
        questionLabel = UILabel(frame: CGRect(x: 10, y: 25, width: view.frame.width-20, height: 50))
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.font = UIFont(name: "Avenir-Light", size: 15)
        questionLabel.center.x = view.center.x
        questionLabel.textAlignment = .center
        questionLabel.text = offerStepsArray[stepIndex]
        
        stepByStepView.addSubview(questionLabel)
        
        //setup response view
        responseView = UIView(frame: CGRect(x: 0, y: 80, width: view.frame.width, height: 170))
        responseView.center.x = view.center.x
        responseView.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        
        stepByStepView.addSubview(responseView)
        
        //setup preview warning label
        previewWarningLabel = UILabel(frame: CGRect(x: 10, y: 295, width: view.frame.width-20, height: 30))
        previewWarningLabel.font = UIFont(name: "Avenir-LightOblique", size: 12)
        previewWarningLabel.center.x = view.center.x
        previewWarningLabel.textAlignment = .center
        previewWarningLabel.text = "You'll be able to preview this info. before posting"
        
        stepByStepView.addSubview(previewWarningLabel)
        
        //setup nextPrevious Buttons
        nextButton = UIButton(type: .custom)
        nextButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: UIControlEvents.touchUpInside)
        nextButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        nextButton.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        nextButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        nextButton.layer.borderWidth = 3
        nextButton.layer.cornerRadius = nextButton.frame.height/2
        
        previousButton = UIButton(type: .custom)
        previousButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        previousButton.setTitle("Previous", for: .normal)
        previousButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
        previousButton.addTarget(self, action: #selector(previousButtonAction), for: UIControlEvents.touchUpInside)
        previousButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        previousButton.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        previousButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        previousButton.layer.borderWidth = 3
        previousButton.layer.cornerRadius = previousButton.frame.height/2
        
        nextPreviousButtonStackView = UIStackView(arrangedSubviews: [previousButton,nextButton])
        nextPreviousButtonStackView.backgroundColor = UIColor.black
        nextPreviousButtonStackView.axis = .horizontal
        nextPreviousButtonStackView.frame = CGRect.zero
        nextPreviousButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        nextPreviousButtonStackView.distribution = .fillEqually
        stepByStepView.addSubview(nextPreviousButtonStackView)
        
        //previewWarningLabel Constraints
//        let previewWarningLabelTopConstraint = NSLayoutConstraint(item: previewWarningLabel, attribute: .top, relatedBy: .equal, toItem: responseView, attribute: .bottom, multiplier: 1, constant: 10)
//        let previewWarningLabelLeadingConstraint = NSLayoutConstraint(item: previewWarningLabel, attribute: .leading, relatedBy: .equal, toItem: stepByStepView, attribute: .leading, multiplier: 1, constant: 10)
//        let previewWarningLabelTrailingConstraint = NSLayoutConstraint(item: previewWarningLabel, attribute: .trailing, relatedBy: .equal, toItem: stepByStepView, attribute: .trailing, multiplier: 1, constant: 10)
//        //let previewWarningLabelBottomConstraint = NSLayoutConstraint(item: previewWarningLabel, attribute: .bottom, relatedBy: .equal, toItem: nextPreviousButtonStackView, attribute: .top, multiplier: 1, constant: 10)
//
//        NSLayoutConstraint.activate([previewWarningLabelTopConstraint, previewWarningLabelLeadingConstraint, previewWarningLabelTrailingConstraint])
        
        
        //nextPreviousButtons Constraints
        let nextPreviousStackViewTopConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .top, relatedBy: .equal, toItem: responseView, attribute: .bottom, multiplier: 1, constant: 10)
        
        let nextPreviousStackViewWidthConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .width, relatedBy: .equal,
                                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: view.frame.width*0.8)
        
        let nextPreviousStackViewHeightConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .height, relatedBy: .equal,
                                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        
        let centralizeXconstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([nextPreviousStackViewWidthConstraint, nextPreviousStackViewHeightConstraint, centralizeXconstraint, nextPreviousStackViewTopConstraint])
        
        
        titleTopConstraint.isActive = false
        descriptionTopConstraint.isActive = false
        //tagButtonTopConstraintToCustomTagTextFieldBottom.isActive = false
        tagButtonTopConstraintToValueBottom.isActive = false
        valueTextFieldTopConstraint.isActive = false
        customTagTrailingConstraint.isActive = false
        customTagTextFieldTopConstraint.isActive = false
        photoCollectionViewTopConstraint.isActive = false
        qualitySegmentTopConstraint.isActive = false
        categoryButtonTopConstraint.isActive = false
        locationButtonTopConstraint.isActive = false
        locationButtonBottomConstraint.isActive = false
        
        setupCascadingQuestions()
    }
    
    
    
    @objc func moveOfferRequestSegmentControl(sender: UISegmentedControl!){
        
        if(stepIndex == 0){
            offerRequestSegmentedControl.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
            offerRequestSegmentedControl.tintColor = UIProperties.sharedUIProperties.lightGreenColour
            offerRequestSegmentedControl.backgroundColor = UIProperties.sharedUIProperties.blackColour
            self.navigationItem.titleView = offerRequestSegmentedControl
            offerRequestSegmentedControl.center.x = (self.navigationItem.titleView?.center.x)!
            nextQuestion()
        }
    }
    
    
    @objc func offerRequestSegmentControlChanged(){
        switch offerRequestSegmentedControl.selectedSegmentIndex {
        case 0: valueTextField.isEnabled = true
            valueTextField.backgroundColor = UIColor.white
        
        if !(editingBool){
        
            if (stepIndex < 8){
                questionLabel.text = offerStepsArray[stepIndex]
            }
            
            if(stepIndex == 2) {
                if let googleImagesCollectionViewContainerUnwrapped = googleImagesCollectionViewContainer {
                    googleImagesCollectionViewContainerUnwrapped.isHidden = true
                }
                
            }
        
            if (stepIndex == 7){
                nextButton.setTitle("Preview", for: .normal)
            }
            else {
                nextButton.setTitle("Next", for: .normal)
                }
            }
        case 1: valueTextField.isEnabled = false
            valueTextField.backgroundColor = UIColor.gray
        
        if !(editingBool){
            if (stepIndex < 8){
                questionLabel.text = requestStepsArray[stepIndex]
            }
            if(stepIndex == 2) {
                if let googleImagesCollectionViewContainerUnwrapped = googleImagesCollectionViewContainer {
                    googleImagesCollectionViewContainerUnwrapped.isHidden = false
                }
                else {
                    
                    //create it
                    setupGoogleImagesContainerView()
                }
                
            }
            
            
            if (stepIndex == 6){
                nextButton.setTitle("Preview", for: .normal)
            }
            else {
                nextButton.setTitle("Next", for: .normal)
                }
            }
            
        default: valueTextField.isEnabled = false
            valueTextField.backgroundColor = UIColor.gray
            

        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
 

    
    @IBAction func selectPostLocationButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showPostMap", sender: self)
    }
    
    
    
    //textView methods
    func textFieldDidBeginEditing(_ textField: UITextField) {

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.removeGestureRecognizer(tapGesture)

    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        if descriptionTextField.textColor == .lightGray && descriptionTextField.isFirstResponder {
            descriptionTextField.text = nil
            descriptionTextField.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        
        self.view.removeGestureRecognizer(tapGesture)
        
        if descriptionTextField.text.isEmpty || descriptionTextField.text == "" {
            descriptionTextField.textColor = .lightGray
            descriptionTextField.text = "Optional Description"
        }
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignAllKeyboardResponders() {
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        customTagTextField.resignFirstResponder()
        valueTextField.resignFirstResponder()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        resignAllKeyboardResponders()
    }
    
    //fullcreen image methods
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
