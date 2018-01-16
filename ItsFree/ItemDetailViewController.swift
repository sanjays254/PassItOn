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

class ItemDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    

    var detailViewTopAnchorConstant: CGFloat!
    var detailViewBottomAnchorConstant: CGFloat!
    
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var itemDetailView: ItemDetailView!
        
    //@IBOutlet weak var collectionViewContentView: UIView!
    var currentItem: Item!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupCollectionView()
        
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
        itemDetailView.layer.borderWidth = 5
        itemDetailView.layer.borderColor = UIColor.black.cgColor
        
        let storageRef = Storage.storage().reference()
        let previewPhotoRef: String = currentItem.photos[0]
        
        itemDetailView.itemTitleLabel.text = currentItem.name
        itemDetailView.categoryLabel.text = currentItem.itemCategory.rawValue
        itemDetailView.qualityLabel.text = currentItem.quality.rawValue
        itemDetailView.descriptionLabel.text = currentItem.itemDescription
        itemDetailView.mainImageView.layer.borderColor = UIColor.black.cgColor
        itemDetailView.mainImageView.layer.borderWidth = 5
        itemDetailView.mainImageView.layer.cornerRadius = 5
        
        itemDetailView.mainImageView.sd_setImage(with: storageRef.child(previewPhotoRef), placeholderImage: UIImage.init(named: "placeholder"))
        print("Storage Location: \(storageRef.child(previewPhotoRef))")
        
        itemDetailView.posterUsername.text = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first?.name
        itemDetailView.posterRating.text = "Score: \(AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first?.rating ?? 0)"
        
        

        //gestures
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        itemDetailView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        itemDetailView.addGestureRecognizer(swipeDown)
        
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))

        self.view.addGestureRecognizer(tapOutside)

        
    }
    
    
    func setupCollectionView(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemDetailView.collectionContentView.frame.height, height: itemDetailView.collectionContentView.frame.height)
        flowLayout.scrollDirection = .horizontal

        
        let photoCollectionView = UICollectionView(frame: CGRect(x:0, y:0, width: itemDetailView.collectionContentView.frame.width, height: itemDetailView.collectionContentView.frame.height), collectionViewLayout: flowLayout)
        
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        photoCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "itemPhotoCollectionViewCell")
        
        photoCollectionView.backgroundColor = UIColor.black
        
        
        
        itemDetailView.collectionContentView.addSubview(photoCollectionView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        let photoRef: [String] = currentItem.photos
        return photoRef.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemPhotoCollectionViewCell", for: indexPath)
        
   
        let storageRef = Storage.storage().reference()
        let photoRef: [String] = currentItem.photos
    
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "compass"))
        
        imageView.sd_setImage(with: storageRef.child(photoRef[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))
        print("Storage Location: \(storageRef.child(photoRef[indexPath.row]))")
        
     
        cell.contentView.addSubview(imageView)
        
        return cell
        
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
                let yPoint = (self.navigationController?.navigationBar.frame.height)! + (UIApplication.shared.statusBarFrame.size.height) + UIScreen.main.bounds.size.height/3
                
       
                    
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
        
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        if(AppData.sharedInstance.currentUser!.UID == destinationUser?.UID){
            //show alert
            let usersOwnItemAlert = UIAlertController(title: "Oops", message: "This item was posted by you", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            usersOwnItemAlert.addAction(okayAction)
            present(usersOwnItemAlert, animated: true, completion: nil)
            
        }
        else {
        
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
        let destinationUserID = destinationUser!.UID
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentUserID = AppData.sharedInstance.currentUser!.UID
        let currentUserEmail = AppData.sharedInstance.currentUser!.email
        let currentItemName = currentItem.name
        let currentItemID = currentItem.UID
        
        let attrLinkString = NSMutableAttributedString(string: "Click here to Rate \(destinationName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSAnotherLifeApp://?itemID=\(currentItemID!)&userID=\(destinationUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail, currentUserEmail])
        mailComposerVC.setSubject("FreeBox: \(currentUserName) wants your item")
        mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I want your \(currentItemName).<br><br>Thanks!<br><br>---------------------<br><br>Admin Message to \(currentUserName): Use the link below to rate \(destinationName), if you like or dislike the item. There will be a copy in your inbox<br><br> \(linkString!)<br><br>Thanks! :)", isHTML: true)
        
        //send an email to current user with link instead of putting link in here
    }
    
    func requestMessage(mailComposerVC: MFMailComposeViewController){
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let destinationEmail = destinationUser!.email
        let destinationName = destinationUser!.name
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentUserID = AppData.sharedInstance.currentUser!.UID
        let currentItemName = currentItem.name
        let currentItemID = currentItem.UID
        
        
        let attrLinkString = NSMutableAttributedString(string: "Click Here to Rate")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSAnotherLifeApp://?itemID=\(currentItemID!)&userID=\(currentUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail])
        mailComposerVC.setSubject("FreeBox: \(currentUserName) has something you want")
        mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I have a \(currentItemName).<br><br><br><br>Admin message: Please click the link below if \(currentUserName) gives you the item, to easily delete your post from the app and so that you can rate him/her!<br><br>\(linkString!)<br><brThanks! :) ", isHTML: true)
    }
    
}
