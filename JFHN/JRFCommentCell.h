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
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
- (CGFloat) heightForComment:(JRFComment *)comment indentationLevel:(NSInteger)indentationLevel;
@end
