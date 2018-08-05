//
//  PostViewController+Tags.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension PostViewController {
    
    
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
            
            if !(editingBool){
                chosenTagsArray.append(string)
            }
            
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
    
    
}
