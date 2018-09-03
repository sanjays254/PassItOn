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
    var meetupButton: UIBarButtonItem!
    
    var thread: PThread?
    
    var item: Item!
    var destinationUser: User!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if opened from convos, we need to find the user and the item
        if destinationUser == nil {
            
     
        }

 
        
        let meetupBarButton = UIBarButtonItem.init(title: "Meetup", style: .plain, target: self, action: #selector(meetup))
        
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
        
        //meetup feature
        
    }
    
    func startChatWithUser () {
        
        
        self.title = "\(destinationUser.name)"
        
        let coreHandler = BAbstractCoreHandler.init()
        
        let destUser = coreHandler.user(forEntityID: destinationUser.UID)
  
        if let destUser = destUser {
            
            
            
            NM.core().createThread(withUsers: [destUser], name: "\(item.name) - \(destinationUser.name)", threadCreated: {(error, thread) in
                
                if let error = error {
                    //something went wrong
                }
                else {
                    
                    self.thread = thread
                    
                    self.thread?.setMetaString("\(self.item.UID)", forKey: "itemUID")
                    
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
        
        if let itemID = thread?.metaString(forKey: "itemUID"),
            let userID = thread?.metaString(forKey: "userUID") {
        
    
        ReadFirebaseData.readUserBasics(userUID: userID, completion: {(success, user) in
            
            if success {
                
               // ReadItem here
                
                self.destinationUser = user!
                self.title = "\(user!.name)"
                
            }
            else {
                Alert.Show(inpVc: self, customAlert: nil, inpTitle: "User is not available", inpMessage: "The user has left the app", inpOkTitle: "Ok")
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
