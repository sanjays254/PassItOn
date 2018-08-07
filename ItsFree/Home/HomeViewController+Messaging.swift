//
//  HomeViewController+Messaging.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-05.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


extension HomeViewController {
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            break
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to tableView")
            
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
            print ("Go back to tableView")
            
        case .sent:
            //self.performSegue(withIdentifier: "unwindToInitialVC", sender: self)
            print ("Go back to tableView")
            
        case .failed:
            print ("Mail sent failure: \([error!.localizedDescription])")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    func emailChosen(inpVC: UIViewController, item: Item, destinationUser: User){
        let mailComposerVC = MFMailComposeViewController()
        
        if let inpVC = inpVC as? ItemDetailViewController{
            mailComposerVC.mailComposeDelegate = inpVC
        }
        if let inpVC = inpVC as? HomeViewController {
            mailComposerVC.mailComposeDelegate = inpVC
        }
        
        //show error if the VC cant send mail
        if MFMailComposeViewController.canSendMail()
        {
            inpVC.present(mailComposerVC, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert(inpVC: inpVC)
        }
        
        if(AppData.sharedInstance.onlineOfferedItems.contains(item)){
            offerMessage(mailComposerVC: mailComposerVC, item: item, destinationUser: destinationUser)
            
        }
        else if(AppData.sharedInstance.onlineRequestedItems.contains(item)){
            requestMessage(mailComposerVC: mailComposerVC, item: item, destinationUser: destinationUser)
        }
    }
    
    func textChosen(inpVC: UIViewController, item: Item, destinationUser: User){
        
        let messageController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = inpVC as? MFMessageComposeViewControllerDelegate
        
        if (MFMessageComposeViewController.canSendText()) {
            self.present(messageController, animated: true, completion: nil)
        }
        else {
            showSendTextErrorAlert(inpVC: inpVC)
        }
        
        if(AppData.sharedInstance.onlineOfferedItems.contains(item)){
            offerText(messageComposerVC: messageController, item: item, destinationUser: destinationUser)
            
        }
        else if(AppData.sharedInstance.onlineRequestedItems.contains(item)){
            requestText(messageComposerVC: messageController, item: item, destinationUser: destinationUser)
        }
        
    }
    
    func showSendMailErrorAlert(inpVC: UIViewController) {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        inpVC.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func showSendTextErrorAlert(inpVC: UIViewController) {
        let sendMailErrorAlert = UIAlertController.init(title: "Could Not Send Text", message: "Your device could not send a text.  Please check your message configuration and try again.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        inpVC.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    
    func offerMessage(mailComposerVC: MFMailComposeViewController, item: Item, destinationUser: User){

        let destinationEmail = destinationUser.email
        let destinationName = destinationUser.name
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentUserEmail = AppData.sharedInstance.currentUser!.email
        
        let currentItemName = item.name
        
        if let destinationUserID = destinationUser.UID,
            let currentItemID = item.UID {
 
         let linkString = createAttrLinkString(rateeName: destinationName, rateeUID: destinationUserID, itemUID: currentItemID)

        
        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail, currentUserEmail])
        mailComposerVC.setSubject("Pass It On: \(currentUserName) wants your item")
            mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I want your \(currentItemName).<br><br>Thanks!<br><br>---------------------<br><br>Admin Message to \(currentUserName): Use the link below to rate \(destinationName), if you like or dislike the item. There will be a copy of this email in your inbox<br><br> \(linkString)<br><br>Thanks! :)", isHTML: true)
        }
        
        //send an email to current user with link instead of putting link in here
    }
    
    func requestMessage(mailComposerVC: MFMailComposeViewController, item: Item, destinationUser: User){
        
        let destinationEmail = destinationUser.email
        let destinationName = destinationUser.name
        let currentItemName = item.name
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        
        if let currentUserID = AppData.sharedInstance.currentUser!.UID,
            let currentItemID = item.UID {
        
        let linkString = createAttrLinkString(rateeName: currentUserName, rateeUID: currentUserID, itemUID: currentItemID)

        //mailVC properties
        mailComposerVC.setToRecipients([destinationEmail])
        mailComposerVC.setSubject("Pass It On: \(currentUserName) has something you want")
        mailComposerVC.setMessageBody("Hey \(destinationName),<br><br> I have a \(currentItemName).<br><br><br><br>Admin message to \(destinationName): Please click the link below if \(currentUserName) gives you the item, to easily delete your post from the app and so that you can rate him/her!<br><br>\(linkString)<br><brThanks! :) ", isHTML: true)
        }
    }
    
    func offerText(messageComposerVC: MFMessageComposeViewController, item: Item, destinationUser: User){
      //  let destinationUser = AppData.sharedInstance.onlineUsers.filter{ $0.UID == item.posterUID }.first
        
        let destinationName = destinationUser.name
        let destinationUserID = destinationUser.UID
        let destinationPhoneNumber = String((destinationUser.phoneNumber))
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentItemName = item.name
        let currentItemID = item.UID
        
        
        messageComposerVC.recipients = [destinationPhoneNumber]
        messageComposerVC.body = "Hey \(destinationName),\n\nI want your \(currentItemName). Thanks!\n\n-----------\n\nAdmin Message to \(currentUserName): Use the link below to rate \(destinationName), if you like or dislike the item.\n\niOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(destinationUserID!)\n\nThanks! :)"
    
        
        //send a message to current user with link instead of putting link in here
    }
    
    func requestText(messageComposerVC: MFMessageComposeViewController, item: Item, destinationUser: User){
        
        let destinationName = destinationUser.name
        let destinationPhoneNumber = String((destinationUser.phoneNumber))
        
        let currentUserName = AppData.sharedInstance.currentUser!.name
        let currentUserID = AppData.sharedInstance.currentUser!.UID
        let currentItemName = item.name
        let currentItemID = item.UID

        //mailVC properties
        messageComposerVC.recipients = [destinationPhoneNumber]
        
        messageComposerVC.body = "Hey \(destinationName),\n\nI have a \(currentItemName).\n\nAdmin message to \(destinationName): Please click the link below if \(currentUserName) gives you the item, to easily delete your post from the app and so that you can rate him/her!\n\niOSPassItOnApp://?itemID=\(currentItemID!)&userID=\(currentUserID!)\n\nThanks! :)"
    }
    
    
    
    
    func createAttrLinkString(rateeName: String, rateeUID: String, itemUID: String) -> String {
        
        let attrLinkString = NSMutableAttributedString(string: "Click Here to Rate \(rateeName)")
        attrLinkString.addAttribute(NSAttributedStringKey.link, value: NSURL(string: "iOSPassItOnApp://?itemID=\(itemUID)&userID=\(rateeUID)")! , range: NSMakeRange(0, attrLinkString.length))
        
        var linkString: String! = ""
        
        do {
            let data = try attrLinkString.data(from: NSMakeRange(0, attrLinkString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType : NSAttributedString.DocumentType.html])
            linkString = String(data: data, encoding: String.Encoding.utf8)
        }catch {
            print("error creating HTML from Attributed String")
        }
        
        return linkString
        
    }
    
}
