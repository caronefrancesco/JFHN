//
//  JRFBrowserController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRFWebViewDelegate.h"

typedef NS_OPTIONS(NSInteger, JRFToolbarMode) {
    JRFToolbarModeHidden = 0,
    JRFToolbarModeInteractive = 1,
    JRFToolbarModeVisible = 3
};

@interface JRFBrowserController : UIViewController<UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, JRFWebViewDelegate>
- (id) initWithUrl:(NSURL *)url;
@property(nonatomic, readwrite, weak) UIToolbar *toolbar;
@property(nonatomic, weak) UINavigationController *navController;
@property(nonatomic) JRFToolbarMode toolbarMode;
@end
