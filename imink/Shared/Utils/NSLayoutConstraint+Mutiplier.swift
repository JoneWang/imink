//
//  NSLayoutConstraint+Mutiplier.swift
//  imink
//
//  Created by Jone Wang on 2020/10/2.
//
//  From: https://stackoverflow.com/questions/19593641/can-i-change-multiplier-property-for-nslayoutconstraint

import UIKit

extension NSLayoutConstraint {
    
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
    
}
