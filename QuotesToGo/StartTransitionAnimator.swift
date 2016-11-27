//
//  StartTransitionAnimator.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 13/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit
import QuartzCore

class StartTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {

    weak var transitionContext: UIViewControllerContextTransitioning?

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()

        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! AllQuotesViewController
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! WelcomeViewController

        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        let fromRibbon = fromViewController.ribbon
        let toRibbon = toViewController.ribbon
        toRibbon.transform = CGAffineTransformMakeTranslation(0, -60)
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            fromRibbon.transform = CGAffineTransformMakeTranslation(0, -300)
            UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                toViewController.view.alpha = 1
                }, completion: {(sucess) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        toRibbon.transform = CGAffineTransformIdentity
                        }, completion: { (sucess) -> Void in
                    transitionContext.completeTransition(true)
                    })
                })
            }, completion: nil)
    }

    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        transitionContext?.completeTransition(!transitionContext!.transitionWasCancelled())
    }
}
