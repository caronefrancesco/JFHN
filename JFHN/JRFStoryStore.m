//
//  JRFStoryStore.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStoryStore.h"
#import "JRFStory.h"
#import "JRFEntrySerializer.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <TMCache/TMDiskCache.h>

static NSString *lastFetchKey = @"last.fetch.date";

static JRFStoryStore *sharedInstance;

@interface JRFStoryStore()
@property(nonatomic, readwrite, strong) NSArray *stories;
@end
@implementation JRFStoryStore

- (id) init {
    self = [super init];
    if (self) {
        _stories = (NSArray *)[[TMDiskCache sharedCache] objectForKey:@"stories"];
    }
    return self;
}

+ (JRFStoryStore *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JRFStoryStore alloc] init];
    });
    return sharedInstance;
}

- (NSArray *) allStories {
    return self.stories;
}

- (void) fetchStoriesWithCompletion:(void (^)(NSArray *, NSError *))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [JRFEntrySerializer serializer];
    [manager GET:@"http://hnapi.jackflintermann.com/entries" parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *stories) {
        self.stories = stories;
        [[TMDiskCache sharedCache] setObject:stories forKey:@"stories"];
        if (completion) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastFetchKey];
            completion(stories, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (NSDate *)lastFetchDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:lastFetchKey];
}

@end
