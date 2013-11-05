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
@property (weak, nonatomic) IBOutlet UILabel *commentNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@end

@implementation JRFStoryCell

- (void) awakeFromNib {
    [super awakeFromNib];
    UIImage *renderedContentImage = [[self.commentButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *renderedHighlightImage = [[self.commentButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentButton setImage:renderedContentImage forState:UIControlStateNormal];
    [self.commentButton setImage:renderedHighlightImage forState:UIControlStateHighlighted];
    self.commentButton.tintColor = [UIColor appTintColor];
    self.commentNumberLabel.textColor = [UIColor appTintColor];
    self.unreadLabel.textColor = [UIColor appTintColor];
}

- (CGFloat) heightForStory:(JRFStory *) story {
    CGSize maxTitleSize = CGSizeMake(self.storyTitleLabel.frame.size.width, CGFLOAT_MAX);
    CGFloat titleY = CGRectGetMinY(self.storyTitleLabel.frame);
    CGFloat titleHeight = [story.title boundingRectWithSize:maxTitleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.storyTitleLabel.font} context:nil].size.height;
    CGFloat domainPadding = 0, domainHeight = 0, bottomPadding = 5;
    if (story.type == JRFStoryTypeNormal || story.type == JRFStoryTypeHNPost) {
        domainPadding = (CGRectGetMinY(self.storyDomainLabel.frame) - CGRectGetMaxY(self.storyTitleLabel.frame));
        domainHeight = CGRectGetHeight(self.storyDomainLabel.frame);
    }
    CGFloat height = titleY + titleHeight + domainPadding + domainHeight + bottomPadding;
    return height;
}

- (void) configureWithStory:(JRFStory *)story {
    self.storyTitleLabel.text = story.title;
    self.unreadLabel.hidden = story.isRead;
    self.commentButton.hidden = NO;
    self.commentNumberLabel.hidden = NO;
    if (story.type == JRFStoryTypeNormal) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@ · %@", (long)story.score, story.authorName, story.domain];
        self.commentNumberLabel.text = [NSString stringWithFormat:@"%li", (long)story.commentCount];
    }
    else if (story.type == JRFStoryTypeHNPost) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@", (long)story.score, story.authorName];
        self.commentNumberLabel.text = [NSString stringWithFormat:@"%li", (long)story.commentCount];
    }
    else {
        self.commentButton.hidden = YES;
        self.commentNumberLabel.hidden = YES;
    }
}

- (void) prepareForReuse {
    self.storyTitleLabel.text = nil;
    self.storyDomainLabel.text = nil;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat imageHeight = self.commentButton.imageView.image.size.height;
    CGRect numberFrame = self.commentNumberLabel.frame;
    numberFrame.origin.y = height/2 + 3;
    UIEdgeInsets insets = self.commentButton.imageEdgeInsets;
    insets.top = height/2 - imageHeight + 6;
    insets.bottom = height - insets.top - imageHeight;
    self.commentButton.imageEdgeInsets = insets;
    self.commentNumberLabel.frame = numberFrame;
}

- (IBAction)selectComments:(id)sender {
    [self.delegate storyCellDidSelectComments:self];
}

@end
