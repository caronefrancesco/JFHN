//
//  JRFHNBrowserController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"
#import <OvershareKit/OvershareKit.h>

@class JRFEntry;

@interface JRFHNBrowserController : JRFBrowserController<OSKPresentationStyle, UINavigationControllerDelegate>
@property(nonatomic) JRFEntry *story;
@property(nonatomic, readonly)BOOL commentsShown;
- (void) showCommentsAnimated:(BOOL)animated;
- (void) hideCommentsAnimated:(BOOL)animated;

@end
