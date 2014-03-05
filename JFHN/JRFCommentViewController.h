//
//  JRFCommentViewController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/15/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JRFEntry;

@interface JRFCommentViewController : UITableViewController
@property(nonatomic) id<UIScrollViewDelegate> scrollViewDelegate;
@property(nonatomic) JRFEntry *story;
@end
