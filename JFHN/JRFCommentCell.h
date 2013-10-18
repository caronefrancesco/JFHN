//
//  JRFCommentCell.h
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JRFComment;

@interface JRFCommentCell : UITableViewCell
- (void) configureWithComment:(JRFComment *)comment;
@end
