//
//  JRFHNBrowserController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFBrowserController.h"

@interface JRFHNBrowserController : JRFBrowserController
@property(nonatomic, readonly)BOOL commentsShown;
- (void) showCommentsAnimated:(BOOL)animated;
- (void) hideCommentsAnimated:(BOOL)animated;

@end
