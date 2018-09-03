//
//  ChatThreadViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-13.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit
import ChatSDK


class ChatThreadViewController: UIViewController {
    
    
    @IBOutlet weak var chatContainerView: UIView!
    
 

    var embeddedVC: UIViewController?
    var meetupBarButton: UIBarButtonItem!
    
    var thread: PThread?
    
    var item: Item?
    var destinationUser: User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //if opened from convos, we need to find the user and the item
//        if destinationUser == nil {
//
//
//        }

 
        
        meetupBarButton = UIBarButtonItem.init(title: "Meetup", style: .plain, target: self, action: #selector(meetup))
        
       
        
        self.navigationItem.rightBarButtonItems = [meetupBarButton]
        
        if let embeddedVC = embeddedVC {
            goToChat()
        }
        else {
            
            //if thread does
            startChatWithUser()
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let thread = thread {
            if thread.allMessages().count == 0 {
                //delete chat
                NM.core().delete(thread)
            }
        }
    }
    
    @objc func meetup(){
        
        
        
        //if item exists, it means user definitely exists
        if let item = self.item {
            
            //payment feature and Rating feature here
            
            Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Coming soon!", inpMessage: "Payment & Rating feature coming soon", inpOkTitle: "Ok")
            
        }
        
    }
    
    func startChatWithUser () {
        
        
        self.title = "\(destinationUser.name)"
        
        let coreHandler = BAbstractCoreHandler.init()
        
        let destUser = coreHandler.user(forEntityID: destinationUser.UID)
  
        if let destUser = destUser,
            let item = item {
            
            
            
            NM.core().createThread(withUsers: [destUser], name: "\(item.name) - \(destinationUser.name)", threadCreated: {(error, thread) in
                
                if let error = error {
                    //something went wrong
                }
                else {
                    
                    self.thread = thread
                    
                    self.thread?.setMetaString("\(item.UID)", forKey: "itemUID")
                    
                    self.thread?.setMetaString("\(self.destinationUser.UID)", forKey: "userUID")
                    
                    
//                    var threadMetadata = thread?.metaDictionary()
//                    
//                    threadMetadata!["itemID"] = "\(self.item.UID)"
//                    
//                    thread?.setMetaDictionary(threadMetadata)
                    
                
                    
                    let cvc = BInterfaceManager.shared().a.chatViewController(with: thread)
                    
                    if let cvc = cvc {
                        
                        self.addChildViewController(cvc)
                        cvc.view.frame = CGRect(x: 0, y: 0, width: self.chatContainerView.frame.width, height: self.chatContainerView.frame.height)
                        
                        self.chatContainerView.addSubview(cvc.view)
                        cvc.didMove(toParentViewController:self)
                        
                        
                    }
                }
            })
        }
        
    }
    
    
    
    func goToChat(){
        
        //let chatVc = BInterfaceManager.shared().a.chatViewController(with: thread)
         meetupBarButton.isEnabled = false
        
        if let itemID = thread!.metaString(forKey: "itemUID"),
            let userID = thread!.metaString(forKey: "userUID") {
        
    
        ReadFirebaseData.readUserBasics(userUID: userID, completion: {(success, user) in
            
            if success {
                
               // ReadItem here
                self.item = ReadFirebaseData.readItem(itemUID: itemID)
                
                if self.item == nil {
                    Alert.Show(inpVc: self, customAlert: nil, inpTitle: "Item is not available", inpMessage: "The item you have been discussing may have been deleted", inpOkTitle: "Okay")
                }
                
                else {
                    self.meetupBarButton.isEnabled = true
                }
                
                self.destinationUser = user!
                self.title = "\(user!.name)"
                
            }
            else {
                
                let alert = UIAlertController(title: "User is not available", message: "The user has left the app", preferredStyle: .alert)
                
                let deleteChatAction = UIAlertAction(title: "Delete Conversation", style: .destructive, handler: {(action) in
                    
                    //delete chat
                    
                })
                
                let cancelAction = UIAlertAction(title: "See Conversation", style: .default, handler: nil)
                
                let backAction = UIAlertAction(title: "Go back to all conversations", style: .cancel, handler: {(action) in
                    
                    self.navigationController?.popViewController(animated: true)
                    
                })
                
                
                alert.addAction(deleteChatAction)
                alert.addAction(cancelAction)
                alert.addAction(backAction)
                
                self.present(alert, animated: true, completion: nil)
                
                
                
                
            }
            
        })
        }
        
        if let embeddedChatViewController = embeddedVC {
            
            self.addChildViewController(embeddedChatViewController)
            embeddedChatViewController.view.frame = CGRect(x: 0, y: 0, width: self.chatContainerView.frame.width, height: self.chatContainerView.frame.height)
            
            self.chatContainerView.addSubview(embeddedChatViewController.view)
            embeddedChatViewController.didMove(toParentViewController:self)
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
