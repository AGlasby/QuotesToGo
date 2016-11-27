//
//  AuthorManager.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 13/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit

class AuthorManager: NSObject {

    class func addAuthor (name:String, completion:(author:Author)->()) {
        let moc = CoreDataHelper.managedObjectContext()
        let predicate = NSPredicate(format: "name = %@", name)
        let authorFound = CoreDataHelper.fetchEntities(NSStringFromClass(Author), managedObjectContext: moc, predicate: predicate, sortDescriptor: nil)
        if authorFound.count > 0 {
            let author = authorFound.firstObject as! Author
            completion(author: author)
        } else {
            let author = CoreDataHelper.inserManagedObject(NSStringFromClass(Author), managedObjectContext: moc) as! Author
            author.name = name

            do {
                try WikiFace.faceForPerson(name, size: CGSizeMake(118, 118), completion: {(image:UIImage?, imageFound:Bool!) -> () in
                    if imageFound == true {
                        let faceImageView = UIImageView(image: image)
                        faceImageView.contentMode = UIViewContentMode.ScaleAspectFill
                        WikiFace.centerImageViewOnFace(faceImageView)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            UIGraphicsBeginImageContextWithOptions(faceImageView.bounds.size, true, 0)
                            let context = UIGraphicsGetCurrentContext()
                            faceImageView.layer.renderInContext(context!)
                            let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            let imageData = UIImageJPEGRepresentation(croppedImage!, 0.5)
                            author.image = imageData
                            try! moc.save()
                            completion(author: author)
                        })
                    } else {
                        author.image = nil
                        try! moc.save()
                        completion(author: author)
                    }

            })
            } catch WikiFace.WikiFaceError.CouldNotDownloadImage {
                print("Could not download image for author. Using default image.")
                author.image = nil
                try! moc.save()
                completion(author: author)
            } catch {
                print(error)
            }
        }
    }

}
