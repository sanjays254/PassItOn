//
//  ConversationsViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-08-13.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit
import ChatSDK


class ConversationsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let conversationsVC = BInterfaceManager.shared().a.privateThreadsViewController() {
            
//            self.navigationController?.pushViewController(conversationsVC, animated: true)
//            // conversationsVC.navigationController?.navigationBar.isHidden = false
//            conversationsVC.navigationController?.setNavigationBarHidden(false, animated: true)
//
        
        
            self.addChildViewController(conversationsVC)
            conversationsVC.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height)
        
            self.containerView.addSubview(conversationsVC.view)
            conversationsVC.didMove(toParentViewController:self)
            
        }
        
    
    
        //self.navigationController?.pushViewController(conversationsVC!, animated: true)
    
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification), name: NSNotification.Name(rawValue: "notifyme"), object: nil)
    
    
    
    
        // Do any additional setup after loading the view.
    }

    @objc func receiveNotification(ns: NSNotification){
    
        let vc = ns.userInfo!["ThreadVC"] as! UIViewController
    
        self.navigationController?.pushViewController(vc, animated: true)
        

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
