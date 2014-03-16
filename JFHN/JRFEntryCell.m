//
//  JRFEntryCell.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFEntryCell.h"
#import "JRFEntry.h"
#import "UIFont+HN.h"

@interface JRFEntryCell ()
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyDomainLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *storyInterestingLabel;
@end

@implementation JRFEntryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *renderedContentImage = [[self.commentButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *renderedHighlightImage = [[self.commentButton imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentButton setImage:renderedContentImage forState:UIControlStateNormal];
    [self.commentButton setImage:renderedHighlightImage forState:UIControlStateHighlighted];
    self.commentButton.tintColor = [UIColor appTintColor];
    self.unreadView.backgroundColor = [UIColor appTintColor];
}

- (CGFloat)heightForEntry:(JRFEntry *)entry {
    [self layoutSubviews];
    CGSize maxTitleSize = CGSizeMake(self.storyTitleLabel.frame.size.width, CGFLOAT_MAX);
    CGFloat titleY = CGRectGetMinY(self.storyTitleLabel.frame);
    CGFloat titleHeight = [entry.title boundingRectWithSize:maxTitleSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.storyTitleLabel.font} context:nil].size.height;
    CGFloat domainPadding = 0, domainHeight = 0, bottomPadding = 5;
    if (entry.type == JRFEntryTypeNormal || entry.type == JRFEntryTypeHNPost) {
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

- (void)configureWithEntry:(JRFEntry *)entry {
    NSString *text = [NSString stringWithFormat:@"%li", (long) entry.commentCount];
    NSMutableDictionary *attributes = [self commentButtonAttributes];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.commentButton setAttributedTitle:attributedText forState:UIControlStateNormal];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.commentButton setAttributedTitle:attributedText forState:UIControlStateHighlighted];
    self.storyTitleLabel.text = entry.title;
    self.unreadView.hidden = (entry.readAt != nil);
    self.commentButton.hidden = NO;
    if (entry.type == JRFEntryTypeNormal) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@ · %@", (long) entry.score, entry.authorName, entry.domain];

    }
    else if (entry.type == JRFEntryTypeHNPost) {
        self.storyDomainLabel.text = [NSString stringWithFormat:@"%li pts · %@", (long) entry.score, entry.authorName];
    }
    else {
        self.commentButton.hidden = YES;
    }
    self.storyInterestingLabel.text = [[self numberFormatter] stringFromNumber:@(entry.interestingProbability)];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.font = [UIFont primaryAppFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"Not\nInterested";
    CGSize size = [label intrinsicContentSize];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, size.width, size.height);
    __weak JRFEntryCell *weakself = self;
    [self setSwipeGestureWithView:label color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [weakself.delegate entryCellDidPerformHideGesture:weakself];
    }];
}

- (void) prepareForReuse {
    [super prepareForReuse];
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
    
    CGRect storyLabelFrame = self.storyTitleLabel.frame;
    storyLabelFrame.size.width = CGRectGetMinX(self.commentButton.frame) - CGRectGetMinX(self.storyTitleLabel.frame) - 5;
    self.storyTitleLabel.frame = storyLabelFrame;
    
    CGRect textRect = [@"123" boundingRectWithSize:CGSizeMake(imageWidth, imageHeight)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:[self commentButtonAttributes]
                                           context:nil];
    CGFloat textHeight = textRect.size.height;
    CGFloat topPadding = (titleHeight - imageHeight) / 2 + 5;
    CGFloat rightPadding = 10;
    CGFloat titlePadding = 5;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    
    imageEdgeInsets.right = rightPadding;
    imageEdgeInsets.left = buttonWidth - imageWidth - imageEdgeInsets.right;
    imageEdgeInsets.top = topPadding;
    imageEdgeInsets.bottom = buttonHeight - imageHeight - imageEdgeInsets.top;
    
    titleEdgeInsets.left = imageEdgeInsets.left - buttonWidth + titlePadding;
    titleEdgeInsets.top = topPadding + titlePadding - 1;
    titleEdgeInsets.bottom = buttonHeight - textHeight - titleEdgeInsets.top;
    
    self.commentButton.imageEdgeInsets = imageEdgeInsets;
    self.commentButton.titleEdgeInsets = titleEdgeInsets;

}

- (IBAction)selectComments:(id)sender {
    [self.delegate entryCellDidSelectComments:self];
}

- (NSNumberFormatter *) numberFormatter {
    static NSNumberFormatter *numberFormatter;
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumSignificantDigits:2];
    }
    return numberFormatter;
}

@end
