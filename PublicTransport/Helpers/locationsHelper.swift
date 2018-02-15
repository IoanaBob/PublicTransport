//
//  locationsHelper.swift
//  PublicTransport
//
//  Created by Ioana Surdu-Bob on 15/02/2018.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

struct LocationsHelper {
    func loadObjectArray(forKey key:String) -> [Location] {
        if let objects = UserDefaults.standard.value(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [Location] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
}
