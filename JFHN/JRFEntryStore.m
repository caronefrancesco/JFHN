   //
//  JRFEntryStore.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFEntryStore.h"
#import "JRFEntry.h"
#import "JRFEntrySerializer.h"
#import "JRFCommentSerializer.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <MagicalRecord/NSManagedObjectContext+MagicalRecord.h>
#import "JRFFeatureExtractor.h"
#import <BayesianKit/BayesianKit.h>

NSString * const JRFStoryStoreDidRefreshNotification = @"JRFStoryStoreDidRefreshNotification";

static NSString *lastFetchKey = @"last.fetch.date";

static JRFEntryStore *sharedInstance;

@implementation JRFEntryStore

- (id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (JRFEntryStore *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JRFEntryStore alloc] init];
    });
    return sharedInstance;
}

- (void) fetchStoriesWithCompletion:(void (^)(NSArray *, NSError *))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [JRFEntrySerializer serializer];
    NSString *path = @"http://news.ycombinator.com/";
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *entries) {

        BKClassifier *classifier = [self updateRatingWeights];
        
        // first, mark all existing records as not on the frontpage
        NSArray *frontpageRecords = [[NSManagedObjectContext MR_rootSavingContext] executeFetchRequest:[self frontpageStoryFetchRequest] error:nil];
        for (NSManagedObject *object in frontpageRecords) {
            [object setValue:@(-1) forKey:@"frontpagePosition"];
        }
        
        // next, go through the returned stories and update their frontpage position
        NSInteger i = 0;
        for (JRFEntry *entry in entries) {
            JRFFeatureExtractor *extractor = [[JRFFeatureExtractor alloc] initWithEntry:entry];
            NSArray *features = [[extractor features] allObjects];
            NSDictionary *results = [classifier guessWithTokens:features];
            entry.interestingProbability = [[results objectForKey:@"interesting"] floatValue];
            entry.uninterestingProbability = [[results objectForKey:@"uninteresting"] floatValue];
            
            entry.frontpagePosition = i;
            
            NSError *mtlError;
            NSManagedObject *object = [MTLManagedObjectAdapter managedObjectFromModel:entry insertingIntoContext:[NSManagedObjectContext MR_rootSavingContext] error:&mtlError];
            
            i++;
            if (mtlError) {
                
            }
        }
        NSError *saveError;
        [[NSManagedObjectContext MR_rootSavingContext] save:&saveError];
        if (saveError) {
            
        }
        if (completion) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastFetchKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:JRFStoryStoreDidRefreshNotification object:entries];
            completion(entries, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void) fetchCommentsForStory:(JRFEntry *)story withCompletion:(void (^)(NSArray *comments, NSError *error))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [JRFCommentSerializer serializer];
    NSString *path = @"https://news.ycombinator.com/item";
    [manager GET:path parameters:@{@"id": story.storyId} success:^(AFHTTPRequestOperation *operation, NSArray *comments) {
        if (completion) {
            completion(comments, nil);
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

- (NSFetchRequest *) frontpageStoryFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[JRFEntry managedObjectEntityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"frontpagePosition" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"frontpagePosition != %@ && markedAsUninterestingAt == %@", @(-1), nil];
    return fetchRequest;
}

- (NSArray *) readStories {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[JRFEntry managedObjectEntityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"readAt != %@ && markedAsUninterestingAt == %@", nil, nil];
    return [[NSManagedObjectContext MR_rootSavingContext] executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *) uninterestingStories {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[JRFEntry managedObjectEntityName]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"markedAsUninterestingAt != %@", nil];
    return [[NSManagedObjectContext MR_rootSavingContext] executeFetchRequest:fetchRequest error:nil];
}

- (void) markEntryAsRead:(JRFEntry *)entry {
    entry.readAt = [NSDate date];
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_rootSavingContext];
    [MTLManagedObjectAdapter managedObjectFromModel:entry insertingIntoContext:ctx error:nil];
    [ctx save:nil];
}

- (void) markEntryAsUninteresting:(JRFEntry *)entry {
    entry.markedAsUninterestingAt = [NSDate date];
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_rootSavingContext];
    [MTLManagedObjectAdapter managedObjectFromModel:entry insertingIntoContext:ctx error:nil];
    [ctx save:nil];
}

- (BKClassifier *) updateRatingWeights {
    BKClassifier *classifier = [BKClassifier classifierWithContentsOfFile:@"classifier.bks"];
    BKDataPool *uninteresting = [classifier poolNamed:@"uninteresting"];
    BKDataPool *interesting = [classifier poolNamed:@"interesting"];
    
    for (JRFEntry *entry in [self uninterestingStories]) {
        JRFFeatureExtractor *extractor = [[JRFFeatureExtractor alloc] initWithEntry:entry];
        NSArray *features = [[extractor features] allObjects];
        [classifier trainWithTokens:features inPool:uninteresting];
    }
    
    for (JRFEntry *entry in [self readStories]) {
        JRFFeatureExtractor *extractor = [[JRFFeatureExtractor alloc] initWithEntry:entry];
        NSArray *features = [[extractor features] allObjects];
        [classifier trainWithTokens:features inPool:interesting];
    }
    
    return classifier;
}

@end
