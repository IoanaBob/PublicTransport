//
//  extensions.swift
//  PublicTransport
//
//  Created by Ioana on 2/12/18.
//  Copyright © 2018 Ioana Surdu-Bob. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element
    
    func safeIndex(after index: Index) -> Index? {
        let nextIndex = self.index(after: index)
        return (nextIndex < self.endIndex) ? nextIndex : nil
    }
    
    func index(afterWithWrapAround index: Index) -> Index {
        return self.safeIndex(after: index) ?? self.startIndex
    }
    
    func item(after item: Element) -> Element? {
        return self.index(of: item)
            .flatMap(self.safeIndex(after:))
            .map{ self[$0] }
    }
    
    func item(afterWithWrapAround item: Element) -> Element? {
        return self.index(of: item)
            .map(self.index(afterWithWrapAround:))
            .map{ self[$0] }
    }
}
