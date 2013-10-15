//
//  JRFStoryStore.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JRFStory;
@interface JRFStoryStore : NSObject
+ (JRFStoryStore *) sharedInstance;
- (NSArray *) allStories;
- (void)fetchStoriesWithCompletion:(void (^)(NSArray *stories, NSError *error))completion;
- (NSDate *)lastFetchDate;
@end
