//
//  JRFStoryCell.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStoryCell.h"
#import "JRFStory.h"

@interface JRFStoryCell()
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyDomainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;
@end

@implementation JRFStoryCell

- (void) awakeFromNib {
    [super awakeFromNib];
    UIImage *renderedContentImage = [self.commentImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *renderedHighlightImage = [self.commentImageView.highlightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.commentImageView.tintColor = [UIColor appTintColor];
    self.commentImageView.image = renderedContentImage;
    self.commentImageView.highlightedImage = renderedHighlightImage;
    self.commentNumberLabel.textColor = [UIColor appTintColor];
    self.unreadLabel.textColor = [UIColor appTintColor];
}

- (CGFloat) heightForStory:(JRFStory *) story {
    CGSize maxTitleSize = CGSizeMake(self.storyTitleLabel.frame.size.width, CGFLOAT_MAX);
    CGFloat titleY = CGRectGetMinY(self.storyTitleLabel.frame);
    CGFloat titleHeight = [story.title boundingRectWithSize:maxTitleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.storyTitleLabel.font} context:nil].size.height;
    CGFloat domainPadding = (CGRectGetMinY(self.storyDomainLabel.frame) - CGRectGetMaxY(self.storyTitleLabel.frame));
    CGFloat bottomPadding = (CGRectGetHeight(self.frame) - CGRectGetMinY(self.storyDomainLabel.frame));
    CGFloat height = titleY + titleHeight + domainPadding + bottomPadding + 5;
    return height;
}

- (void) configureWithStory:(JRFStory *)story {
    self.storyTitleLabel.text = story.title;
    self.storyDomainLabel.text = story.domain;
    self.commentNumberLabel.text = [NSString stringWithFormat:@"%li", (long)story.commentCount];
    self.unreadLabel.hidden = story.isRead;
}

- (void) prepareForReuse {
    self.storyDomainLabel.text = nil;
    self.storyDomainLabel.text = nil;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect imageFrame = self.commentImageView.frame;
    CGRect numberFrame = self.commentNumberLabel.frame;
    CGFloat height = self.frame.size.height;
    imageFrame.origin.y = height/2 - imageFrame.size.height + 6;
    numberFrame.origin.y = height/2 + 3;
    self.commentImageView.frame = imageFrame;
    self.commentNumberLabel.frame = numberFrame;
}

- (IBAction)highlightComment:(id)sender {
    [self.commentImageView setHighlighted:YES];
}
- (IBAction)unhighlightComment:(id)sender {
    [self.commentImageView setHighlighted:NO];
}
- (IBAction)selectComments:(id)sender {
    [self.commentImageView setHighlighted:NO];
    [self.delegate storyCellDidSelectComments:self];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.commentImageView.highlighted = NO;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.commentImageView.highlighted = NO;
}

@end
