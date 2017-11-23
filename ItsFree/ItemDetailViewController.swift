//
//  ItemDetailViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var detailContainerViewTopAnchorConstant: CGFloat!
    var detailContainerViewBottomAnchorConstant: CGFloat!
    var detailContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        detailContainerView = UIView()
        detailContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailContainerView)
        
        detailContainerViewTopAnchorConstant = 0
        detailContainerViewBottomAnchorConstant = 0
        
        NSLayoutConstraint.activate([
            detailContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            detailContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            detailContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: detailContainerViewTopAnchorConstant),
            detailContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailContainerViewBottomAnchorConstant)
            ])
        
        detailContainerView.backgroundColor = UIColor.blue
        view.bringSubview(toFront: detailContainerView)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.down
        detailContainerView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        detailContainerView.addGestureRecognizer(swipeUp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    
    
    @objc func swipe(swipeGesture: UISwipeGestureRecognizer) {
        if (swipeGesture.direction == UISwipeGestureRecognizerDirection.down) {
            
            //self.willMove(toParentViewController: nil)

            
            UIView.animate(withDuration: 0.5, animations: {self.view.alpha = 0.0}, completion: {(finished: Bool) in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            })
            
            
            
        } else if (swipeGesture.direction == UISwipeGestureRecognizerDirection.up) {
            
        }
        
        detailContainerView.updateConstraints()
        
    }

}
