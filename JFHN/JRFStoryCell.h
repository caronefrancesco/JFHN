//
//  JRFStoryCell.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JRFStory;
@class JRFStoryCell;

@protocol JRFStoryCellDelegate <NSObject>
- (void) storyCellDidSelectComments:(JRFStoryCell *)cell;
@end

@interface JRFStoryCell : UITableViewCell

- (CGFloat) heightForStory:(JRFStory *) story;
- (void) configureWithStory:(JRFStory *) story;
@property(weak, nonatomic) id<JRFStoryCellDelegate> delegate;
@end
