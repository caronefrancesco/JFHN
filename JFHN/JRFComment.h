//
//  JRFComment.h
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRFComment : NSObject
- (JRFComment *)commentAtIndex:(NSInteger)index;
@property(nonatomic) NSString *commentId;
@property(nonatomic) NSArray *comments;
@property(nonatomic) NSString *text;
@property(nonatomic) NSString *authorName;
@property(nonatomic) JRFComment *parent;
@property(nonatomic, readonly) NSInteger depth;
@property(nonatomic, readonly) NSInteger commentCount;
@end
