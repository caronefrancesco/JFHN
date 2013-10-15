//
//  JRFStory.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFStory.h"
#import <TMDiskCache.h>

@implementation JRFStory
- (BOOL) isRead {
    return [[TMDiskCache sharedCache] objectForKey:self.storyId] != nil;
}
- (void) setRead:(BOOL)read {
    if (read) {
        [[TMDiskCache sharedCache] setObject:@(YES) forKey:self.storyId];
    }
    else {
        [[TMDiskCache sharedCache] removeObjectForKey:self.storyId];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.storyId = [aDecoder decodeObjectForKey:@"storyId"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.authorName = [aDecoder decodeObjectForKey:@"authorName"];
        self.submittedAt = [aDecoder decodeObjectForKey:@"submittedAt"];
        self.commentCount = [aDecoder decodeIntegerForKey:@"commentCount"];
        self.domain = [aDecoder decodeObjectForKey:@"domain"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.storyId forKey:@"storyId"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.authorName forKey:@"authorName"];
    [aCoder encodeObject:self.submittedAt forKey:@"submittedAt"];
    [aCoder encodeInteger:self.commentCount forKey:@"commentCount"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
}


@end
