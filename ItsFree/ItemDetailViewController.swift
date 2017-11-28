//
//  ItemDetailViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-22.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseStorage

class ItemDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var detailViewTopAnchorConstant: CGFloat!
    var detailViewBottomAnchorConstant: CGFloat!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var itemDetailView: ItemDetailView!
        
    var currentItem: Item!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        itemDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        //make this auto constrained
        detailViewTopAnchorConstant = UIScreen.main.bounds.height/1.7
        detailViewBottomAnchorConstant = 0
        
        NSLayoutConstraint.activate([
            itemDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            itemDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            itemDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: detailViewTopAnchorConstant),
            itemDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: detailViewBottomAnchorConstant)
            ])

        itemDetailView.alpha = 1
        itemDetailView.layer.cornerRadius = 30
        
        let storageRef = Storage.storage().reference()
        let previewPhotoRef: String = currentItem.photos[0]
        itemDetailView.itemTitleLabel.text = currentItem.name
        itemDetailView.categoryLabel.text = currentItem.itemCategory.rawValue
        itemDetailView.qualityLabel.text = currentItem.quality.rawValue
        itemDetailView.descriptionLabel.text = currentItem.itemDescription
        itemDetailView.mainImageView.sd_setImage(with: storageRef.child(previewPhotoRef), placeholderImage: UIImage.init(named: "placeholder"))
        print("Storage Location: \(storageRef.child(previewPhotoRef))")
        

        //gestures
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        itemDetailView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        itemDetailView.addGestureRecognizer(swipeDown)
        
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        let tapNavBar: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        self.view.addGestureRecognizer(tapOutside)
        self.navigationController?.navigationBar.addGestureRecognizer(tapNavBar)
        //self.navigationController?.navigationBar.ite
        
    }
    
    @objc func tappedOutside(gesture: UIGestureRecognizer){
        if (gesture.location(in: view).y < detailViewTopAnchorConstant) {
            self.view.removeGestureRecognizer(gesture)
            self.navigationController?.navigationBar.removeGestureRecognizer(gesture)
            self.willMove(toParentViewController: nil)
            let theParentViewController = self.parent as! HomeViewController
            theParentViewController.itemDetailContainerView.removeFromSuperview()
            theParentViewController.homeMapView.deselectAnnotation(currentItem, animated: true)
            //self.itemDetailView.removeFromSuperview()
            self.removeFromParentViewController()
            
        }
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
                theParentViewController.itemDetailContainerView.removeFromSuperview()
                theParentViewController.homeMapView.deselectAnnotation(self.currentItem, animated: true)
                //self.itemDetailView.removeFromSuperview()
                self.removeFromParentViewController()

            })
                
            } else if (swipeGesture.direction == UISwipeGestureRecognizerDirection.up) {
            
                //nav bar + status bar
                let yPoint = (self.navigationController?.navigationBar.frame.height)! + (UIApplication.shared.statusBarFrame.size.height)
                    
                UIView.animate(withDuration: 0.5, animations: {
                    self.itemDetailView.frame = CGRect(x: 0, y:yPoint, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    
                }, completion: {(finished: Bool) in
                    
                })
            }
        }
        itemDetailView.updateConstraints()
    }
    
    
    @IBAction func sendEmail(_ sender: UIButton) {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //show error if the VC cant send mail
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
        if(AppData.sharedInstance.onlineOfferedItems.contains(currentItem)){
            offerMessage(mailComposerVC: mailComposerVC)
            
        }
        else if(AppData.sharedInstance.onlineRequestedItems.contains(currentItem)){
            requestMessage(mailComposerVC: mailComposerVC)
        }

    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
           break
            
        case .saved:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .failed:
            print ("Mail sent failure: \([error!.localizedDescription])")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func offerMessage(mailComposerVC: MFMailComposeViewController){
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let destinationEmail = destinationUser!.email
        let destinationName = destinationUser!.name
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentItemName = currentItem.name
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail])
        mailComposerVC.setSubject("Second Life: \(currentUserName) wants your item")
        mailComposerVC.setMessageBody("Hey \(destinationName),\n\n I want your \(currentItemName).\n\n Please click this link if you give it to \(currentUserName), to auto-delete your item and so that he/she can rate you!\n\nThanks! :) ", isHTML: false)
    }
    
    func requestMessage(mailComposerVC: MFMailComposeViewController){
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let destinationEmail = destinationUser!.email
        let destinationName = destinationUser!.name
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentItemName = currentItem.name
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail])
        mailComposerVC.setSubject("Second Life: \(currentUserName) has something you want")
        mailComposerVC.setMessageBody("Hey \(destinationName),\n\n I have a \(currentItemName).\n\n Please click this link if \(currentUserName) gives you the item, to auto-delete your post from the app and so that you can rate him/her!\n\nThanks! :) ", isHTML: false)
    }
    
}
