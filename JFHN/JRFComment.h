//
//  JRFComment.h
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRFComment : NSObject
@property(nonatomic) NSString *text;
@property(nonatomic) NSString *authorName;
@property(nonatomic) NSInteger depth;
@end
