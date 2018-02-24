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
    
    @IBOutlet weak var stepByStepView: UIView!
    var questionLabel: UILabel!
    var responseView: UIView!
    var nextPreviousButtonStackView: UIStackView!
    var stepsArray: [String]!
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
    
    let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosArray = []
        setupUI()
        
        
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
        
       
    }
    func setupInitialUI(){
        
        stepsArray = ["Item to give away or item that you want?", "Item Title", "Optional Description", "Add some photos", "Add tags to enhance searches for this item", "What condition is it in?", "What category does it fall under?", "Pick up Location?", "What is it's value?"]
        stepIndex = 0

        view.bringSubview(toFront: stepByStepView)
        
        questionLabel = UILabel(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 20))
        questionLabel.center.x = view.center.x
        questionLabel.textAlignment = .center
        questionLabel.text = stepsArray[stepIndex]
        
        stepByStepView.addSubview(questionLabel)
        
        responseView = UIView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 190))
        responseView.center.x = view.center.x
        responseView.backgroundColor = UIProperties.sharedUIProperties.whiteColour
        
        stepByStepView.addSubview(responseView)
        
        nextButton = UIButton(type: .custom)
        nextButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: UIControlEvents.touchUpInside)
        nextButton.tintColor = UIProperties.sharedUIProperties.whiteColour
        nextButton.backgroundColor = UIProperties.sharedUIProperties.purpleColour
        nextButton.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        nextButton.layer.borderWidth = 3
        nextButton.layer.cornerRadius = nextButton.frame.height/2
        
        previousButton = UIButton(type: .custom)
        previousButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        previousButton.setTitle("Previous", for: .normal)
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
        //nextPreviousButtonStackView.frame = CGRect(x: 0, y: 250, width: view.frame.width*0.8, height: 30)
        //nextPreviousButtonStackView.
        //nextPreviousButtonStackView.center.x = stepByStepView.center.x
        nextPreviousButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        nextPreviousButtonStackView.distribution = .fillEqually
        stepByStepView.addSubview(nextPreviousButtonStackView)
        
        let nextPreviousStackViewTopConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .top, relatedBy: .equal, toItem: responseView, attribute: .bottom, multiplier: 1, constant: 10)
        
        let nextPreviousStackViewWidthConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: view.frame.width*0.8)
        
        let nextPreviousStackViewHeightConstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        
        let centralizeXconstraint = NSLayoutConstraint(item: nextPreviousButtonStackView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([nextPreviousStackViewWidthConstraint, nextPreviousStackViewHeightConstraint, centralizeXconstraint, nextPreviousStackViewTopConstraint])
//        stepByStepView.addSubview(questionLabel)
//        stepByStepView.addSubview(responseView)
        
        
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
            self.navigationItem.titleView = offerRequestSegmentedControl
            nextQuestion()
        }
        
    }
    @objc func previousButtonAction(sender:UIButton!) {
        print("previous Clicked")
        stepIndex = stepIndex - 1
       setupCascadingQuestions()
    }
    
    @objc func nextButtonAction(sender:UIButton!) {
        nextQuestion()
        print("next Clicked")
        
    }
    func nextQuestion(){
        
        if  (nextButton.titleLabel?.text == "Preview"){
            stepIndex = stepsArray.count
        }
        
        else {
            stepIndex = stepIndex + 1
            if (stepIndex < stepsArray.count){
                questionLabel.text = stepsArray[stepIndex]
            }
            
        }
            setupCascadingQuestions()
    }
    
    func setupCascadingQuestions(){
        
        if (stepIndex == stepsArray.count){
            
            topConstraintInResponseView.isActive = false
            bottomConstraintInResponseView.isActive = false
            trailingConstraintInResponseView.isActive = false
            leadingConstraintInResponseView.isActive = false
            
            questionLabel.removeFromSuperview()
            responseView.removeFromSuperview()
            nextPreviousButtonStackView.removeFromSuperview()
            view.sendSubview(toBack: stepByStepView)
        
            view.addSubview(titleTextField)
            view.addSubview(descriptionTextField)
            view.addSubview(tagButtonView)
            view.addSubview(customTagTextField)
            view.addSubview(addCustomTagButton)
            view.addSubview(photoCollectionView)
            view.addSubview(addCategoryButton)
            view.addSubview(locationButton)
            
            titleTextField.isHidden = false
            descriptionTextField.isHidden = false
            tagButtonView.isHidden = false
            customTagTextField.isHidden = false
            addCustomTagButton.isHidden = false
            photoCollectionView.isHidden = false
            addCategoryButton.isHidden = false
            locationButton.isHidden = false
            
            titleTopConstraint.isActive = true
            titleLeadingConstraint.isActive = true
            titleTrailingConstraint.isActive = true
            
            descriptionTopConstraint.isActive = true
            descriptionLeadingConstraint.isActive = true
            descriptionTrailingConstraint.isActive = true
            
            tagButtonTopConstraintToCustomTagTextFieldBottom.isActive = true
            tagButtonTopConstraintToValueBottom.isActive = true
            tagButtonHeightConstraint.isActive = true
            tagButtonLeadingConstraint.isActive = true
            tagButtonTrailingConstraint.isActive = true
            
            valueTextFieldTopConstraint.isActive = true
            valueTextFieldTrailingConstraint.isActive = true
            
            customTagTextFieldTopConstraint.isActive = true
            customTagTextFielLeadingConstraint.isActive = true
            customTagTrailingConstraint.isActive = true
            
            addTagButtonTopConstraint.isActive = true
            addTagButtonTrailingConstraint.isActive = true
            addTagButtonBottomConstraint.isActive = true
            
            photoCollectionViewTopConstraint.isActive = true
            photoCollectionViewLeadingConstraint.isActive = true
            photoCollectionViewTrailingConstraint.isActive = true
            
            qualitySegmentTopConstraint.isActive = true
            qualitySegmentHeightConstraint.isActive = true
            qualitySegmentLeadingConstraint.isActive = true
            qualitySegmentTrailingConstraint.isActive = true
            
            categoryButtonTopConstraint.isActive = true
            categoryButtonLeadingConstraint.isActive = true
            categoryButtonTrailingConstraint.isActive = true
            
            locationButtonTopConstraint.isActive = true
            locationButtonLeadingConstraint.isActive = true
            locationButtonTrailingConstraint.isActive = true
            locationButtonBottomConstraint.isActive = true
            
            view.layoutIfNeeded()
        }
        
        else if (stepIndex == 0){
            nextPreviousButtonStackView.isHidden = true
          
            offerRequestSegmentedControl.frame = CGRect(x: 0, y: 30, width: 300, height: 30)
            offerRequestSegmentedControl.layer.cornerRadius = 4
            offerRequestSegmentedControl.addTarget(self, action: #selector(moveOfferRequestSegmentControl), for: .valueChanged)
            
            responseView.addSubview(offerRequestSegmentedControl)
            offerRequestSegmentedControl.center.x = responseView.center.x
            
        }
        else if (stepIndex == 1){
            
           
            nextPreviousButtonStackView.isHidden = false
             previousButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            
           // nextButton.center.x = nextPreviousButtonStackView.center.x
           
            previousButton.isHidden = true
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            questionLabel.text = stepsArray[stepIndex]
            titleTextField.isHidden = false
            responseView.addSubview(titleTextField)
            
            topConstraintInResponseView = NSLayoutConstraint(item: titleTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
                                 
//            titleTextField.center.y = responseView.center.y
//            titleTextField.center.x = responseView.center.x
            
        }
        else if (stepIndex == 2){
            
            previousButton.frame = CGRect(x: 0, y: 0, width: nextPreviousButtonStackView.frame.width/2, height: nextPreviousButtonStackView.frame.height)
            nextPreviousButtonStackView.distribution = .fillEqually
            previousButton.isHidden = false
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            descriptionTextField.isHidden = false
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(descriptionTextField)
            
            topConstraintInResponseView = NSLayoutConstraint(item: descriptionTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
        }
        else if (stepIndex == 3){
            for view in responseView.subviews {
               view.isHidden = true
            }
            photoCollectionView.isHidden = false
            questionLabel.text = stepsArray[stepIndex]
            setupPhotoCollectionView()
            responseView.addSubview(photoCollectionView)
            
            topConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            
            bottomConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -50)
            
            trailingConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 10)
            
            leadingConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            
            responseView.addConstraints([topConstraintInResponseView, bottomConstraintInResponseView, leadingConstraintInResponseView, trailingConstraintInResponseView])
        }
        else if (stepIndex == 4){
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            customTagTextField.isHidden = false
            tagButtonView.isHidden = false
            addCustomTagButton.isHidden = false
            
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(customTagTextField)
            responseView.addSubview(tagButtonView)
            responseView.addSubview(addCustomTagButton)
            
            topConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            trailingConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)
            leadingConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView, trailingConstraintInResponseView, leadingConstraintInResponseView])
            
        }
        else if (stepIndex == 5){
            
            
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            
            nextButton.titleLabel?.text = "Next"
            
            qualitySegmentedControl.isHidden = false
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(qualitySegmentedControl)
            
            topConstraintInResponseView = NSLayoutConstraint(item: qualitySegmentedControl, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
            
            
        }
        else if (stepIndex == 6){
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                nextButton.titleLabel?.text = "Preview"
            }
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            addCategoryButton.isHidden = false
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(addCategoryButton)
            
            topConstraintInResponseView = NSLayoutConstraint(item: addCategoryButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
            
           
        }
        else if (stepIndex == 7){

            
            nextButton.titleLabel?.text = "Next"
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            
            locationButton.isHidden = false
            
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(locationButton)
            
            topConstraintInResponseView = NSLayoutConstraint(item: locationButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
            
        }
        else if (stepIndex == 8){
            
            nextButton.titleLabel?.text = "Preview"
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            valueTextField.isHidden = false
            questionLabel.text = stepsArray[stepIndex]
            responseView.addSubview(valueTextField)
            
            topConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            bottomConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -70)
            
            leadingConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            
            trailingConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)
           
            responseView.addConstraints([topConstraintInResponseView,leadingConstraintInResponseView, trailingConstraintInResponseView, bottomConstraintInResponseView])
        }
         
    }
    func setupUI(){
        
        self.navigationItem.backBarButtonItem?.title = "Browse"
        
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
    
    func setupPhotoCollectionView(){
        let photoCollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        photoCollectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        photoCollectionViewFlowLayout.minimumInteritemSpacing = 5.0
        
        photoCollectionView.collectionViewLayout = photoCollectionViewFlowLayout
        
        
        //photoCollectionView.center.x = view.center.x
        var totalPhotosCount: Int!
        
        if (editingBool == true){
            totalPhotosCount = photosArray.count + itemToEdit.photos.count + 1
        }
        else {
            totalPhotosCount = photosArray.count + 1
        }
        
        let viewWidth = CGFloat(photoCollectionView.frame.width * 1)
        let totalCellWidth = (photoCollectionView.frame.size.width/3) * CGFloat(totalPhotosCount);
        let totalSpacingWidth = 10 * CGFloat(totalPhotosCount - 1);
        
        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
        let rightInset = leftInset;
        
        photoCollectionViewLeadingConstraint = NSLayoutConstraint(item: photoCollectionView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 7)
        photoCollectionViewTrailingConstraint = NSLayoutConstraint(item: photoCollectionView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: 7)
        photoCollectionViewLeadingConstraint.constant = leftInset
        photoCollectionViewTrailingConstraint.constant = rightInset
        
        view.layoutIfNeeded()
        
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
        
        else {
            setupInitialUI()
        }
    }
    
    
    fileprivate func setupOfferRequestSegmentedControl() {
        offerRequestSegmentedControl = UISegmentedControl()
        offerRequestSegmentedControl.tintColor = UIProperties.sharedUIProperties.lightGreenColour
        offerRequestSegmentedControl.backgroundColor = UIProperties.sharedUIProperties.blackColour
        offerRequestSegmentedControl.insertSegment(withTitle: "Offer", at: 0, animated: true)
        offerRequestSegmentedControl.insertSegment(withTitle: "Request", at: 1, animated: true)
        //self.navigationItem.titleView = offerRequestSegmentedControl
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        var totalPhotosCount: Int!
//
//        if (editingBool == true){
//            totalPhotosCount = photosArray.count + itemToEdit.photos.count + 1
//        }
//        else {
//            totalPhotosCount = photosArray.count + 1
//        }
//
//        let viewWidth = CGFloat(collectionView.frame.width * 1)
//        let totalCellWidth = (collectionView.frame.size.width/3) * CGFloat(totalPhotosCount);
//        let totalSpacingWidth = 10 * CGFloat(totalPhotosCount - 1);
//
//        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
//        let rightInset = leftInset;
//
//        return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
//    }
    
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
