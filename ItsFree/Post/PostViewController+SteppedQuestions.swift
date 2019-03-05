//
//  PostViewController+SteppedQuestions.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension PostViewController {
    
    //next, previous button actions
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
            stepIndex = offerStepsArray.count
        }
        else {
            stepIndex = stepIndex + 1
            if (stepIndex < offerStepsArray.count){
                questionLabel.text = offerStepsArray[stepIndex]
            }
        }
        setupCascadingQuestions()
    }
    
    //step by step questions
    func setupCascadingQuestions(){
        
        //show default UI
        if (stepIndex == offerStepsArray.count){
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            topConstraintInResponseView.isActive = false
            bottomConstraintInResponseView.isActive = false
            trailingConstraintInResponseView.isActive = false
            leadingConstraintInResponseView.isActive = false
            
            questionLabel.removeFromSuperview()
            responseView.removeFromSuperview()
            previewWarningLabel.removeFromSuperview()
            nextPreviousButtonStackView.removeFromSuperview()
            view.sendSubview(toBack: stepByStepView)
            
            view.addSubview(titleTextField)
            view.addSubview(descriptionTextField)
            view.addSubview(tagButtonView)
            view.addSubview(customTagTextField)
            view.addSubview(addCustomTagButton)
            view.addSubview(photoCollectionView)
            photoCollectionView.reloadData()
            view.addSubview(addCategoryButton)
            view.addSubview(locationButton)
            view.addSubview(valueTextField)
            view.addSubview(qualitySegmentedControl)
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                valueTextField.isEnabled = false
                valueTextField.backgroundColor = UIColor.gray
            }
            
            titleTextField.isHidden = false
            descriptionTextField.isHidden = false
            tagButtonView.isHidden = false
            customTagTextField.isHidden = false
            addCustomTagButton.isHidden = false
            photoCollectionView.isHidden = false
            addCategoryButton.isHidden = false
            locationButton.isHidden = false
            valueTextField.isHidden = false
            qualitySegmentedControl.isHidden = false
            
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
            //locationButtonBottomConstraint.isActive = true
            
            photoCollectionView.reloadData()
            
            view.layoutIfNeeded()
        }
            
            //ask if offer or request
        else if (stepIndex == 0){
            nextPreviousButtonStackView.isHidden = true
            
            offerRequestSegmentedControl.frame = CGRect(x: 0, y: 30, width: 300, height: 30)
            offerRequestSegmentedControl.center.x = responseView.center.x
            offerRequestSegmentedControl.layer.cornerRadius = 4
            offerRequestSegmentedControl.addTarget(self, action: #selector(moveOfferRequestSegmentControl), for: .valueChanged)
            
            responseView.addSubview(offerRequestSegmentedControl)
        }
            
            //title and description
        else if (stepIndex == 1){
            
            nextPreviousButtonStackView.isHidden = false
            previousButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            previousButton.isHidden = true
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            questionLabel.text = offerStepsArray[stepIndex]
            titleTextField.isHidden = false
            descriptionTextField.isHidden = false
            responseView.addSubview(titleTextField)
            responseView.addSubview(descriptionTextField)
            
            if googleImagesCollectionViewContainer != nil{
                googleImagesCollectionViewContainer.removeFromSuperview()
                googleImagesCollectionViewContainer = nil
            }
            
            topConstraintInResponseView = NSLayoutConstraint(item: titleTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            
            bottomConstraintInResponseView = NSLayoutConstraint(item: titleTextField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: descriptionTextField, attribute: NSLayoutAttribute.top, multiplier: 1, constant: -10)
            
            responseView.addConstraints([topConstraintInResponseView, bottomConstraintInResponseView])
        }
            
            //photos
        else if (stepIndex == 2){
            
            resignAllKeyboardResponders()
            
            previousButton.frame = CGRect(x: 0, y: 0, width: nextPreviousButtonStackView.frame.width/2, height: nextPreviousButtonStackView.frame.height)
            nextPreviousButtonStackView.distribution = .fillEqually
            previousButton.isHidden = false
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                questionLabel.text = requestStepsArray[stepIndex]
            }
                
            else {
                questionLabel.text = offerStepsArray[stepIndex]
            }
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            photoCollectionView.isHidden = false
            setupPhotoCollectionView()
            photoCollectionView.reloadData()
            responseView.addSubview(photoCollectionView)
            
            //setup GoogleImagesContainerView if its a request
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                setupGoogleImagesContainerView()
            }
            
            
            
            topConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            
            bottomConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20)
            
            trailingConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 10)
            
            leadingConstraintInResponseView = NSLayoutConstraint(item: photoCollectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            
            responseView.addConstraints([topConstraintInResponseView, bottomConstraintInResponseView, leadingConstraintInResponseView, trailingConstraintInResponseView])
        }
            
            //tags
        else if (stepIndex == 3){
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            customTagTextField.isHidden = false
            tagButtonView.isHidden = false
            addCustomTagButton.isHidden = false
            
            questionLabel.text = offerStepsArray[stepIndex]
            responseView.addSubview(customTagTextField)
            responseView.addSubview(tagButtonView)
            responseView.addSubview(addCustomTagButton)
            
            if googleImagesCollectionViewContainer != nil{
                googleImagesCollectionViewContainer.removeFromSuperview()
                googleImagesCollectionViewContainer = nil
            }
            
            topConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            trailingConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)
            leadingConstraintInResponseView = NSLayoutConstraint(item: customTagTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView, trailingConstraintInResponseView, leadingConstraintInResponseView])
        }
            
            //quality
        else if (stepIndex == 4){
            
            resignAllKeyboardResponders()
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                questionLabel.text = requestStepsArray[stepIndex]
            }
                
            else {
                questionLabel.text = offerStepsArray[stepIndex]
            }
            
            qualitySegmentedControl.isHidden = false
            responseView.addSubview(qualitySegmentedControl)
            
            topConstraintInResponseView = NSLayoutConstraint(item: qualitySegmentedControl, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
        }
            
            //Category
        else if (stepIndex == 5){
            
            resignAllKeyboardResponders()
            
            nextButton.setTitle("Next", for: .normal)
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            addCategoryButton.isHidden = false
            questionLabel.text = offerStepsArray[stepIndex]
            responseView.addSubview(addCategoryButton)
            
            topConstraintInResponseView = NSLayoutConstraint(item: addCategoryButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
        }
            
            //location
        else if (stepIndex == 6){
            
            resignAllKeyboardResponders()
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                nextButton.setTitle("Preview", for: .normal)
            }
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            if (offerRequestSegmentedControl.selectedSegmentIndex == 1){
                questionLabel.text = "Drop off Location?"
            }
                
            else {
                questionLabel.text = offerStepsArray[stepIndex]
            }
            
            locationButton.isHidden = false
            responseView.addSubview(locationButton)
            
            topConstraintInResponseView = NSLayoutConstraint(item: locationButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            responseView.addConstraints([topConstraintInResponseView])
        }
            
            //value
        else if (stepIndex == 7){
            
            nextButton.setTitle("Preview", for: .normal)
            
            for view in responseView.subviews {
                view.isHidden = true
            }
            
            valueTextField.isHidden = false
            questionLabel.text = offerStepsArray[stepIndex]
            responseView.addSubview(valueTextField)
            
            topConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            
            leadingConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10)
            
            trailingConstraintInResponseView = NSLayoutConstraint(item: valueTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: responseView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10)
            
            responseView.addConstraints([topConstraintInResponseView,leadingConstraintInResponseView, trailingConstraintInResponseView])
        }
    }
    
    
}
