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
#import <hpple/TFHpple.h>
#import "NSString+HTML.h"

@implementation JRFEntrySerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    
    TFHpple *document = [TFHpple hppleWithHTMLData:data];
    NSArray *baseTables = [document searchWithXPathQuery:@"//table/tr/td/table"];
    TFHppleElement *baseTable = [baseTables objectAtIndex:1];
    NSMutableArray *entries = [NSMutableArray array];
    for (NSInteger i = 0; i < baseTable.children.count - 2; i += 3) {
        JRFStory *story = [JRFStory new];
        story.type = JRFStoryTypeNormal;
        NSArray *rows = [baseTable.children subarrayWithRange:NSMakeRange(i, 3)];
        TFHppleElement *linkChild = rows[0];
        TFHppleElement *link = [[linkChild searchWithXPathQuery:@"//td[@class='title']/a"] firstObject];
        NSString *href = link.attributes[@"href"];
        NSString *title = link.text;
        TFHppleElement *domainElement = [[linkChild searchWithXPathQuery:@"//td[@class='title']/span"] firstObject];
        NSCharacterSet *parensAndWhitespace = [NSCharacterSet characterSetWithCharactersInString:@"( )"];
        NSString *domain = [domainElement.text stringByTrimmingCharactersInSet:parensAndWhitespace];
        if (domain) {
            story.domain = domain;
        }
        else {
            story.type = JRFStoryTypeHNPost;
        }
        story.title = title;
        story.url = [NSURL URLWithString:href];
        TFHppleElement *metadataChild = rows[1];
        TFHppleElement *pointsChild = [[metadataChild searchWithXPathQuery:@"//td/span"] firstObject];
        NSString *points = [pointsChild text];
        story.score = [points integerValue];
        TFHppleElement *authorElement = [[metadataChild searchWithXPathQuery:@"//td/a"] firstObject];
        story.authorName = authorElement.text;
        TFHppleElement *commentElement = [[metadataChild searchWithXPathQuery:@"//td/a"] lastObject];
        story.commentCount = [commentElement.text integerValue];
        NSString *commentLink = commentElement.attributes[@"href"];
        if (commentLink) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithString:commentLink];
            NSArray *queryArgs = [components.query componentsSeparatedByString:@"&"];
            for (NSString *query in queryArgs) {
                NSArray *kv = [query componentsSeparatedByString:@"="];
                if ([kv[0] isEqualToString:@"id"]) {
                    story.storyId = kv[1];
                }
            }
        }
        else {
            story.type = JRFStoryTypeHiring;
            story.storyId = [NSString stringWithFormat:@"%@%@", story.title, story.url];
        }
        [entries addObject:story];
    }
    return [NSArray arrayWithArray:entries];
}

@end
