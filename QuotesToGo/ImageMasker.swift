//
//  ImageMasker.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 19/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit

class ImageMasker: NSObject {
    class func maskImage(imageView:UIImageView, size:CGSize!) {
        let mask = CALayer()

        var maskImage = UIImage(named: "mask")

        if size.width > 54 {
            maskImage = UIImage(named: "bigMask")
        }

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), false, 0)
        maskImage?.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        mask.contents = newImage?.CGImage
        mask.frame = CGRectMake(0, 0, size.width, size.height)

        imageView.contentMode = .ScaleAspectFill
        imageView.layer.mask = mask
        
    }
}
