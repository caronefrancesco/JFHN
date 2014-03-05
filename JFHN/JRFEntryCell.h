//
//  JRFEntryCell.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MCSwipeTableViewCell/MCSwipeTableViewCell.h>

@class JRFEntry;
@class JRFEntryCell;

@protocol JRFEntryCellDelegate <MCSwipeTableViewCellDelegate>
- (void)entryCellDidSelectComments:(JRFEntryCell *)cell;
- (void)entryCellDidPerformHideGesture:(JRFEntryCell *)cell;
@end

@interface JRFEntryCell : MCSwipeTableViewCell

- (CGFloat)heightForEntry:(JRFEntry *)entry;
- (void)configureWithEntry:(JRFEntry *)entry;
@property(weak, nonatomic) id<JRFEntryCellDelegate> delegate;

@end
