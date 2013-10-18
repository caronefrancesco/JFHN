//
//  JRFEntryDetailSerializer.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFEntryDetailSerializer.h"
#import "JRFStory.h"
#import "JRFComment.h"

@implementation JRFEntryDetailSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super responseObjectForResponse:response data:data error:error];
    JRFStory *story = [JRFStory new];
    story.storyId = [json nilSafeForKey:@"id"];
    story.text = [json nilSafeForKey:@"text"];
    NSMutableArray *comments = [NSMutableArray array];
    NSArray *commentData = [json nilSafeForKey:@"comments"];
    for (NSDictionary *commentJson in commentData) {
        [comments addObject:[self commentWithData:commentJson parent:nil]];
    }
    story.comments = comments;
    return story;
}

- (JRFComment *) commentWithData:(NSDictionary *)data parent:(JRFComment *)parent {
    JRFComment *comment = [JRFComment new];
    comment.commentId = [data nilSafeForKey:@"id"];
    comment.text = [data nilSafeForKey:@"text"];
    comment.text = [comment.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    comment.authorName = [data nilSafeForKey:@"submitter"];
    comment.parent = parent;
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *json in [data nilSafeForKey:@"children"]) {
        [array addObject:[self commentWithData:json parent:comment]];
    }
    comment.comments = array;
    return comment;
}

@end
