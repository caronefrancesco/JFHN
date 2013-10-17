//
//  JRFCommentCell.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFCommentCell.h"
#import "JRFComment.h"

#define rightPadding 10

@implementation JRFCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    return self;
}

- (void) configure {
    UILabel *authorLabel = [[UILabel alloc] init];
    _authorLabel = authorLabel;
    _authorLabel.font = [UIFont primaryAppFont];
    _authorLabel.numberOfLines = 0;
    [self addSubview:_authorLabel];
    UILabel *commentLabel = [[UILabel alloc] init];
    _commentLabel = commentLabel;
    _commentLabel.font = [UIFont secondaryAppFont];
    _commentLabel.numberOfLines = 0;
    _commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_commentLabel];
}

- (CGFloat) xForLabels {
    return (self.indentationLevel + 1) * 10;
}

- (CGFloat) widthForLabels {
    return self.frame.size.width - [self xForLabels] - rightPadding;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect authorFrame = self.authorLabel.frame;
    authorFrame.origin.x = [self xForLabels];
    authorFrame.origin.y = 5;
    authorFrame.size.width = [self widthForLabels];
    authorFrame.size.height = 20;
    CGRect commentFrame = self.commentLabel.frame;
    commentFrame.origin.x = [self xForLabels];
    commentFrame.origin.y = 30;
    commentFrame.size.width = [self widthForLabels];
    commentFrame.size.height = self.frame.size.height - 30 - 5;
    self.authorLabel.frame = authorFrame;
    self.commentLabel.frame = commentFrame;
}

- (CGFloat)heightForComment:(JRFComment *)comment indentationLevel:(NSInteger)indentationLevel {
    CGFloat commentY = 30;
    CGSize boundingSize = CGSizeMake([self widthForLabels], CGFLOAT_MAX);
    CGRect rect = [comment.text boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.authorLabel.font} context:nil];
    return commentY + rect.size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
