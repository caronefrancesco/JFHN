//
//  JRFBrowserController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/13/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRFBrowserController : UIViewController<UINavigationControllerDelegate, UIWebViewDelegate, UIScrollViewDelegate>
- (id) initWithUrl:(NSURL *)url;
@property(nonatomic, readwrite, weak) UIToolbar *toolbar;
@end
