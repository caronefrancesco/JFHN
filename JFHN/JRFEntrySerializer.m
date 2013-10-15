//
//  JRFEntrySerializer.m
//  JFHN
//
//  Created by Jack Flintermann on 10/12/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFEntrySerializer.h"
#import "JRFStory.h"
#import "JRFStoryStore.h"

@interface NSDictionary(NilSafe)
- (id) nilSafeForKey:(id)key;
@end

@implementation NSDictionary(NilSafe)
- (id) nilSafeForKey:(id)key {
    id val = [self objectForKey:key];
    if (val == [NSNull null]) {
        return nil;
    }
    return val;
}

@end

@implementation JRFEntrySerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    NSArray *json = [super responseObjectForResponse:response data:data error:error];
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:json.count];
    for (NSDictionary *dict in json) {
        JRFStory *story = [JRFStory new];
        story.storyId = [dict nilSafeForKey:@"id"];
        story.title = [dict nilSafeForKey:@"title"];
        story.url = [NSURL URLWithString:[dict nilSafeForKey:@"url"]];
        story.domain = [dict nilSafeForKey:@"domain"];
        story.authorName = [dict nilSafeForKey:@"author_name"];
        story.commentCount = [[dict nilSafeForKey:@"comment_count"] integerValue];
        [entries addObject:story];
    }
    return entries;
}

@end
