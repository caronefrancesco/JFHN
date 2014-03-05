//
//  JRFEntryStore.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const JRFStoryStoreDidRefreshNotification;

@class JRFEntry;
@interface JRFEntryStore : NSObject
+ (JRFEntryStore *) sharedInstance;
- (void)fetchStoriesWithCompletion:(void (^)(NSArray *stories, NSError *error))completion;
- (void) fetchCommentsForStory:(JRFEntry *)story withCompletion:(void (^)(NSArray *comments, NSError *error))completion;
- (NSDate *)lastFetchDate;

- (NSFetchRequest *) frontpageStoryFetchRequest;

- (void) markEntryAsRead:(JRFEntry *)entry;
- (void) markEntryAsUninteresting:(JRFEntry *)entry;

@end
