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
    
 
    var meetupButton: UIBarButtonItem!
    
    var thread: PThread?
    
    var item: Item!
    var destinationUser: User!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let thread = thread {
            goToChat(thread: thread)
        }
        else {
            startChatWithUser()
        }
        
        
    }
    
    func startChatWithUser () {
        
        let coreHandler = BAbstractCoreHandler.init()
        
        let destUser = coreHandler.user(forEntityID: destinationUser.UID)
  
        if let destUser = destUser {
            
            NM.core().createThread(withUsers: [destUser], name: "\(item.name) - \(destinationUser.name)", threadCreated: {(error, thread) in
                
                if let error = error {
                    //something went wrong
                }
                else {
                    
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
    
    
    
    func goToChat(thread: PThread){
        
        let chatVc = BInterfaceManager.shared().a.chatViewController(with: thread)
        
        if let chatVc = chatVc {
            
            self.addChildViewController(chatVc)
            chatVc.view.frame = CGRect(x: 0, y: 0, width: self.chatContainerView.frame.width, height: self.chatContainerView.frame.height)
            
            self.chatContainerView.addSubview(chatVc.view)
            chatVc.didMove(toParentViewController:self)
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
