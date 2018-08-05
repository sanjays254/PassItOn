//
//  Tag.swift
//  ItsFree
//
//  Created by Nicholas Fung on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import Foundation


class Tag {
    var tagsArray:[String] = [""]

    func add(tag:String) {
        if tagsArray.first == "" {
            tagsArray.remove(at: 0)
        }
        tagsArray.append(tag)
    }
}
