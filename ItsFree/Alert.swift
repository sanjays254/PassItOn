//
//  Alert.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-07-26.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class Alert: NSObject {
    
    class func Show(inpVc: UIViewController,
                   customAlert: UIAlertController?,
                   inpTitle: String?,
                   inpMessage: String?,
                   inpOkTitle: String) -> Void
    {
        var alert: UIAlertController!
        let okAction: UIAlertAction! = UIAlertAction (title: inpOkTitle,
                                                      style: UIAlertActionStyle.cancel,
                                                      handler: nil);
        if ( customAlert != nil)
        {
            alert = customAlert;
        }
        else
        {
            alert = UIAlertController(title: inpTitle,
                                         message: inpMessage,
                                         preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(okAction);
        }
        
        
        inpVc.present(alert,
                     animated: true,
                     completion: nil)
    }

}
