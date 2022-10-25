//
//  NXFileOperationAnimation.m
//  nxrmc
//
//  Created by nextlabs on 12/9/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXFileOperationAnimation.h"

#define kAnimationDuration 0.3

@implementation NXFileOperationAnimation

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CATransform3D fd = CATransform3DMakeRotation(-0.5 * M_PI, 0, 1, 0);
    fd.m34 = -1.0/500;
    
    if (self.present) {
        [[transitionContext containerView] insertSubview:toViewController.view aboveSubview:fromViewController.view];
        
        toViewController.view.layer.transform = fd;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            toViewController.view.layer.zPosition = 0;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
//        [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
//
        fromViewController.view.layer.zPosition = fromViewController.view.frame.size.width/2;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.layer.transform = fd;
        } completion:^(BOOL finished) {
            fromViewController.view.layer.zPosition = 0;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end
