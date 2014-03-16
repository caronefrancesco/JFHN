//
//  JRFCommentCell.h
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JRFComment;

@protocol JRFCommentCellDelegate
- (void)commentCellDidSelectURL:(NSURL *)url;
@end

@interface JRFCommentCell : UITableViewCell
@property(weak, nonatomic) id<JRFCommentCellDelegate> delegate;
- (void) configureWithComment:(JRFComment *)comment;
@end
