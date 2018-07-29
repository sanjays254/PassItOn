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

class ItemDetailViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    


    var detailViewTopAnchorConstant: CGFloat!
    var detailViewBottomAnchorConstant: CGFloat!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var itemDetailView: ItemDetailView!

    weak var currentItem: Item!
    let storageRef = Storage.storage().reference()
  
    var kindOfItem: String!

    var mainImageTapRecognizer: UITapGestureRecognizer!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
    
        setupCollectionView()
        setupItemDetailContainer()
        setupItemLabels()
        setupGestures()
        
        
        ReadFirebaseData.readUserBasics(userUID: currentItem.posterUID, completion: {(success, user) in
            if (success){
                
                self.itemDetailView.posterUsername.text = user!.name
                self.itemDetailView.posterRating.text = "\(user!.rating)"
                
            }
            else {
                
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Oops", inpMessage: "The poster seems to have left the app", inpOkTitle: "Ok")
                
            }
            
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func setupItemDetailContainer(){
        
        itemDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        detailViewTopAnchorConstant = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.categoryLabel.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
        
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
    }
    
    func setupGestures(){
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        itemDetailView.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        itemDetailView.addGestureRecognizer(swipeDown)
        
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutside))
        
        tapOutside.delegate = self
        self.view.addGestureRecognizer(tapOutside)
    }
    
    
    func setupItemLabels(){
        
        let previewPhotoRef: String = currentItem.photos[0]
        
        itemDetailView.itemTitleLabel.text = currentItem.name
        itemDetailView.categoryLabel.text = currentItem.itemCategory.rawValue
        itemDetailView.qualityLabel.text = currentItem.quality.rawValue
        itemDetailView.descriptionLabel.text = currentItem.itemDescription
        
        itemDetailView.mainImageView.isUserInteractionEnabled = true
        mainImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mainImageTapped))
        itemDetailView.mainImageView.addGestureRecognizer(mainImageTapRecognizer)
        itemDetailView.mainImageView.layer.borderColor = UIColor.black.cgColor
        itemDetailView.mainImageView.layer.borderWidth = 5
        itemDetailView.mainImageView.layer.cornerRadius = 5
        itemDetailView.mainImageView.sd_setImage(with: storageRef.child(previewPhotoRef), placeholderImage: UIImage.init(named: "placeholder"))
        //ImageManager.downloadImage(imagePath: previewPhotoRef, into: itemDetailView.mainImageView)
        
        itemDetailView.posterUsername.text = "Loading ..."
        itemDetailView.posterRating.text = "0"
        
    
        if (kindOfItem == "Offer"){
            itemDetailView.itemValueLabel.text = "Value: $\(currentItem.value)"
        }
        else if (kindOfItem == "Request"){
            itemDetailView.itemValueLabel.text = ""
        }
    }
    
    @objc func mainImageTapped(recognizer: UITapGestureRecognizer) {
        fullscreenImage(imagePath: currentItem.photos[0])
    }
    
    func setupCollectionView(){
        
        itemDetailView.photoCollectionView.frame.size.height =  UIScreen.main.bounds.size.height/9
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemDetailView.photoCollectionView.frame.height, height: itemDetailView.photoCollectionView.frame.height)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing =  10
    
        itemDetailView.photoCollectionView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
        
        itemDetailView.photoCollectionView.contentInsetAdjustmentBehavior = .never
        itemDetailView.photoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        itemDetailView.photoCollectionView.setContentOffset(CGPoint(), animated: true)
        itemDetailView.photoCollectionView.delegate = self
        itemDetailView.photoCollectionView.dataSource = self
        
        itemDetailView.photoCollectionView.isUserInteractionEnabled = true
        
        let nibName = UINib(nibName: "ItemPhotoCollectionViewCell", bundle:nil)
        itemDetailView.photoCollectionView.register(nibName, forCellWithReuseIdentifier: "itemPhotoCollectionViewCell")
        
        itemDetailView.photoCollectionView.backgroundColor = UIProperties.sharedUIProperties.purpleColour
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (self.itemDetailView.photoCollectionView.bounds.contains(touch.location(in: self.itemDetailView.photoCollectionView))) {

            return false
        }
        
        else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let viewWidth = CGFloat(itemDetailView.photoCollectionView.frame.width * 1)
        let totalCellWidth = (itemDetailView.photoCollectionView.frame.size.height-30) * CGFloat(currentItem.photos.count);
        let totalSpacingWidth = 10 * CGFloat(currentItem.photos.count - 1);
        
        let leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
        let rightInset = leftInset;
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: itemDetailView.photoCollectionView.frame.size.height-30, height: itemDetailView.photoCollectionView.frame.size.height-30);
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        let photoRef: [String] = currentItem.photos
        return photoRef.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemPhotoCollectionViewCell", for: indexPath) as! ItemPhotoCollectionViewCell
        
        let photoRef: [String] = currentItem.photos
    
        cell.layer.borderColor = UIProperties.sharedUIProperties.blackColour.cgColor
        cell.layer.borderWidth = 5.0
        cell.layer.cornerRadius = 5.0
        //ImageManager.downloadImage(imagePath: photoRef[indexPath.item], into: cell.collectionViewImageVew)
        cell.collectionViewImageVew.sd_setImage(with: storageRef.child(photoRef[indexPath.item]), placeholderImage: UIImage.init(named: "placeholder"))

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoRef: [String] = currentItem.photos
        fullscreenImage(imagePath: photoRef[indexPath.item])
    }
    
    //When screen is tapped outside the itemDetailView, go back to Map
    @objc func tappedOutside(gesture: UIGestureRecognizer){
        if (gesture.location(in: view).y < detailViewTopAnchorConstant) {
            self.view.removeGestureRecognizer(gesture)
            self.navigationController?.navigationBar.removeGestureRecognizer(gesture)
            self.willMove(toParentViewController: nil)
            let theParentViewController = self.parent as! HomeViewController
            theParentViewController.itemDetailContainerView.removeFromSuperview()
            theParentViewController.homeMapView.deselectAnnotation(currentItem, animated: true)
            self.removeFromParentViewController()
        }
    }

    
    @objc func swipe(gesture: UIGestureRecognizer) {
        
        let topOfFullViewFrame = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.photoCollectionView.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
        
        let topOfPreviewFrame = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.categoryLabel.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
        
        
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if (swipeGesture.direction == UISwipeGestureRecognizerDirection.down) {
                
                if (self.itemDetailView.frame.minY == topOfFullViewFrame){
                    
                    detailViewTopAnchorConstant = topOfPreviewFrame
                    
            
                    UIView.animate(withDuration: 0.5, animations: {
                        self.itemDetailView.frame = CGRect(x: 0, y: self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        
                        
                        
                        self.itemDetailView.leftUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi*2))
                        self.itemDetailView.rightUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * -0.9999*2))
                        
                    }, completion: {(finished: Bool) in
                    })
                    
                }
                
                else if (self.itemDetailView.frame.minY == topOfPreviewFrame){
 
                    UIView.animate(withDuration: 0.5, animations: {
                        self.itemDetailView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        
                       
                        
                    }, completion: {(finished: Bool) in
                        
                        self.willMove(toParentViewController: nil)
                        let theParentViewController = self.parent as! HomeViewController
                        theParentViewController.itemDetailContainerView.removeFromSuperview()
                        theParentViewController.homeMapView.deselectAnnotation(self.currentItem, animated: true)
                        
                        self.removeFromParentViewController()
                        
                    })
                }
                
            } else if (swipeGesture.direction == UISwipeGestureRecognizerDirection.up) {
            
                //this constant allows all details to be shown, and no empty space
                
                detailViewTopAnchorConstant = (UIScreen.main.bounds.size.height-(itemDetailView.mainImageView.frame.minY+itemDetailView.photoCollectionView.frame.maxY)) - (44 + (UIApplication.shared.statusBarFrame.size.height))
            
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    
                    self.itemDetailView.leftUpArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * -0.9999))
                    self.itemDetailView.rightUpArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    
                }, completion: {(finished: Bool) in
                    
                                        self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                })
            }
        }
        itemDetailView.updateConstraints()
    }
    
    
    func fullscreenImage(imagePath : String) {
        
        if (imagePath == ""){
            let noImageAlert = UIAlertController(title: "Sorry", message: "This item doesn't have an image", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            noImageAlert.addAction(okayAction)
            
            present(noImageAlert, animated: true, completion: nil)
        }
        
        else {
        
            let newImageView = UIImageView()
            //ImageManager.downloadImage(imagePath: imagePath, into: newImageView)
            newImageView.sd_setImage(with: storageRef.child(imagePath), placeholderImage: UIImage.init(named: "placeholder"))
            
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
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        UIView.animate(withDuration: 0, animations: {}, completion: {(finished: Bool) in
            
            self.itemDetailView.frame = CGRect(x: 0, y:self.detailViewTopAnchorConstant, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        })
        
        sender.view?.removeFromSuperview()
    }
    
    
    
    @IBAction func sendEmail(_ sender: UIButton) {
        
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first

        if(AppData.sharedInstance.currentUser!.UID == destinationUser?.UID){
            //show alert
            let usersOwnItemAlert = UIAlertController(title: "Oops", message: "This item was posted by you", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            usersOwnItemAlert.addAction(okayAction)
            present(usersOwnItemAlert, animated: true, completion: nil)

        }
        else {
            
            if (destinationUser?.phoneNumber != 0){
            
            let textOrEmailAlert = UIAlertController(title: "How would you like to message \((destinationUser?.name)!)?", message: "", preferredStyle: .actionSheet)
            
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: {_ in
                self.emailChosen()})
            
            let textAction = UIAlertAction(title: "Text", style: .default, handler: {_ in
                self.textChosen()})
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            textOrEmailAlert.addAction(emailAction)
            textOrEmailAlert.addAction(textAction)
            textOrEmailAlert.addAction(cancelAction)
            
            self.present(textOrEmailAlert, animated: true, completion: nil)
            }
            else {
                emailChosen()
            }
        }

    }
    
    func emailChosen(){
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
    
    func textChosen(){
        
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        
        if (MFMessageComposeViewController.canSendText()) {
            self.present(messageController, animated: true, completion: nil)
        }
        else {
            self.showSendTextErrorAlert()
        }
        
        if(AppData.sharedInstance.onlineOfferedItems.contains(currentItem)){
            offerText(messageComposerVC: messageController)
            
        }
        else if(AppData.sharedInstance.onlineRequestedItems.contains(currentItem)){
            requestText(messageComposerVC: messageController)
        }
        
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func showSendTextErrorAlert() {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Text", message: "Your device could not send a text.  Please check your message configuration and try again.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            break
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to mapView")
            
        case .failed:
            print ("Message sent failure")
        }
        self.dismiss(animated: true, completion: nil)
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
        let currentUserEmail = AppData.sharedInstance.currentUser!.email
        let currentItemName = currentItem.name
        let currentItemID = currentItem.UID
        
        let attrLinkString = NSMutableAttributedString(string: "Click here to Rate \(destinationName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(destinationUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail, currentUserEmail])
        mailComposerVC.setSubject("Pass It On: \(currentUserName) wants your item")
        mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I want your \(currentItemName).<br><br>Thanks!<br><br>---------------------<br><br>Admin Message to \(currentUserName): Use the link below to rate \(destinationName), if you like or dislike the item. There will be a copy of this email in your inbox<br><br> \(linkString!)<br><br>Thanks! :)", isHTML: true)
        
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
        
        let attrLinkString = NSMutableAttributedString(string: "Click Here to Rate \(currentUserName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(currentUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail])
        mailComposerVC.setSubject("Pass It On: \(currentUserName) has something you want")
        mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I have a \(currentItemName).<br><br><br><br>Admin message to \(destinationName): Please click the link below if \(currentUserName) gives you the item, to easily delete your post from the app and so that you can rate him/her!<br><br>\(linkString!)<br><brThanks! :) ", isHTML: true)
    }
    
    func offerText(messageComposerVC: MFMessageComposeViewController){
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let destinationName = destinationUser!.name
        let destinationUserID = destinationUser!.UID
        let destinationPhoneNumber = String((destinationUser!.phoneNumber))
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentItemName = currentItem.name
        let currentItemID = currentItem.UID
        
        let attrLinkString = NSMutableAttributedString(string: "Click here to Rate \(destinationName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(destinationUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        messageComposerVC.recipients = [destinationPhoneNumber]
        messageComposerVC.body = "Hey \(destinationName),\n\nI want your \(currentItemName). Thanks!\n\n-----------\n\nAdmin Message to \(currentUserName): Use the link below to rate \(destinationName), if you like or dislike the item.\n\niOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(destinationUserID!)\n\nThanks! :)"
        //, isHTML: true)
        
        //send a message to current user with link instead of putting link in here
    }
    
    func requestText(messageComposerVC: MFMessageComposeViewController){
        let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == currentItem.posterUID }.first
        
        let destinationName = destinationUser!.name
        let destinationPhoneNumber = String((destinationUser!.phoneNumber))
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentUserID = AppData.sharedInstance.currentUser!.UID
        let currentItemName = currentItem.name
        let currentItemID = currentItem.UID
        
        let attrLinkString = NSMutableAttributedString(string: "Click Here to Rate \(currentUserName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(currentUserID!)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        //mailVC properties
        messageComposerVC.recipients = [destinationPhoneNumber]
        
        messageComposerVC.body = "Hey \(destinationName),\n\nI have a \(currentItemName).\n\nAdmin message to \(destinationName): Please click the link below if \(currentUserName) gives you the item, to easily delete your post from the app and so that you can rate him/her!\n\niOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(currentUserID!)\n\nThanks! :)"
    }
    
}
