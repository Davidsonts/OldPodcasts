//
//  Describable.swift
//  Podcasts
//
//  Created by Eugene Karambirov on 22/02/2019.
//  Copyright © 2019 Eugene Karambirov. All rights reserved.
//

import Foundation

protocol Describable {

    var typeName: String { get }
    static var typeName: String { get }
}

extension Describable {

    var typeName: String {
        String(describing: self)
    }

    static var typeName: String {
        String(describing: self)
    }
}

extension Describable where Self: NSObjectProtocol {

    var typeName: String {
        String(describing: type(of: self))
    }
}
