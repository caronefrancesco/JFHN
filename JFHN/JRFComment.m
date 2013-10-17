//
//  JRFComment.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFComment.h"

@implementation JRFComment

- (NSInteger) depth {
    if (!self.parent) {
        return 0;
    }
    return self.parent.depth + 1;
}

- (JRFComment *)commentAtIndex:(NSInteger)index {
    if (index == 0) {
        return self;
    }
    if (index > [self commentCount]) {
        return nil;
    }
    index--;
    for (JRFComment *comment in [self comments]) {
        JRFComment *indexComment = [comment commentAtIndex:index];
        if (indexComment) {
            return indexComment;
        }
        index -= comment.commentCount;
    }
    return nil;
}

- (NSInteger) commentCount {
    return [[self.comments valueForKeyPath:@"@sum.commentCount"] integerValue] + 1;
}

@end
