//
//  JRFStoryCell.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStoryCell.h"
#import "JRFStory.h"
#import "UIFont+HN.h"

@interface JRFStoryCell()
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyDomainLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
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
    self.unreadView.backgroundColor = [UIColor appTintColor];
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

- (NSMutableDictionary *) commentButtonAttributes {
    return [@{
             NSFontAttributeName: [UIFont tertiaryAppFont],
             NSForegroundColorAttributeName: [UIColor appTintColor],
             } mutableCopy];
}

- (void) configureWithStory:(JRFStory *)story {
    NSString *text = [NSString stringWithFormat:@"%li", (long)story.commentCount];
    NSMutableDictionary *attributes = [self commentButtonAttributes];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.commentButton setAttributedTitle:attributedText forState:UIControlStateNormal];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.commentButton setAttributedTitle:attributedText forState:UIControlStateHighlighted];
    self.storyTitleLabel.text = story.title;
    self.unreadView.hidden = story.isRead;
    self.commentButton.hidden = NO;
    if (story.type == JRFStoryTypeNormal) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@ · %@", (long)story.score, story.authorName, story.domain];

    }
    else if (story.type == JRFStoryTypeHNPost) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@", (long)story.score, story.authorName];
    }
    else {
        self.commentButton.hidden = YES;
    }
}

- (void) prepareForReuse {
    self.storyTitleLabel.text = nil;
    self.storyDomainLabel.text = nil;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonWidth = self.commentButton.frame.size.width;
    CGFloat buttonHeight = self.commentButton.frame.size.height;
    CGFloat imageWidth = self.commentButton.imageView.image.size.width;
    CGFloat imageHeight = self.commentButton.imageView.image.size.height;
    CGFloat titleHeight = CGRectGetMaxY(self.storyTitleLabel.frame);
    CGRect textRect = [@"123" boundingRectWithSize:CGSizeMake(imageWidth, imageHeight)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:[self commentButtonAttributes]
                                           context:nil];
    CGFloat textHeight = textRect.size.height;
    CGFloat topPadding = (titleHeight - imageHeight) / 2 + 5;
    CGFloat rightPadding = 10;
    CGFloat titlePadding = 4;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    
    imageEdgeInsets.right = rightPadding;
    imageEdgeInsets.left = buttonWidth - imageWidth - imageEdgeInsets.right;
    imageEdgeInsets.top = topPadding;
    imageEdgeInsets.bottom = buttonHeight - imageHeight - imageEdgeInsets.top;
    
    titleEdgeInsets.left = imageEdgeInsets.left - buttonWidth + titlePadding;
    titleEdgeInsets.top = topPadding + titlePadding;
    titleEdgeInsets.bottom = buttonHeight - textHeight - titleEdgeInsets.top;
    
    self.commentButton.imageEdgeInsets = imageEdgeInsets;
    self.commentButton.titleEdgeInsets = titleEdgeInsets;

}

- (IBAction)selectComments:(id)sender {
    [self.delegate storyCellDidSelectComments:self];
}

@end
