//
//  PostViewController+GoogleImages.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-03.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit

extension PostViewController {
    
    func grabGoogleImages(){
        if let url = ReadGoogleImages.constructURL(keyword: titleTextField.text!) {
            
            if let googleImagesCollectionViewController = self.googleImagesCollectionViewController {
            
                //BusyActivityView.showMini(inpVC: googleImagesCollectionViewController, inpView: googleImagesCollectionViewContainer)
        
                ReadGoogleImages.grabImages(url: url, completion: {(images, success) in
            
                    if (success){
                        googleImagesCollectionViewController.googleImagesArray = images
            
                        DispatchQueue.main.async {
                            googleImagesCollectionViewController.collectionView.reloadData()
                          //  BusyActivityView.hide()
                    
                        }
                    }
                    else {
                        
                        //BusyActivityView.hide()
                    }
                    
             
                })
            }
        }
        
    }
    
    func setupGoogleImagesContainerView(){
        
        googleImagesCollectionViewContainer = UIView()
        googleImagesCollectionViewContainer.backgroundColor = .white
        googleImagesCollectionViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(googleImagesCollectionViewContainer)
        
        let gImagesCollectionViewTopConstraint = NSLayoutConstraint(item: googleImagesCollectionViewContainer, attribute: .top, relatedBy: .equal, toItem: previewWarningLabel, attribute: .bottom, multiplier: 1, constant: 10)
        
        let gImagesCollectionViewTrailingConstraint = NSLayoutConstraint(item: googleImagesCollectionViewContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10)
        let gImagesCollectionViewLeadingConstraint = NSLayoutConstraint(item: googleImagesCollectionViewContainer, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10)
        let gImagesCollectionViewBottomConstraint = NSLayoutConstraint(item: googleImagesCollectionViewContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10)
        
        view.addConstraints([gImagesCollectionViewTopConstraint, gImagesCollectionViewLeadingConstraint, gImagesCollectionViewTrailingConstraint, gImagesCollectionViewBottomConstraint])
        
        
        
        googleImagesCollectionViewController = GoogleImagesCollectionViewController()
        addChildViewController(googleImagesCollectionViewController!)
        
        googleImagesCollectionViewController?.view.backgroundColor = .white
        if let containedView = googleImagesCollectionViewController?.view {

            containedView.translatesAutoresizingMaskIntoConstraints = false

            googleImagesCollectionViewContainer.addSubview(containedView)

            NSLayoutConstraint.activate([
                containedView.leadingAnchor.constraint(equalTo: googleImagesCollectionViewContainer.leadingAnchor),
                containedView.trailingAnchor.constraint(equalTo: googleImagesCollectionViewContainer.trailingAnchor),
                containedView.topAnchor.constraint(equalTo: googleImagesCollectionViewContainer.topAnchor),
                containedView.bottomAnchor.constraint(equalTo: googleImagesCollectionViewContainer.bottomAnchor)
                ])



        }
        
        googleImagesCollectionViewController!.didMove(toParentViewController: self)
        
        if(titleTextField.text != ""){
            grabGoogleImages()
        }
    }
}
