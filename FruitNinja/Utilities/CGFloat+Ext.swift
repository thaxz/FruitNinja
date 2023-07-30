//
//  CGFloat+Ext.swift
//  FruitNinja
//
//  Created by thaxz on 29/07/23.
//

import CoreGraphics

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat((Float(arc4random())) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
     assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
    
}
