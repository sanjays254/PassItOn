//
//  UIProperties.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2018-01-17.
//  Copyright © 2018 Sanjay Shah. All rights reserved.
//

import UIKit

class UIProperties: NSObject {
    
    static let sharedUIProperties = UIProperties()
    
    
    public var blackColour = UIColor.black
    public var whiteColour = UIColor.white
    public var lightGreenColour = UIColor(red: (153.0/255.0), green: 1, blue: (51.0/255.0), alpha: 1)
    public var purpleColour = UIColor(red: (51.0/255.0), green: (0/255.0), blue: (128.0/255.0), alpha: 1)
    

}
