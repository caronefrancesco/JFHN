//
//  JRFStory.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JRFComment;

typedef NS_ENUM(NSInteger, JRFStoryType) {
    JRFStoryTypeNormal,
    JRFStoryTypeHiring,
    JRFStoryTypeHNPost,
};

@interface JRFStory : NSObject<NSCoding>
@property(nonatomic) NSString *storyId;
@property(nonatomic) NSString *title;
@property(nonatomic) NSURL *url;
@property(nonatomic) JRFStoryType type;
@property(nonatomic) NSString *authorName;
@property(nonatomic) NSDate *submittedAt;
@property(nonatomic) NSInteger commentCount;
@property(nonatomic) NSInteger score;
@property(nonatomic) NSArray *comments;
@property(nonatomic) NSString *domain;
@property(nonatomic) NSString *text; // for jobs/polls/etc
@property(nonatomic, getter = isRead) BOOL read;
- (JRFComment *)commentAtIndex:(NSInteger)index;
@end
