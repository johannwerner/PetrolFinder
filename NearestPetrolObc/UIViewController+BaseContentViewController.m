//
//  UIViewController+BaseContentViewController.m
//  Spar
//
//  Created by Johann Werner on 2014/08/01.
//  Copyright (c) 2014 Johann. All rights reserved.
//

#import "UIViewController+BaseContentViewController.h"
#import <objc/runtime.h>

static char* overlayViewTag = "overlayViewTag";
static char* currentlyActiveTextViewTag = "currentlyActiveTextViewTag";

@implementation UIViewController (BaseContentViewController)

- (void)addTapGestureToCloseKeyboardView:(UISearchBar*)textField {
    UITextField *oldTextField = objc_getAssociatedObject(self, currentlyActiveTextViewTag);
    if (oldTextField) {
        [self dismissKeyboardAndRemoveOverlay];
    }
    objc_setAssociatedObject(self, currentlyActiveTextViewTag, textField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIView *view = self.overlayView;
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    [textField.superview bringSubviewToFront:textField];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardAndRemoveOverlay)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    [view addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboardAndRemoveOverlay {
    UITextField *textField = objc_getAssociatedObject(self, currentlyActiveTextViewTag);
    if (textField) {
        [self.overlayView removeFromSuperview];
        [textField resignFirstResponder];
        objc_setAssociatedObject(self, currentlyActiveTextViewTag, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UIView*)overlayView {
    UIView *overlayView = objc_getAssociatedObject(self, overlayViewTag);
    if (overlayView == nil) {
        overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//#ifdef DEBUG
//        overlayView.backgroundColor = [UIColor blueColor];
//#endif
        objc_setAssociatedObject(self, overlayViewTag, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return overlayView;
}

@end
