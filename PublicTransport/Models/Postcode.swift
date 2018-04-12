//
//  Postcode.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 11/04/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

struct Postcode: Codable {
    let status:Int
    let result:PostcodeInfo
}

struct PostcodeInfo: Codable {
    let postcode:String
    let latitude:Float
    let longitude:Float
}
