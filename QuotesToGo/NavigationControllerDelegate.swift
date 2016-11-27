//
//  NavigationControllerDelegate.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 13/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.restorationIdentifier == "Welcome" {
            return StartTransitionAnimator()
        } else {
            return nil
        }
    }
}
