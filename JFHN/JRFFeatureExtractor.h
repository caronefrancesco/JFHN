//
//  JRFFeatureExtractor.h
//  JFHN
//
//  Created by Jack Flintermann on 3/4/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JRFEntry;

@interface JRFFeatureExtractor : NSObject

- (instancetype) initWithEntry:(JRFEntry *)entry;
- (NSSet *)features;

@end
