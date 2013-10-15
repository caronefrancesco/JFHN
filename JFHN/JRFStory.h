//
//  JRFStory.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JRFStoryType) {
    JRFStoryTypeNormal,
    JRFStoryTypePoll,
    JRFStoryTypeAsk
};

@interface JRFStory : NSObject<NSCoding>
@property(strong, readwrite) NSString *storyId;
@property(strong, readwrite) NSString *title;
@property(strong, readwrite) NSURL *url;
@property(readwrite) JRFStoryType type;
@property(strong, readwrite) NSString *authorName;
@property(strong, readwrite) NSDate *submittedAt;
@property(readwrite) NSInteger commentCount;
@property(readwrite) NSString *domain;
@property(readwrite, getter = isRead) BOOL read;
@end
