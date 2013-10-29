//
//  JRFEntryDetailSerializer.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFCommentSerializer.h"
#import "JRFStory.h"
#import "JRFComment.h"
#import <hpple/TFHpple.h>
#import "NSString+HTML.h"

@implementation JRFCommentSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    TFHpple *document = [TFHpple hppleWithHTMLData:data];
    TFHppleElement *baseTable = [[document searchWithXPathQuery:@"//table"] objectAtIndex:3];
    NSMutableArray *comments = [NSMutableArray array];
    for (TFHppleElement *child in [baseTable children]) {
        JRFComment *comment = [JRFComment new];
        TFHppleElement *tr = [[child searchWithXPathQuery:@"//td/table/tr"] firstObject];
        TFHppleElement *img = [[tr searchWithXPathQuery:@"//td/img"] firstObject];
        NSInteger depth = [img.attributes[@"width"] integerValue] / 40;
        comment.depth = depth;
        TFHppleElement *td = [[tr searchWithXPathQuery:@"//td[@class='default']"] firstObject];
        TFHppleElement *authorElement = [[td searchWithXPathQuery:@"//div/span/a"] firstObject];
        comment.authorName = [authorElement text];
        TFHppleElement *commentElement = [[td searchWithXPathQuery:@"//span[@class='comment']"] firstObject];
        NSMutableArray *linkPairs = [NSMutableArray array];
        for (TFHppleElement *a in [commentElement searchWithXPathQuery:@"//a"]) {
            NSString *href = a.attributes[@"href"];
            NSString *truncated = a.text;
            if (href && truncated) {
                [linkPairs addObject:@{truncated: href}];
            }
        }
        NSString *tmp = @"WOOOJACKFLINTERMANN";
        NSString *placeholder = [tmp stringByAppendingString:@"<p>"];
        NSString *rawComment = [[commentElement raw] stringByReplacingOccurrencesOfString:@"<p>" withString:placeholder];
        rawComment = [rawComment stringByConvertingHTMLToPlainText];
        rawComment = [rawComment stringByReplacingOccurrencesOfString:tmp withString:@"\n\n"];
        for (NSDictionary *linkPair in linkPairs) {
            NSString *truncated = [[linkPair allKeys] firstObject];
            NSString *href = linkPair[truncated];
            rawComment = [rawComment stringByReplacingOccurrencesOfString:truncated withString:href];
        }
        comment.text = rawComment;
        [comments addObject:comment];
    }
    return [NSArray arrayWithArray:comments];
}

@end
