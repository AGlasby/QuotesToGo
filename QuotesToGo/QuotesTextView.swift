//
//  QuotesTextView.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 13/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit

class QuotesTextView: UITextView {



    var heightConstraint:NSLayoutConstraint?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        let size = self.sizeThatFits(CGSizeMake(self.bounds.width, CGFloat(FLT_MAX)))
        if self.heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: CGFloat(1), constant: size.height)
            self.addConstraint(heightConstraint!)
        }

        heightConstraint!.constant = size.height

        super.updateConstraints()
    }


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
