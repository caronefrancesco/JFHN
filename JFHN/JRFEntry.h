//
//  JRFEntry.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
@class JRFComment;

typedef NS_ENUM(NSInteger, JRFEntryType) {
    JRFEntryTypeNormal,
    JRFEntryTypeHiring,
    JRFEntryTypeHNPost,
};

@interface JRFEntry : MTLModel <MTLManagedObjectSerializing>

@property(nonatomic) NSString *storyId;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *urlString;
@property(nonatomic) JRFEntryType type;
@property(nonatomic) NSString *authorName;
@property(nonatomic) NSDate *submittedAt;
@property(nonatomic) NSInteger commentCount;
@property(nonatomic) NSInteger score;
@property(nonatomic) NSArray *comments;
@property(nonatomic) NSString *domain;
@property(nonatomic) NSDate *readAt;
@property(nonatomic) NSDate *markedAsUninterestingAt;
@property(nonatomic) NSInteger frontpagePosition;
@property(nonatomic) CGFloat interestingProbability;
@property(nonatomic) CGFloat uninterestingProbability;

- (NSURL *) url;
- (JRFComment *)commentAtIndex:(NSInteger)index;

@end
