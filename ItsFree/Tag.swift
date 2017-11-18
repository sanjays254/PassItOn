//
//  Tag.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation


class Tag {
    var tagsDict:[String:String] = [:]
    
    func add(tag:String) {
        tagsDict[String(tagsDict.count)] = tag
    }
}
