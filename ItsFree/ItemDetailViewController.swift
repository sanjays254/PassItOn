//
//  ItemDetailViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var detailViewTopAnchorConstant: CGFloat!
    var detailViewBottomAnchorConstant: CGFloat!
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var itemDetailView: ItemDetailView!
        
    var currentItem: Item!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        itemDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        detailViewTopAnchorConstant = 250
        detailViewBottomAnchorConstant = 0
        
        NSLayoutConstraint.activate([
            itemDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            itemDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            itemDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: detailViewTopAnchorConstant),
            itemDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailViewBottomAnchorConstant)
            ])
        

        itemDetailView.alpha = 1
        
        
        itemDetailView.itemTitleLabel.text = currentItem.name
        itemDetailView.categoryLabel.text = currentItem.itemCategory.rawValue
        itemDetailView.qualityLabel.text = currentItem.quality.rawValue
        itemDetailView.descriptionLabel.text = currentItem.itemDescription
        //itemDetailView.mainImageView = currentItem.
        
        

        //gestures
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        itemDetailView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        itemDetailView.addGestureRecognizer(swipeDown)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @objc func swipe(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if (swipeGesture.direction == UISwipeGestureRecognizerDirection.down) {
 
            UIView.animate(withDuration: 0.5, animations: {
                self.itemDetailView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                
            }, completion: {(finished: Bool) in
                
                self.willMove(toParentViewController: nil)
                let theParentViewController = self.parent as! HomeViewController
                theParentViewController.containerView.removeFromSuperview()
                //self.itemDetailView.removeFromSuperview()
                self.removeFromParentViewController()

            })
                
              
            
            } else if (swipeGesture.direction == UISwipeGestureRecognizerDirection.up) {
            
                UIView.animate(withDuration: 0.5, animations: {
                    self.itemDetailView.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    
                }, completion: {(finished: Bool) in
                    
                })
            }
        }
        itemDetailView.updateConstraints()
    }
}
